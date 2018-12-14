@ECHO OFF
SETLOCAL enabledelayedexpansion
REM //////////////////////////////////////////////////////////////////////////////
REM ///////////////////// APK Tesing Tool (LIME Security) ////////////////////////
REM /////////////////////////// VER 1.13 (2018-12-14)) /////////////////////////////
REM //////////////////////////////////////////////////////////////////////////////

SET current_dir=%cd%
SET att_dir=%~dp0

REM 라인커맨드인지 or 메뉴 모드인지 확인 후 경로 SET
REM 라인커맨드- 현재 디렉토리에서 작업, 메뉴모드- att 실행 디렉토리에서 작업
:HEAD
IF [%1]==[] (
	SET mode=menustyle
	SET source_dir=%att_dir%source
	SET output_dir=%att_dir%output
	SET ext-tools_dir=%att_dir%ext-tools
	IF NOT EXIST "!source_dir!" MKDIR "!source_dir!"
	GOTO MENU
) ELSE (
	SET mode=linestyle
	SET source_dir=%current_dir%
	SET output_dir=%current_dir%\output
	SET ext-tools_dir=%att_dir%\ext-tools
	GOTO LINE
)

:LINE
IF %1==p SET workno=1
IF %1==d SET workno=2
IF %1==d-no-res SET workno=3
IF %1==j SET workno=4
IF %1==b SET workno=5
IF %1==s SET workno=6
IF %1==i SET workno=7
IF %1==h SET workno=99
GOTO START

:MENU
mode con:cols=100 lines=1000
CLS
REM ┚┎┖┒━┃  ㅂ  ━  ┃ ┣ ┫ ─ ┣┠ ┨
ECHO.
ECHO ┎--------------------------------------------------------------------------┒
ECHO ┃                  APK Testing Tool (Lime Security)                        ┃
ECHO ┠--------------------------------------------------------------------------┨
ECHO ┃                             VER 1.13 (2018-12-14)                        ┃
ECHO ┣--------------------------------------------------------------------------┫
ECHO ┃                                                                          ┃
ECHO ┃ 1. Search and Pull APK File                                              ┃
ECHO ┃                                                                          ┃
ECHO ┃ 2. Decoding APK                          5. Build APK                    ┃
ECHO ┃ 3. Decoding APK (no-res option)          6. Sign APK                     ┃
ECHO ┃ 4. View Java (With Jad-gui)              7. Install APK                  ┃
ECHO ┃                                                                          ┃
ECHO ┃ 8. Encoding UNICODE to KOR (python 3.x)                                  ┃
ECHO ┃ 9. Encoding KOR to UNICODE (python 3.x)                                  ┃
ECHO ┃                                                                          ┃
ECHO ┃ 10. Build + Sign + Install APK                                           ┃
ECHO ┃ 11. Extract files from APP_DIR (VD only)                                 ┃
ECHO ┃ 12. Quit                                                                 ┃
ECHO ┃                                                                          ┃
ECHO ┖--------------------------------------------------------------------------┚
SET /p workno=[ATT] SELECT NO: 


:START
IF (%workno%)==() GOTO END
IF %workno%==1 GOTO PACKAGES
IF %workno%==2 GOTO DECODE
IF %workno%==3 GOTO DECODE_NO_RES
IF %workno%==4 GOTO JAVA_SOURCE
IF %workno%==5 GOTO BUILD
IF %workno%==6 GOTO SIGN
IF %workno%==7 GOTO INSTALL
If %workno%==8 GOTO UnicodeToKOR
If %workno%==9 GOTO KorToUnicode
IF %workno%==10 GOTO INSTALL_ALL
IF %workno%==11 GOTO PULL_APPDIR
IF %workno%==12 GOTO QUIT
IF %workno%==99 GOTO HELP
IF %workno%==13 GOTO ADB_ROOT_TEST
GOTO END


:PACKAGES
REM /////////////////////// PACKAGES /////////////////////////////////
SET CURRENT_WORK=PACAGES_2
GOTO ADB_CONNECT_TEST
:PACAGES_2
IF NOT [%2]==[] (
	SET searchkey=%2
) ELSE (
	SET searchkey=
	SET /p searchkey=[ATT] Input keyword to search packeages : 
)
IF (%searchkey%)==() GOTO END
SET num=0
ECHO [ATT] Searching packages with keyword '%searchkey%' ....
ECHO.
for /f "tokens=1,2,3 delims=:=" %%i in ('"%ext-tools_dir%\sdk-tools\adb" shell pm list packages -f') do (
	echo %%k | findstr /C:%searchkey% 1>null
	if errorlevel 1 (
		REM
	) ELSE (
		set /a num=num+1
		set pfile[!num!]=%%j
		set pname[!num!]=%%k
		echo [!num!] : %%j
	)
)
IF %num%==0 (
	ECHO [ATT] No packages fonund.
	GOTO PKG_END
) ELSE (
	ECHO.
)
SET /p str=[ATT] Select Apk file to pull : 
IF %str% gtr %num% (
	SET /p str=[ATT] Cancel? [y/n]: 
	IF !str!==y (GOTO END) ELSE (GOTO PACKAGES)
)
SET ori_apk=!pfile[%str%]!
SET new_apk=!pname[%str%]!.apk
"%ext-tools_dir%\sdk-tools\adb" pull %ori_apk% "%source_dir%\%new_apk%"
ECHO [ATT] Saved as: %source_dir%\%new_apk%

