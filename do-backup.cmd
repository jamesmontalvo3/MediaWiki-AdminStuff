@echo off

 

REM ##### ENVIRONMENT VARIABLES #####

set backupScriptLocation=C:\wikibackup

 

set local=C:\path\to\local

set source=\\path\to\source\server

set future=\\path\to\new\server

set backup=\\path\to\backup\location

 

set localhost=localhost

set localuser=username

set localpass=password

set localdb=dbname

 

set sourcehost=host

set sourceuser=username

set sourcepass=password

set sourcedb=dbname

 

set futurehost=host

set futureuser=username

set futurepass=password

set futuredb=dbname

 

 

REM ##### TABLE OF CONTENTS #####

 

REM (1)  DELETE images directory on local wiki

REM (2)  LOCK source wiki; make read-only

REM (3)  XCOPY files from source to local/wiki/images

REM (4)  MYSQLDUMP source sql to local/wiki, called %DATE%-wiki-db-1.17.sql

REM (5)  UNLOCK source; make wiki editable

REM (6)  PUSH SQL to local/wiki, PROCESS with PHP scripts

REM (7)  MYSQLDUMP local/wiki sql to local/wiki, called %DATE%-wiki-db-1.21.sql

REM (8)  LOCK future wiki; make read-only

REM (9)  PUSH SQL to future wiki

REM (10) DELETE images directory on future wiki

REM (11) XCOPY new images directory from local/wiki/images to future/wiki/images

REM (12) UNLOCK future wiki; make wiki editable

REM (13) COMPRESS all of local/wiki (including 2 SQL files), pushing zip file to backup server

REM (14) DELETE two SQL files in local/wiki (leave images so local/wiki works)

 

 

REM ##### (1) DELETE images directory on local #####

echo STEP 1: Deleting local images folder...

rmdir %local%\images /S /Q

echo STEP 1: COMPLETE

echo:

 

REM ##### (2) LOCK source wiki; make read-only #####

type %backupScriptLocation%\lib\setReadOnlyContent.txt > %source%\wgReadOnly.php

echo STEP 2: COMPLETE

echo:

 

REM ##### (3) XCOPY files from source to local/wiki/images #####

echo STEP 3: Copying files from source to local

xcopy "%source%\images" "%local%\images" /c /d /i /y /e /s

echo STEP 3: COMPLETE

echo:

 

REM ##### (4) MYSQLDUMP source sql to local/wiki, called wiki-db-1.17.sql #####

echo STEP 4: mysqldump source onto local

C:/xampp/mysql/bin/mysqldump.exe --host=%sourcehost% --user=%sourceuser% --password=%sourcepass% %sourcedb% > %local%/wiki-db-1.17.sql

echo STEP 4: COMPLETE

echo:

 

REM ##### (5) UNLOCK source; make wiki editable #####

type %backupScriptLocation%\lib\unsetReadOnlyContent.txt > %source%\wgReadOnly.php

echo STEP 5: COMPLETE

echo:

 

REM ##### (6) PUSH SQL to local/wiki, PROCESS with PHP scripts #####

echo STEP 6: Push SQL to local wiki and run PHP upgrade scripts

 

REM (6.1) PUSH SQL

echo ...pushing SQL

C:\\xampp\mysql\bin\mysql.exe -h %localhost% -u %localuser% --pass=%localpass% %localdb%  < %local%\wiki-db-1.17.sql

 

REM (6.2) PROCESS WITH PHP SCRIPTS

echo ...script 1: updating database to MediaWiki v1.21 via update.php script

C:\\xampp\php\php.exe %local%\maintenance\update.php

 

echo ...script 2: running first Semantic MediaWiki update script

C:\\xampp\php\php.exe %local%\extensions\SemanticMediaWiki\maintenance\SMW_setup.php -b SMWSQLStore3

 

echo ...script 3: running second Semantic MediaWiki update script

C:\\xampp\php\php.exe %local%\extensions\SemanticMediaWiki\maintenance\SMW_refreshData.php -v -b SMWSQLStore3 -fp

 

echo ...script 4: running third Semantic MediaWiki update script

C:\\xampp\php\php.exe %local%\extensions\SemanticMediaWiki\maintenance\SMW_refreshData.php -v -b SMWSQLStore3

 

echo STEP 6: COMPLETE

echo:

 

REM ##### (7) MYSQLDUMP local/wiki sql to local/wiki, called %DATE%-wiki-db-1.21.sql #####

echo STEP 7: Mysqldump of updated data from local

C:/xampp/mysql/bin/mysqldump.exe --host=%localhost% --user=%localuser% --password=%localpass% %localdb% > %local%\wiki-db-1.21.sql

echo STEP 7: COMPLETE

echo:

 

REM ##### (8) LOCK future wiki; make read-only #####

type %backupScriptLocation%\lib\setReadOnlyContent.txt > %future%\wgReadOnly.php

echo STEP 8: COMPLETE

echo:

 

REM ##### (9) PUSH SQL to future wiki #####

echo STEP 9: Push SQL to future wiki

C:\\xampp\mysql\bin\mysql.exe -h %futurehost% -u %futureuser% --pass=%futurepass% %futuredb%  < %local%\wiki-db-1.21.sql

echo STEP 9: COMPLETE

echo:

 

REM ##### (10) DELETE images directory on future wiki #####

echo STEP 10: Removing existing images from future wiki

rmdir %future%\images /S /Q

echo STEP 10: COMPLETE

echo:

 

REM ##### (11) XCOPY new images directory from local/wiki/images to future/wiki/images #####

echo STEP 11: Copying from local to future

xcopy "%local%\images" "%future%\images" /c /d /i /y /e /s

echo STEP 11: COMPLETE

echo:

 

REM ##### (12) UNLOCK future wiki; make wiki editable #####

type %backupScriptLocation%\lib\unsetReadOnlyContent.txt > %future%\wgReadOnly.php

echo STEP 12: COMPLETE

echo:

 

REM ##### (13) COMPRESS all of local/wiki (including 2 SQL files), push .zip to S-Drive #####

echo STEP 13: Compressing data, storing on backup server

C:\Progra~1\7-Zip\7z.exe a "%backup%\%date:~6,4%%date:~0,2%%date:~3,2%%time:~0,2%%time:~3,2%%time:~6,2%-wiki.zip" "%local%\*" -r -tzip

echo STEP 13: COMPLETE

echo:

 

REM ##### (14) DELETE two SQL files in local/wiki (leave images so local/wiki works) #####

echo STEP 14: Delete SQL files on local

del %local%\wiki-db-1.21.sql

del %local%\wiki-db-1.17.sql

echo STEP 14: COMPLETE

echo:

 

echo:

echo:

echo Complete with 3-Way-Backup!

