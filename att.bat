@ECHO OFF
SETLOCAL enabledelayedexpansion
REM //////////////////////////////////////////////////////////////////////////////
REM ///////////////////// APK Tesing Tool (LIME Security) ////////////////////////
REM /////////////////////////// 2018-08-26 (VER 1.0) /////////////////////////////
REM //////////////////////////////////////////////////////////////////////////////

SET current_dir=%cd%
SET att_dir=%~dp0

REM 라인커맨드인지 or 메뉴 모드인지 확인 후 경로 SET
REM 라인커맨드- 현재 디렉토리에서 작업, 메뉴모드- att 실행 디렉토리에서 작업
:HEAD
IF [%1]==[] (
	SET mode=menustyle
	SET source_dir=%att_dir%\source
	SET output_dir=%att_dir%\output
	SET ext-tools_dir=%att_dir%\ext-tools
	IF NOT EXIST !source_dir! MKDIR !source_dir!
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
IF %1==h SET workno=10
GOTO START

:MENU
mode con:cols=100 lines=1000
CLS
ECHO ------------------------------------------------------------------------------
ECHO                        APK Testing Tool (Lime Security)
ECHO ------------------------------------------------------------------------------
ECHO                            version 1.0 (2018-08-25)
ECHO ------------------------------------------------------------------------------
ECHO (0. Set Target APK - optional)
ECHO.
ECHO 1. Search / Pull APK File
ECHO. 
ECHO 2. Decoding APK                      5. Build APK   
ECHO 3. Decoding APK (no-res option)      6. Sign APK
ECHO 4. View Java (With Jad-gui)          7. Install APK
ECHO.
ECHO 8. Build + Sign + Install APK
ECHO 9. Quit
ECHO -------------------------------------------------------------------------------
SET /p workno=[ATT] SELECT NO: 
GOTO START

:START
IF %workno%==1 GOTO PACKAGES
IF %workno%==2 GOTO SET_TARGET
IF %workno%==3 GOTO SET_TARGET
IF %workno%==4 GOTO SET_TARGET
IF %workno%==5 GOTO SET_TARGET
IF %workno%==6 GOTO SET_TARGET
IF %workno%==7 GOTO SET_TARGET
IF %workno%==8 GOTO SET_TARGET
IF %workno%==9 GOTO QUIT
IF %workno%==10 GOTO HELP
GOTO END

:SET_TARGET
IF %mode%==linestyle (
	IF [%2]==[] (
		GOTO SELECT_TARGET
	) ELSE (
		SET targetapk=%2
		GOTO GO_WORKING
	)		
)
IF %mode%==menustyle (
	GOTO SELECT_TARGET
)

:SELECT_TARGET
ECHO.
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
	SET /p str=[ATT] Cancel and goto Main? [y/n]: 
	IF !str!==y (GOTO END) ELSE (GOTO SELECT_TARGET)
)
SET targetapk=!flist[%str%]!
cd "%current_dir%"
GOTO GO_WORKING

:GO_WORKING
IF %workno%==2 GOTO DECODE
IF %workno%==3 GOTO DECODE_NO_RES
IF %workno%==4 GOTO JAVA_SOURCE
IF %workno%==5 GOTO BUILD
IF %workno%==6 GOTO SIGN
IF %workno%==7 GOTO INSTALL
IF %workno%==8 GOTO INSTALL_2
GOTO END


:PACKAGES
REM /////////////////////// PACKAGES /////////////////////////////////
ECHO.
IF %mode%==linestyle (
	IF [%2]==[] (
		SET /p searchkey=[ATT] Input keyword to search packeages : 
	) ELSE (
		SET searchkey=%2
	)
)
IF %mode%==menustyle (
	SET /p searchkey=[ATT] Input keyword to search packeages : 
)	

SET num=0
ECHO [ATT] Searching packages with keyword '%searchkey%' ....
ECHO.
for /f "tokens=1,2,3 delims=:=" %%i in ('%ext-tools_dir%\sdk-tools\adb shell pm list packages -f') do (
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
)
ECHO.
SET /p str=[ATT] Select Apk file to pull : 
IF %str% gtr %num% (
	SET /p str=[ATT] Cancel and goto Main? [y/n]: 
	IF !str!==y (GOTO END) ELSE (GOTO PACKAGES)
)
SET ori_apk=!pfile[%str%]!
SET new_apk=!pname[%str%]!.apk
%ext-tools_dir%\sdk-tools\adb pull %ori_apk% "%source_dir%\%new_apk%"
ECHO.
ECHO [ATT] Package saved to :
ECHO       %source_dir%\%new_apk%
ECHO         (ref: APK File is saved with package name, Not original apk file name)

:PKG_END
del null
GOTO END


