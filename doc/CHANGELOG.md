##### 0.1.4.0 Mon Nov 24 04:40:59 2014 +0100
- change structure of __blscd_move_line()
- do coloration in the browser with <LS_COLORS> (`paste`(1) is now needed)
- change behaviour of column 2 and 3 in the browser, when the cursor stats a file or an empty directory

##### 0.1.3.0 Fri Nov 21 23:39:08 2014 +0100
- implement sorting (atime, ctime, mtime, size, type, basename, natural) with keys <oX>
- hide/unhide files; toggle filter with key <^H>
- temporarily remove marking/selection action
- restruct functions

##### 0.1.2.11 Sun Sep 28 00:57:29 2014 +0200
- replace key 'm' with 'N': By default, go to newest/oldest file
- some fixes

##### 0.1.2.0 Mon Sep 22 15:53:30 2014 +0200
- after exit all variables, arrays and functions will have been unset
- implement file sizes and file indicators in the browser
- currently, we do not need 'find' and 'sort' anymore
- the status line shows the number of files in the highlighted directory
- 'vi' is now fallback when using key <E>
- we do not use 'SIGALRM' anymore
- open the console with key <:>
- the search mechanism is now also useable as console command named 'search'
- search is now case insensitive
- some fixes when using key </> (matching and marking)
- some internal changes (renaming etc.)

##### 0.1.1.0 Fri Sep 12 20:32:55 2014 +0200
- Open a forked shell in the current directory with key <S>
- Edit the current file in '<EDITOR>' with key <E>
- go to first match after search prompt
- marked lines with indention and normal bg
- mini changes
