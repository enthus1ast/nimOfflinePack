import strutils
import ospaths
import os
import nimGithubProjects
import flatdb
import json
import times

type GpDownloader = object of RootObj
  repopath: string
  dbpath: string
  readyDb: FlatDb

proc newGpDownloader(dbpath, repopath: string): GpDownloader =
  result = GpDownloader()
  result.repopath = repopath
  createDir(repopath)

  result.dbpath = dbpath
  result.readyDb = newFlatDb("ready.db")
  if not result.readyDb.load():
    echo "could not load ready.db"

proc computeName(gproject: GithubProject): string =
   """$#__$#__$#""" % [gproject.project, gproject.user, $gproject.githubId]

proc getDir(dow: GpDownloader, gproject: GithubProject): string =
  return dow.repopath / gproject.computeName()

proc genGitCmd(dow: GpDownloader, gproject: GithubProject): string =
  let gitPath = findExe("git")
  let computedName = gproject.computeName()
  return """$# clone --depth=1 $# $#""" % [gitPath , gproject.url, dow.getDir(gproject)]

proc download(dow: GpDownloader, gps: GithubProjects) =
  for idx, gp in gps:
    echo "[+] Clone [$#/$#]: $#" % [$(idx+1), $gps.len(), gp.project]
    if dirExists(dow.getDir(gp)):
      # folder exists, now check if it was ready before,
      if not dow.readyDb.exists( equal("name", gp.computeName())):
        echo "--> folder is there but was not marked ready, we think that this clone was corrupted. So delete and start new"
        removeDir(dow.getDir(gp))
      else:
        echo "--> skipping"
        continue

    echo dow.genGitCmd(gp)
    let res = execShellCmd(dow.genGitCmd(gp))
    if res == 0:
      discard dow.readyDb.append(%*{"name": gp.computeName(), "insertTime": epochTime()})
      echo "DONE\n"

proc store(dow: GpDownloader, findsDb: FlatDb, project: GithubProject) =
  # for gp in projects:
  if not findsDb.exists( equal("name", project.computeName())):
    discard findsDb.append( %*project  )

when isMainModule:
  var down = newGpDownloader("gp.db", "./repos")
  var findsDb = newFlatDb("finds.db")
  # var gps = newSeq[GithubProject]()
  # gps.add GithubProject(
  #     githubId : 1234,
  #     user : "enthus1ast",
  #     project : "flatdb",
  #     url : "http://github.com/enthus1ast/flatdb.git"
  # )
  var gcollector = newGithubCollector("nim")
  # var gps = gcollector.collect()
  # down.store(findsDb, gps)
  for gp in gcollector.collect():
    down.store(findsDb, gp)
    down.download(@[gp])
  # for gp in gcollector.collect(Asc):
  #   down.store(findsDb, gp)
  #   down.download(@[gp])