:DECODE
REM //////////////////////// DECODE //////////////////////////////////
REM // CALL로 apktool.bat 를 호출할 경우 -Dfile.encoding=UTF8 세팅으로인해 cmd 창 폰트설정이 리셋되는 문제가 있어 해당 옵션 없이 jar를 직접 실행
REM // 이 경우, apktool 개발자가 원래 UTF8을 가정하고 작성했을 것이므로 나중에 인코딩에서 오류가 발생하는 경우도 존재할 수 있음

SET str=n
IF exist "%output_dir%\%targetapk%\" (
	ECHO [ATT] Old directory is exist. : %output_dir%\%targetapk%\
	SET /p str=[ATT] Overwrite old directory?[y/n] : 
	IF !str!==y (
		ECHO [ATT] Deleting old directory... Please wait.
		rmdir /s /q "%output_dir%\%targetapk%"
	) ELSE (
		GOTO DECODE_END
	)
)
java -jar "%ext-tools_dir%\apktool\apktool.jar" d "%source_dir%"\%targetapk% -o "%output_dir%"\%targetapk%\ -p "%output_dir%"\%targetapk%\framework\
if errorlevel 1 goto ERROR1
ECHO.
ECHO [ATT] Output directory is :
ECHO       %output_dir%\%targetapk%\
:DECODE_END
GOTO END


:DECODE_NO_RES
REM ///////////////// Decode with no-res option //////////////////////

SET str=n
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
ECHO.
ECHO [ATT] Output directory is :
ECHO       %output_dir%\%targetapk%\
:DECODE_NO_RES_END
GOTO END


:BUILD
REM ///////////////////////// BUILD //////////////////////////////////
java -jar "%ext-tools_dir%\apktool\apktool.jar" b "%output_dir%"\%targetapk%\ -p "%output_dir%"\%targetapk%\framework\ --force
if errorlevel 1 goto ERROR1
ECHO.
ECHO [ATT] APK file saved to :
ECHO       %output_dir%\%targetapk%\dist\%targetapk%
GOTO END


:SIGN
REM ///////////////////////// SIGN ///////////////////////////////////
ECHO.
IF EXIST "%output_dir%\%targetapk%\dist\%targetapk%" (
	ECHO [ATT] Signing... Please wait.
	java -jar "%ext-tools_dir%\signapk\signapk.jar" "%ext-tools_dir%\signapk\certificate.pem" "%ext-tools_dir%\signapk\key.pk8" "%output_dir%"\%targetapk%\dist\%targetapk% "%output_dir%"\%targetapk%\dist\signed-%targetapk%
	if errorlevel 1 goto ERROR1
	ECHO [ATT] Signed file saved to :
	ECHO       %output_dir%\%targetapk%\dist\signed-%targetapk%
	GOTO END
) ELSE (
	ECHO.
	ECHO [ATT] No apk file.
	GOTO END
)


:INSTALL
REM //////////////////////// INSTALL /////////////////////////////////
ECHO.
"%ext-tools_dir%\sdk-tools\adb" install -r "%output_dir%"\%targetapk%\dist\signed-%targetapk%
GOTO END


:JAVA_SOURCE
REM /////////////////////// JAVA_SOURCE //////////////////////////////
ECHO.
IF EXIST "%output_dir%\%targetapk%\java\%targetapk%.jar" (
	"%ext-tools_dir%\jd-gui\jd-gui.exe" "%output_dir%\%targetapk%\java\%targetapk%.jar"
) ELSE (
	if exist "%output_dir%"\%targetapk%\build\apk\classes.dex (
		CALL "%ext-tools_dir%\dex2jar-2.0\d2j-dex2jar.bat" "%output_dir%"\%targetapk%\build\apk\classes.dex --force
		if errorlevel 1 goto ERROR1
		mkdir "%output_dir%"\%targetapk%\java"
		move classes-dex2jar.jar "%output_dir%"\%targetapk%\java\%targetapk%.jar
		"%ext-tools_dir%\jd-gui\jd-gui.exe" "%output_dir%"\%targetapk%\java\%targetapk%.jar
	) else (
		ECHO [ATT] There is no classes.dex. You must build apk first.
		SET /p str=[ATT] Do you want build apk?[y/n]: 
		IF !str!==y (
			java -jar "%ext-tools_dir%\apktool\apktool.jar" b "%output_dir%"\%targetapk%\ -p "%output_dir%"\%targetapk%\framework\ --force
			if errorlevel 1 goto ERROR1
			GOTO JAVA_SOURCE
		) ELSE (
			GOTO END
		)
	)
)
ECHO.
ECHO [ATT] Execute jd-gui.exe.
GOTO END

:INSTALL_2
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


:HELP
ECHO APK file Testing Tool v1.0 (2018-08-25)
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


:ERROR1
ECHO.
ECHO [ATT] Error occured...

:END
IF %mode%==menustyle (
	ECHO.
	SET /p str=[ATT] Press any key to continue....
	SET str=
	GOTO MENU
)
IF %mode%==linestyle GOTO QUIT


:QUIT
SET str=
ECHO.

