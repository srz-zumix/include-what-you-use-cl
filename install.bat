@echo off

if not exist %~dp0\cl.exe call :build
if errorlevel 1 goto failed

whoami /PRIV | find "SeLoadDriverPrivilege" >NUL
if not errorlevel 1 goto start

@echo runas
powershell.exe -Command Start-Process "%0" -Verb Runas
rem runas /user:administrator %0
goto :EOF

:start
echo Installing MSVC integration...
cd /d %~dp0

if not exist cl.exe (
	call build.bat
	if errorlevel 1 goto failed
)

for %%p in (x64 Win32) do (
	call :platform %%p
	if errorlevel 1 goto failed
)

setx IWYUCL_ROOT %~dp0
@echo Done!
:end
goto :EOF

:failed
echo MSVC integration install failed.
pause
goto :EOF

:platform
SET PLATFORM=%1
for %%v in (V140) do (
	call :vs %%v
	if errorlevel 1 exit /b 1
)
exit /b 0

:vs
SET D="%ProgramFiles%\MSBuild\Microsoft.Cpp\v4.0\%1\Platforms\%PLATFORM%\PlatformToolsets"
if exist %D% goto install
SET D="%ProgramFiles(x86)%\MSBuild\Microsoft.Cpp\v4.0\%1\Platforms\%PLATFORM%\PlatformToolsets"
if exist %D% goto install
exit /b 1

:install
if not exist %D%\Include-What-You-Use mkdir %D%\Include-What-You-Use
if errorlevel 1 exit /b 1
copy toolset\%PLATFORM%\toolset-%1.props %D%\Include-What-You-Use\toolset.props
if errorlevel 1 exit /b 1
copy toolset\%PLATFORM%\toolset-%1.targets %D%\Include-What-You-Use\toolset.targets
if errorlevel 1 exit /b 1

exit /b 0

:build
call %~dp0\build.bat
goto :EOF
