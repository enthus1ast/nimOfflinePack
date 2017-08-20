# nimOfflinePack
Hi,

Dankrad and i have bundled a somewhat "little" (ca 3gb uncompressed / xxgb compressed) offline pack for you.
This comes in handy when you are offline and want to lookup/grep nim code. 
Or just want to explore the nim ecosystem.

We have build an index of (almost) all public available/visible nim repositories
and cloned the latest commit into a flat file structure which looks like so:

```bash
[...]
drwxr-xr-x    3 z z  4096 Aug 20 05:48 asynchttp__tulayang__41775260/
drwxr-xr-x    6 z z  4096 Aug 20 05:49 asyncmysql__tulayang__96606802/
drwxr-xr-x    5 z z  4096 Aug 20 05:17 asyncpg__cheatfate__62013761/
drwxr-xr-x    4 z z  4096 Aug 20 05:36 asyncredis__SSPkrolik__60104639/
drwxr-xr-x    5 z z  4096 Aug 20 06:32 asyncstreams__vegansk__66549671/
drwxr-xr-x    6 z z  4096 Aug 20 05:23 asynctools__cheatfate__68193970/
drwxr-xr-x    5 z z  4096 Aug 20 06:32 attano__k12a-cpu__59951809/
drwxr-xr-x    3 z z  4096 Aug 20 06:23 authserver__rgv151__61176253/
drwxr-xr-x    3 z z  4096 Aug 20 05:49 authserver__runvnc__18746970/
drwxr-xr-x    3 z z  4096 Aug 20 05:41 AutoCommit__pabloogc__73094817/
drwxr-xr-x    4 z z  4096 Aug 20 05:23 autome__miere43__62836170/
drwxr-xr-x    3 z z  4096 Aug 20 06:24 autonomic__rskew__100492444/
drwxr-xr-x    5 z z  4096 Aug 20 05:19 awk__greencardamom__57229375/
[...]
```


`where $reponame__$owner__$githubid`



every folder is still a git repository so you can `cd` into it and `git pull`.


we also have build a little tool called `mgit` which let you do the following:

```bash
# since we store the username this works:
z@z ~/n/repos> mgit "*Araq*"
R: nimedit__Araq__80336917
R: lexim__Araq__33143791
R: libcurl__Araq__41120819
R: nawabs__Araq__71706837
R: sphinx__Araq__40964451
R: wxnim__Araq__38682357
```



```bash
z@z ~/n/repos> mgit "*Araq*" log

[...]
################################################################################
###########################  nawabs__Araq__71706837  ###########################
################################################################################
log
commit 66be691045d792aa2db28de4f0e40c28c50d96f8
Author: Andreas Rumpf <rumpf_a@web.de>
Date:   Thu May 11 16:57:45 2017 +0200

    attempt to make nawabs work with choosenim


################################################################################
###########################  sphinx__Araq__40964451  ###########################
################################################################################
log
commit 629c5e1a4a468c5752e02d94734c05422b8a9c44
Author: Araq <rumpf_a@web.de>
Date:   Tue Aug 18 12:00:12 2015 +0200

    initial commit


################################################################################
###########################  wxnim__Araq__38682357  ############################
################################################################################
log
commit 86d4bfc7af539b57097086ea707312054f8fa5df
Author: Araq <rumpf_a@web.de>
Date:   Sun Aug 2 16:41:43 2015 +0200

    cleaned up examples; added missing files; fixes #1
z@z ~/n/repos> mgit "*Araq*" log
[...]
```
# mgit help
```
z@z ~> mgit
    mgit filePattern command

    filepattern is like:
        *
        nim*
    
    command is like:
        status
        commit -m "wip $REPO"

    variables in command:
        $REPO points to the actual repository name (withouth path)
        $TIMESTAMP gives an unix timestamp 
        ...
```


# Updateing
since these are git repositories and mgit can "bulk execute your git commands"
this should update all packages:

```bash
mgit "*" pull
```

pull for eg all dom96 packages (since we know he build cool stuff):
```bash
mgit "*dom96*" pull
mgit "*dom96*" log

```


# Download
[DOWNLOAD (xxgb)](http://code0.xyz/gitCollector/latest.7z)



| Type        | Hash          
| ------------- |:-------------:
| sha1     | right-aligned 
| sha256   | centered     |    


# Misc

this repo contains the cralwer and the downloader which helps to construct these packages.
Please be polite in useing it. (We try to always are because want to construct not destory right?!)
Since this this is such a noise process we
recommend that you download our compressed package.






# IDEAS/TODOS

- [] Make this nimble/nim importable somehow
- [] Prebuild html index?
- [] Update?

