@echo off
setlocal

REM Check for administrative privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%ERRORLEVEL%' NEQ '0' (
    echo This script requires administrative privileges.
    echo Please right-click the script and select 'Run as administrator.'
    exit /b 1
)

REM Set default installation path
set installDir="C:\Program Files\InfoHandler"

REM Allow the user to specify a custom installation path
set /p customPath="Enter installation directory or press Enter to use default (%installDir%): "
if not "%customPath%"=="" set installDir="%customPath%"

echo Installing script to %installDir%...

REM Create the installation directory
if not exist %installDir% mkdir %installDir%

REM Copy all necessary files to the install directory
xcopy /s /i * %installDir%

echo Files copied to %installDir%.

REM Set the path to the batch script that will be scheduled
set scriptPath=%installDir%\RunUpload.bat

REM Check if RunUpload.bat exists in the install directory
if not exist %scriptPath% (
    echo Error: RunUpload.bat not found in %installDir%.
    exit /b 1
)

REM Check if the necessary configuration files are present
if not exist %installDir%\config.txt (
    echo Error: config.txt not found in %installDir%.
    exit /b 1
)
if not exist %installDir%\sendmail.ini (
    echo Error: sendmail.ini not found in %installDir%.
    exit /b 1
)

REM Create a scheduled task to run the script daily
echo Creating a scheduled task to run daily...

schtasks /create /tn "InfoHandlerSyncTask" /tr "%scriptPath%" /sc daily /st 00:30 /f

if %ERRORLEVEL% neq 0 (
    echo Error: Failed to create the scheduled task.
    exit /b 1
)

echo Installation complete. The task will run daily at 12:30 AM.

REM Give the user a prompt to open Task Scheduler if they want to test the task
set /p testTask="Do you want to run the task now to test it? (Y/N): "
if /i "%testTask%"=="Y" (
    echo Running the task now...
    schtasks /run /tn "InfoHandlerSyncTask"
    if %ERRORLEVEL% neq 0 (
        echo Error: Failed to run the task.
        exit /b 1
    )
    echo Task executed successfully.
)

endlocal
exit /b 0
