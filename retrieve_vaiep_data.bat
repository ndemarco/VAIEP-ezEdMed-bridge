for /f "delims=" %%i in (config.txt) do set %%i

REM Download from PCG Education (VA IEP)
"WinSCP.exe" /log="WinSCP.log" /ini=nul /script="SyncScript_1.txt"

if %ERRORLEVEL% neq 0 goto error

REM Extract Zip File(s)
C:
cd C:\Infohandler\Reports
7z e *.zip
del *.zip
del Services_Washington.xls
cd ..
 
REM Upload to Infohandler (EZMed)
"WinSCP.exe" /log="WinSCP.log" /ini=nul /script="SyncScript_2.txt"
 
echo Success
sendmail.exe -t < mail_success.txt
exit /b 0
 
:error
echo Error!
sendmail.exe -t < mail_error.txt
exit /b 1
