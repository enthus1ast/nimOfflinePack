#https://api.github.com/search/repositories?q=language:nim&page=0

import httpclient
import json
import strutils
import times # TODO: imported for testing, check if realy necessary to import times module
import math

template dbg(args: varargs[untyped]) =
  when not defined release: debugEcho args

const GITHUB_REPOS_PER_PAGE: int = 100
const GITHUB_REPOS_QUERY_LIMIT: int = 1000

type
  GithubProject* = ref object of RootObj
    id*: int # id
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
    lang*: string # project language to search for

proc reset*(gcollector: GithubCollector) =
  gcollector.rateLimit = -1
  gcollector.rateLimitRemaining = -1
  gcollector.rateLimitReset = -1
  gcollector.totalCount = -1
  gcollector.actualPage = 1
  gcollector.maxPage = -1

proc newGithubCollector*(lang: string): GithubCollector =
  result = GithubCollector()
  result.client = newHttpClient()
  result.reset()
  result.lang = lang

proc getGithubProjects(jsonNode: JsonNode): GithubProjects =
  result = newSeq[GithubProject]()
  var
    gproject: GithubProject
    ownerNode: JsonNode

  for node in jsonNode.getOrDefault("items").items():
    ownerNode = node.getOrDefault("owner")

    gproject = GithubProject()
    gproject.id = node.getOrDefault("id").getNum.int
    gproject.user = ownerNode.getOrDefault("login").getStr
    gproject.project = node.getOrDefault("name").getStr
    gproject.url = node.getOrDefault("clone_url").getStr
    dbg "gproject.id: " & $gproject.id
    dbg "gproject.owner: " & gproject.user
    dbg "gproject.name: " & gproject.project
    dbg "gproject.url: " & gproject.url

    result.add(gproject)

proc collect*(gcollector: GithubCollector): GithubProjects =
  var
    url: string = "https://api.github.com/search/repositories?q=language:" & gcollector.lang & "&per_page=100&page=" & $gcollector.actualPage
    resp: Response = gcollector.client.request(url)
    jsonNode: JsonNode = parseJson(resp.body)

  if gcollector.rateLimit == -1:
    gcollector.rateLimit = resp.headers["X-RateLimit-Limit"].parseInt
  if gcollector.rateLimitRemaining == -1:
    gcollector.rateLimitRemaining = resp.headers["X-RateLimit-Remaining"].parseInt
  if gcollector.rateLimitReset == -1:
    gcollector.rateLimitReset = resp.headers["X-RateLimit-Reset"].parseInt
  if gcollector.totalCount == -1:
    gcollector.totalCount = jsonNode.getOrDefault("total_count").getNum.int
  if gcollector.maxPage == -1:
    gcollector.maxPage = math.ceil(gcollector.totalCount / GITHUB_REPOS_PER_PAGE).int

  return jsonNode.getGithubProjects()

when isMainModule:
  var gcollector = newGithubCollector("nim")
  discard gcollector.collect()