:PKG_END
del null
GOTO END


:DECODE
REM //////////////////////// DECODE //////////////////////////////////
REM // CALL로 apktool.bat 를 호출할 경우 -Dfile.encoding=UTF8 세팅으로인해 cmd 창 폰트설정이 리셋되는 문제가 있어 해당 옵션을 빼고 jar를 직접 실행 (원래 UTF8을 가정하고 apktool를 작성했을 것이므로 차후 인코딩 오류 이슈가 존재할 수도 있음)
SET CURRENT_WORK=DECODE_2
GOTO SELECT_TARGET2
:DECODE_2
IF exist "%output_dir%\%targetapk%\" (
	ECHO [ATT] Old directory is exist. : %output_dir%\%targetapk%\
	SET /p str=[ATT] Overwrite old directory?[y/n] : 
	IF !str!==y (
		REM
	) ELSE (
		GOTO DECODE_END
	)
)
java -jar "%ext-tools_dir%\apktool\apktool.jar" d "%source_dir%"\%targetapk% -o "%output_dir%"\%targetapk%\ -p "%output_dir%"\%targetapk%\framework\ -f
if errorlevel 1 goto ERROR1
ECHO [ATT] Output: %output_dir%\%targetapk%\
:DECODE_END
GOTO END


:DECODE_NO_RES
REM ///////////////// DECODE with no-res option //////////////////////
SET CURRENT_WORK=DECODE_NO_RES_2
GOTO SELECT_TARGET2
:DECODE_NO_RES_2
IF exist "%output_dir%\%targetapk%\" (
	ECHO [ATT] Old directory is exist. : %output_dir%\%targetapk%\
	SET /p str=[ATT] Overwrite old directory?[y/n] : 
	IF !str!==y (
		ECHO [ATT] Deleting old directory... Please wait.
		rmdir /s /q "%output_dir%\%targetapk%"
	) ELSE (
		GOTO DECODE_NO_RES_END
	)
)
java -jar "%ext-tools_dir%\apktool\apktool.jar" d "%source_dir%"\%targetapk% -r -o "%output_dir%"\%targetapk%\ -p "%output_dir%"\%targetapk%\framework\
if errorlevel 1 goto ERROR1
ECHO [ATT] Output: %output_dir%\%targetapk%\
:DECODE_NO_RES_END
GOTO END


:BUILD
REM ///////////////////////// BUILD //////////////////////////////////
SET CURRENT_WORK=BUILD_2
GOTO SELECT_TARGET2
:BUILD_2
java -jar "%ext-tools_dir%\apktool\apktool.jar" b "%output_dir%"\%targetapk%\ -p "%output_dir%"\%targetapk%\framework\ --force
if errorlevel 1 goto ERROR1
ECHO [ATT] Output: %output_dir%\%targetapk%\dist\%targetapk%
GOTO END


:SIGN
REM ///////////////////////// SIGN ///////////////////////////////////
SET CURRENT_WORK=SIGN_2
GOTO SELECT_TARGET2
:SIGN_2
IF NOT EXIST "%output_dir%\%targetapk%\dist\%targetapk%" (
	ECHO [ATT] No apk file.
	GOTO END
)
ECHO [ATT] Signing... Please wait.
java -jar "%ext-tools_dir%\signapk\signapk.jar" "%ext-tools_dir%\signapk\certificate.pem" "%ext-tools_dir%\signapk\key.pk8" "%output_dir%"\%targetapk%\dist\%targetapk% "%output_dir%"\%targetapk%\dist\signed-%targetapk%
if errorlevel 1 goto ERROR1
ECHO [ATT] Output: %output_dir%\%targetapk%\dist\signed-%targetapk%
GOTO END


:INSTALL
REM //////////////////////// INSTALL /////////////////////////////////
SET CURRENT_WORK=INSTALL_2
GOTO ADB_CONNECT_TEST
:INSTALL_2
SET CURRENT_WORK=INSTALL_3
GOTO SELECT_TARGET2
:INSTALL_3
IF NOT EXIST "%output_dir%"\%targetapk%\dist\signed-%targetapk% (
	ECHO [ATT] No signed-apk file in build directory. Build and Sign apk file first.
	GOTO END
)
"%ext-tools_dir%\sdk-tools\adb" install -r "%output_dir%"\%targetapk%\dist\signed-%targetapk%
if errorlevel 1 goto ERROR1
GOTO END


