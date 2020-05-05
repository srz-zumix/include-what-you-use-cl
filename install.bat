@echo off

where include-what-you-use.exe >NUL 2>NUL
if errorlevel 1 (
	@echo please set PATH include-what-you-use
	goto failed
)

if not exist %~dp0\cl.exe call :build
if errorlevel 1 goto failed

whoami /PRIV 2>NUL | find "SeLoadDriverPrivilege" >NUL 2>NUL
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
	echo %%p
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
for %%v in (V140 V120 V110) do (
	call :vs %%v
	if errorlevel 1 exit /b 1
)
for %%v in ("[16.0,17.0)" "[15.0,16.0)") do (
	call :vswhere %%v
	if errorlevel 1 exit /b 1
)
exit /b 0

:vs
SET D="%ProgramFiles%\MSBuild\Microsoft.Cpp\v4.0\%1\Platforms\%PLATFORM%\PlatformToolsets"
if exist %D% call :install %1
SET D="%ProgramFiles(x86)%\MSBuild\Microsoft.Cpp\v4.0\%1\Platforms\%PLATFORM%\PlatformToolsets"
if exist %D% call :install %1
exit /b 0

:vswhere
for /f "tokens=*" %%x in ( 'vswhere.bat -version %1 -requires Microsoft.Component.MSBuild -find MSBuild\**\%PLATFORM%\PlatformToolsets' ) do (
	if exist %%x call :vswhere_install "%%x" %1
)
exit /b 0

:vswhere_install
SET D=%1
call :install %2

:install
echo install to %D% ...
if not exist %D%\Include-What-You-Use mkdir %D%\Include-What-You-Use
SET FNAME_=toolset
if exist toolset\%PLATFORM%\%FNAME_%-%1.props (
	copy toolset\%PLATFORM%\%FNAME_%-%1.props %D%\Include-What-You-Use\%FNAME_%.props
	if errorlevel 1 exit /b 1
	copy toolset\%PLATFORM%\%FNAME_%-%1.targets %D%\Include-What-You-Use\%FNAME_%.targets
	if errorlevel 1 exit /b 1
)
SET FNAME_=Microsoft.Cpp.Win32.Include-What-You-Use
if exist toolset\%PLATFORM%\%FNAME_%-%1.props (
	copy toolset\%PLATFORM%\%FNAME_%-%1.props %D%\Include-What-You-Use\%FNAME_%.props
	if errorlevel 1 exit /b 1
	copy toolset\%PLATFORM%\%FNAME_%-%1.targets %D%\Include-What-You-Use\%FNAME_%.targets
	if errorlevel 1 exit /b 1
)
exit /b 0

:build
call %~dp0\build.bat
goto :EOF
