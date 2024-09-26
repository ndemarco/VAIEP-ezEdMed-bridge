@echo off
set errorFlag=0
set errorFile=error_email.txt
set configFile=config.txt
set secretsFile=secrets.txt
set emailEnabled=false

REM Remove any existing error file
if exist %errorFile% del %errorFile%

REM Check if config.txt exists and is readable
if not exist %configFile% (
    echo %DATE% %TIME% Error: %configFile% not found on %COMPUTERNAME% >> %errorFile%
    set errorFlag=1
    goto error
)

REM Check if secrets file exists and is readable
if not exist %secretsFile% (
    echo %DATE% %TIME% Error: %secretsFile% not found on %COMPUTERNAME% >> %errorFile%
    set errorFlag=1
    goto error
)

REM Verify if both WinSCP scripts exist and are readable
if not exist .\scripts\from_PCG.scr (
    echo %DATE% %TIME% Error: from_PCG.scr not found on %COMPUTERNAME% >> %errorFile%
    set errorFlag=1
    goto error
)
if not exist .\scripts\to_InfoHandler.scr (
    echo %DATE% %TIME% Error: to_InfoHandler.scr not found on %COMPUTERNAME% >> %errorFile%
    set errorFlag=1
    goto error
)

REM Load configuration keys and data
for /f "tokens=1,2 delims== " %%i in (%configFile%) do (
    if "%%i"=="email_enabled" set emailEnabled=%%j
    set %%i=%%j
)

REM Load sensitive secrets (SFTP and email server credentials)
for /f "tokens=1,2 delims== " %%i in (%secretsFile%) do set %%i=%%j

REM Set environment variables for SCP and SFTP URLs
set download_URL=%PCG_SCP_URL%
set upload_URL=%InfoHandler_SFTP_URL%

REM Check if 7z is installed and on the PATH
where 7z >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %DATE% %TIME% Error: 7z is not installed or not on the system PATH >> %errorFile%
    set errorFlag=1
    goto error
)

REM Download files from PCG using from_PCG.scr to 
"WinSCP.exe" /log="WinSCP_fromPCG.log" /ini=nul /command "open scp://%download_URL%" /script=".\scripts\from_PCG.scr"
if %ERRORLEVEL% neq 0 (
    echo %DATE% %TIME% Error: WinSCP download from PCG failed >> %errorFile%
    set errorFlag=1
    goto error
)

TODO: Verify this will check that some data was downloaded from PCG. We're looking for a .zip file.
REM Verify if download data exists and is readable
if not exist .\downloads\* (
    echo %DATE% %TIME% Error: from_PCG.scr not found on %COMPUTERNAME% >> %errorFile%
    set errorFlag=1
    goto error
)

REM Extract the ZIP files from .\downloads to .\reports
7z e .\downloads\*.zip -o.\reports\
if %ERRORLEVEL% neq 0 (
    echo %DATE% %TIME% Error: 7z extraction failed in .\reports directory >> %errorFile%
    set errorFlag=1
    goto error
)

REM Clean up ZIP files after extraction
del .\downloads\*.*
TODO: Remove any subfolders also

REM Remove any .xls file with 'services' in the filename in the reports directory
for %%f in (.\reports\*.xls) do (
    echo %%f | find /i "services" >nul
    if not errorlevel 1 del "%%f"
)

REM Use to_InfoHandler.scr to upload files to InfoHandler
"WinSCP.exe" /log="WinSCP_toInfoHandler.log" /ini=nul /script=".\scripts\to_InfoHandler.scr"
if %ERRORLEVEL% neq 0 (
    echo %DATE% %TIME% Error: WinSCP upload to InfoHandler failed >> %errorFile%
    set errorFlag=1
    goto error
)

REM Handle success email or console echo
if /i "%emailEnabled%"=="true" (
    sendmail.exe -t < mail_success.txt
) else (
    echo Test mode: No emails will be sent:
    echo To: %email_to%
    echo From: %email_from%
    echo Subject: SUCCESS: VAIEP->InfoHandler upload
    echo The VAIEP -> InfoHandler upload was successful.
)

goto end

:error
REM Handle error email or console echo
if /i "%emailEnabled%"=="true" (
    sendmail.exe -t -a %errorFile% < mail_error.txt
) else (
    echo Test mode. No emails will be sent: 
    echo To: %email_to%
    echo From: %email_from%
    echo Subject: FAIL: VAIEP->InfoHandler upload
    echo An error occurred during the VAIEP -> InfoHandler upload. Please check the logs.
    echo Error file: %errorFile%
)

:end
exit /b 0