:JAVA_SOURCE
REM /////////////////////// JAVA_SOURCE //////////////////////////////
SET CURRENT_WORK=JAVA_SOURCE_2
GOTO SELECT_TARGET2
:JAVA_SOURCE_2
IF NOT EXIST "%output_dir%\%targetapk%\java\*.jar" (
	IF NOT EXIST "%output_dir%"\%targetapk%\build\apk\classes.dex (
		ECHO [ATT] There is no classes.dex. You must build apk first.
		SET /p str=[ATT] Do you want build apk?[y/n]: 
		IF !str!==y (
			java -jar "%ext-tools_dir%\apktool\apktool.jar" b "%output_dir%"\%targetapk%\ -p "%output_dir%"\%targetapk%\framework\ --force
			if errorlevel 1 goto ERROR1
			GOTO JAVA_SOURCE_2
		) ELSE (
			GOTO END
		)
	)
	FOR %%i in ("%output_dir%"\%targetapk%\build\apk\*.dex) DO (
		CALL "%ext-tools_dir%\dex2jar-2.0\d2j-dex2jar.bat" "%%i" --force
		if errorlevel 1 goto ERROR1
	)
	IF NOT EXIST "%output_dir%"\%targetapk%\java mkdir "%output_dir%"\%targetapk%\java
	move classes*.jar "%output_dir%"\%targetapk%\java\
	IF EXIST classes*.zip move classes*.zip "%output_dir%"\%targetapk%\java\
	ECHO [ATT] Output: "%output_dir%"\%targetapk%\java\
)
"%ext-tools_dir%\jd-gui\jd-gui.exe" "%output_dir%"\%targetapk%\java\*.jar
ECHO [ATT] Execute jd-gui.exe.
GOTO END


:INSTALL_ALL
SET CURRENT_WORK=INSTALL_ALL_2
GOTO SELECT_TARGET2
:INSTALL_ALL_2
ECHO.
ECHO [ATT] Building %targetapk%...
java -jar "%ext-tools_dir%\apktool\apktool.jar" b "%output_dir%"\%targetapk%\ -p "%output_dir%"\%targetapk%\framework\ --force
ECHO.
ECHO [ATT] Signing %targetapk%...
java -jar "%ext-tools_dir%\signapk\signapk.jar" "%ext-tools_dir%\signapk\certificate.pem" "%ext-tools_dir%\signapk\key.pk8" "%output_dir%"\%targetapk%\dist\%targetapk% "%output_dir%"\%targetapk%\dist\signed-%targetapk%
ECHO.
ECHO [ATT] Installing %targetapk%...
"%ext-tools_dir%\sdk-tools\adb" install -r "%output_dir%"\%targetapk%\dist\signed-%targetapk%
GOTO END


:ADB_CONNECT_TEST
"%ext-tools_dir%\sdk-tools\adb" shell pwd 1>null
IF errorlevel 1 (
	ECHO [ATT] No device found.
) else (
	GOTO %CURRENT_WORK%
)
SET /p str=[ATT] Do you want trying 'adb kill-server'?[y/n]: 
IF (%str%)==() GOTO END
IF %str%==y (
	"%ext-tools_dir%\sdk-tools\adb" kill-server
	GOTO ADB_CONNECT_TEST
) ELSE (
	ECHO [ATT] Manually connect device and try again.
	GOTO END
)


:ADB_ROOT_TEST
"%ext-tools_dir%\sdk-tools\adb" shell "ls /data/data" | findstr /C:"Permission" > null
if errorlevel 1 (
	GOTO %CURRENT_WORK%
) ELSE (
	ECHO [ATT] Permission denied.
	ECHO [ATT] This command is only available in Virual Device.
	GOTO END
)


:UnicodeToKOR
ECHO [ATT] Enclose string in double quote, if string contain 'space'. 
SET /p str=[ATT] UNICODE String: 
If (%str%)==() GOTO END
python "%ext-tools_dir%"\KorUnicode.py 1 %str%
GOTO END


:KorToUnicode
ECHO [ATT] Enclose string in double quote, if string contain 'space'. 
SET /p str=[ATT] KOR String: 
If (%str%)==() GOTO END
python "%ext-tools_dir%"\KorUnicode.py 2 %str%
GOTO END


