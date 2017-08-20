import strutils
import ospaths
import os
import nimGithubProjects
# import subexe
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
  # result.db 

# var ready = newFlatDb("ready.db")

proc computeName(gproject: GithubProject): string =
   """$#__$#__$#""" % [gproject.name, gproject.owner, $gproject.githubId]

proc getDir(dow: GpDownloader, gproject: GithubProject): string = 
  return dow.repopath / gproject.computeName()


proc genGitCmd(dow: GpDownloader, gproject: GithubProject): string = 
  let gitPath = findExe("git")
  let computedName = gproject.computeName()
  # let basepath = "/foo/baa/collector/repos/"
  return """$# clone --depth=1 $# $#""" % [gitPath , gproject.url, dow.getDir(gproject)] # basepath / computedName


proc download(dow: GpDownloader, gps: GithubProjects) =
  for idx, gp in gps:  
    echo "[+] Clone [$#/$#]: $#" % [$(idx+1), $gps.len(), gp.name]
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

when isMainModule:

  var down = newGpDownloader("gp.db", "./repos")
  var gps = newSeq[GithubProject]()
  gps.add GithubProject(
      githubId : 1234, 
      owner : "enthus1ast",
      name : "flatdb",  
      url : "http://github.com/enthus1ast/flatdb.git"
  )
  down.download(gps)