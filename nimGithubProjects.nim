#https://api.github.com/search/repositories?q=language:nim&page=0

import httpclient
import json
import strutils
import times
import math
import os # TODO: Remove, used for bad file database

template dbg(args: varargs[untyped]) =
  when not defined release: debugEcho args

const GITHUB_REPOS_START_YEAR: int = 2010
const GITHUB_REPOS_PER_PAGE: int = 100
const GITHUB_REPOS_QUERY_LIMIT: int = 1000

type
  GithubProject* = ref object of RootObj
    githubId*: int # id
    user*: string # project owner name
    project*: string # project name
    url*: string # clone url
  GithubProjects* = seq[GithubProject]
  GithubCollector* = ref object of RootObj
    client*: HttpClient
    rateLimit*: int # Max request until RateLimitReset (timestamp) is passed
    rateLimitRemaining*: int # Amount of available requests before RateLimitReset (timestamp) is passed
    rateLimitReset*: int # Timestamp when the RateLimitRemaining gets reset
    totalCount*: int # Amount of found repositories
    actualPage*: int # Actual page
    maxPage*: int # Actual page
    # maxItems*: int # max items per page = 100 (set by github)
    actualYear*: int
    lang*: string # project language to search for

proc savePage(page: int) =
  writeFile("page.txt", $page)

proc saveYear(year: int) =
  writeFile("year.txt", $year)

proc loadYear(): int =
  if fileExists("year.txt"):
    return readFile("year.txt").parseInt
  else:
    return GITHUB_REPOS_START_YEAR

proc loadPage(): int =
  if fileExists("page.txt"):
    return readFile("page.txt").strip().parseInt
  else:
    return 1

proc url(gcollector: GithubCollector): string =
  var createdFilter: string = "created:" & $gcollector.actualYear & "-01-01T00:00:00.." & $(gcollector.actualYear) & "-12-31T23:59:59"
  return "https://api.github.com/search/repositories?q=language:" & gcollector.lang & "+" & createdFilter & "&per_page=100&page=" & $gcollector.actualPage

proc reset*(gcollector: GithubCollector) =
  gcollector.rateLimit = -1
  gcollector.rateLimitRemaining = -1
  gcollector.rateLimitReset = -1
  gcollector.totalCount = -1
  gcollector.actualPage = loadPage()
  gcollector.maxPage = -1
  gcollector.actualYear = GITHUB_REPOS_START_YEAR

proc newGithubCollector*(lang: string): GithubCollector =
  result = GithubCollector()
  result.client = newHttpClient()
  result.reset()
  result.lang = lang

iterator getGithubProjects(gcollector: GithubCollector, jsonNode: JsonNode): GithubProject =
  var
    gproject: GithubProject
    ownerNode: JsonNode

  for node in jsonNode.getOrDefault("items").items():
    ownerNode = node.getOrDefault("owner")

    gproject = GithubProject()
    gproject.githubId = node.getOrDefault("id").getNum.int
    gproject.user = ownerNode.getOrDefault("login").getStr
    gproject.project = node.getOrDefault("name").getStr
    gproject.url = node.getOrDefault("clone_url").getStr
    dbg "### QUERY (API) URL => " & gcollector.url
    dbg "=> Project: " & gproject.project
    dbg "   - Owner: " & gproject.user & "(" & $gproject.githubId & ")"
    dbg "   - Url: " & gproject.url
    dbg "###"

    yield gproject

iterator collect*(gcollector: GithubCollector): GithubProject =
  var
    resp: Response
    jsonNode: JsonNode
    startPage: int = loadPage()
    startYear: int = loadYear()

  for year in startYear..getTime().toTimeInterval.years:
    gcollector.actualYear = year
    saveYear(year)

    resp = gcollector.client.request(gcollector.url)
    jsonNode = parseJson(resp.body)

    gcollector.rateLimitRemaining = resp.headers["X-RateLimit-Remaining"].parseInt
    gcollector.rateLimitReset = resp.headers["X-RateLimit-Reset"].parseInt
    gcollector.totalCount = jsonNode.getOrDefault("total_count").getNum.int
    gcollector.maxPage = math.ceil(gcollector.totalCount / GITHUB_REPOS_PER_PAGE).int
    gcollector.rateLimit = resp.headers["X-RateLimit-Limit"].parseInt

    # for node in jsonNode.getGithubProjects():
    #   yield node

    for page in startPage..gcollector.maxPage:
      gcollector.actualPage = page
      savePage(page)

      resp = gcollector.client.request(gcollector.url)
      jsonNode = parseJson(resp.body)

      for node in gcollector.getGithubProjects(jsonNode):
        yield node

    startPage = 1 # reset to one for the next year

when isMainModule:
  var gcollector = newGithubCollector("nim")
  # echo gcollector.url
  try:
    for project in gcollector.collect():
      echo project.project
  except:
    echo gcollector.url
    quit(123)