:HELP
ECHO APK file Testing Tool v1.01 (2018-08-30)
ECHO [USAGE] ATT.BAT Command Target
ECHO Command:
ECHO     p: Search apk file with keyword from connected device. 
ECHO        And apk file is saved in current directory (apk file name = project name)
ECHO     d: Decode target project (out: [current]\output\[apkname]\)
ECHO        (d-no-res: Decode with no-res option)
ECHO     b: Build target project (out: [current]\output\[apkname]\dist\)
ECHO     s: Sign target project (out: [currnet]\output\[apkname]\dist\signed-apkname)
ECHO     i: Install signed apk to device
ECHO     j: View java
ECHO     h: Help
ECHO Target: 
ECHO     Project name. (= name of source apk file)
ECHO     IF target is omitted, then ATT will show list of apk files in current directory.
ECHO     Don't use real path of file/directory as target
ECHO     Use project name as target (=name of source apk file)
GOTO END


:SELECT_TARGET2
IF NOT [%2]==[] (
	SET targetapk=%2
	GOTO %CURRENT_WORK%
)
cd "%source_dir%"
set num=0
for %%i in (*.apk) do (
	set /a num=num+1
	set flist[!num!]=%%i
	echo [!num!] : %%i
)
if "%num%"=="0" (
	ECHO [ATT] No target file...
	GOTO END
)
ECHO.
SET /p str=[ATT] Select Apk file : 
IF %str% gtr %num% (
	SET /p str=[ATT] Cancel? [y/n]: 
	IF !str!==y (GOTO END) ELSE (GOTO SELECT_TARGET)
)
SET targetapk=!flist[%str%]!
cd "%current_dir%"
GOTO %CURRENT_WORK%


:PULL_APPDIR
REM /////////////////////// PULL_APPDIR /////////////////////////////////
SET CURRENT_WORK=PULL_APPDIR_2
GOTO ADB_CONNECT_TEST
:PULL_APPDIR_2
SET CURRENT_WORK=PULL_APPDIR_3
GOTO ADB_ROOT_TEST
:PULL_APPDIR_3
SET CURRENT_WORK=PULL_APPDIR_4
GOTO SELECT_TARGET2
:PULL_APPDIR_4
IF not exist "%output_dir%\%targetapk%\APPDIR_files" (
	mkdir "%output_dir%\%targetapk%\APPDIR_files"
)
echo [+] Wait.....

set appdir=/data/data/%targetapk:~0,-4%
adb shell "ls -R %appdir%" | findstr ":" > dirlist.txt

REM [참고사항]
REM 1. adb shell에서 받은 문자열은 리눅스 스트링이므로 행 끝에 CR이 붙어서 나중에 문제를 일으킴.
REM    따라서 므로 마지막 글자를 잘라주어야함 (--> !tmpstr:~0,-1!)
REM 2. android 파일명에 공백이 있는 경우 for문의 token 처리에서 문제가 발생 - error.log에 로깅
for /f "tokens=1,2 delims=:" %%a in (dirlist.txt) do (
	adb shell "ls -al %%a | grep ^-"> sub_filelist.txt
	for /f "tokens=1,2,3,4,5,6,7,8 delims= " %%i in (sub_filelist.txt) do (
		if [%%o]==[] (
			echo [Error: can't read Directory, Check manually] %%a>> .[ATT_log_error].txt
			echo [Error: can't read Directory, Check manually] !tmpstr!>> .[ATT_log_filelist].txt
		) else (
			set tmpstr=%%a/%%o
			if [%%p]==[] (
				echo !tmpstr:~0,-1!>> .[ATT_log_filelist].txt
			) else (
				echo [Error: can't read File, Check manually] !tmpstr!>> .[ATT_log_filelist].txt
				echo [Error: can't read File, Check manually] !tmpstr!>> .[ATT_log_error].txt
			)
		)
	)
)

for /f "tokens=1* delims=" %%t in (.[ATT_log_filelist].txt) do (
	set tmpstr=%%t
	if not "!tmpstr:~0,1!"=="[" (
		adb pull %%t "%output_dir%"\%targetapk%\APPDIR_files\
	)
)
del dirlist.txt
del sub_filelist.txt
move .[ATT_log_filelist].txt "%output_dir%\%targetapk%\APPDIR_files\"
if exist .[ATT_log_error].txt (
	move .[ATT_log_error].txt "%output_dir%\%targetapk%\APPDIR_files\"
	echo.
	echo [ATT] Complete.
	echo [ATT] Some error was found.
	echo [ATT] Check log : %output_dir%\%targetapk%\APPDIR_files\.[ATT_log_error].txt
)
GOTO END


:ERROR1
ECHO.
ECHO [ATT] Error occured...


:END
IF %mode%==menustyle (
	ECHO.
	SET /p str=[ATT] Press any key to continue....
	SET str=
	SET workno=
	GOTO MENU
)
IF %mode%==linestyle GOTO QUIT


:QUIT
IF EXIST null del null
SET str=
ECHO.

