#https://api.github.com/search/repositories?q=language:nim&page=0

import httpclient
import json
import strutils
import times # TODO: imported for testing, check if realy necessary to import times module
import tables

template dbg(args: varargs[untyped]) =
  when not defined release: debugEcho args

type
  GithubProject = ref object of RootObj
    id: int # id
    owner: string # project owner name
    name: string # project name
    url: string # clone url
  GithubProjects = seq[GithubProject]
  GithubCollector = ref object of RootObj
    client: HttpClient
    rateLimit: int # Max request until RateLimitReset (timestamp) is passed
    rateLimitRemaining: int # Amount of available requests before RateLimitReset (timestamp) is passed
    rateLimitReset: int # Timestamp when the RateLimitRemaining gets reset
    totalCount: int # Amount of found repositories
    actualPage: int # Actual page
    maxPage: int # Actual page
    # maxItems: int # max items per page = 100 (set by github)
    lang: string # project language to search for

proc newGithubCollector(lang: string): GithubCollector =
  result = GithubCollector()
  result.client = newHttpClient()
  result.rateLimit = -1
  result.rateLimitRemaining = -1
  result.rateLimitReset = -1
  result.totalCount = -1
  result.maxPage = 1
  result.lang = lang

iterator collect(gcolletor: GithubCollector): GithubProject =
  var
    url = "https://api.github.com/search/repositories?q=language:" & gcolletor.lang & "&per_page=100&page=0"
    resp = gcolletor.client.request(url)
    jsonNode = parseJson(resp.body)

  gcolletor.rateLimit = resp.headers["X-RateLimit-Limit"].parseInt
  gcolletor.rateLimitRemaining = resp.headers["X-RateLimit-Remaining"].parseInt
  gcolletor.rateLimitReset = resp.headers["X-RateLimit-Reset"].parseInt
  gcolletor.totalCount = jsonNode.getOrDefault("total_count").getNum.int
  dbg "result.rateLimit: " & $gcolletor.rateLimit
  dbg "result.rateLimitRemaining: " & $gcolletor.rateLimitRemaining
  dbg "result.rateLimitReset: " & $gcolletor.rateLimitReset
  dbg "result.totalCount: " & $gcolletor.totalCount
  dbg fromSeconds(gcolletor.rateLimitReset)

# proc collect(gcolletor: GithubCollector): GithubProjects =
#   result = newSeq[GithubProject]()
#   var
#     url = "https://api.github.com/search/repositories?q=language:" & gcolletor.lang & "&page=0"
#     resp = gcolletor.client.request(url)
#     jsonNode = parseJson(resp.body)

#   gcolletor.rateLimit = resp.headers["X-RateLimit-Limit"].parseInt
#   gcolletor.rateLimitRemaining = resp.headers["X-RateLimit-Remaining"].parseInt
#   gcolletor.rateLimitReset = resp.headers["X-RateLimit-Reset"].parseInt
#   gcolletor.totalCount = jsonNode.getOrDefault("total_count").getNum.int
#   dbg "result.rateLimit: " & $gcolletor.rateLimit
#   dbg "result.rateLimitRemaining: " & $gcolletor.rateLimitRemaining
#   dbg "result.rateLimitReset: " & $gcolletor.rateLimitReset
#   dbg "result.totalCount: " & $gcolletor.totalCount
#   dbg fromSeconds(gcolletor.rateLimitReset)


# proc reqGithubProjects(gcollector: GithubCollector, )


when isMainModule:
  var githubCollector = newGithubCollector("nim")
  # echo $epochTime()