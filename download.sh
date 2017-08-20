#!/bin/bash
nim c -d:ssl downloader.nim
xterm -hold -e watch "echo -n '- Repos: '; echo repos/* | wc -w; echo -n '  -> Size: '; du -hs repos/ | cut -f -1; echo -n '- Year: '; cat year.txt; echo; echo -n '- Page: '; cat page.txt" &
osiris downloader