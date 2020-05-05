@echo off

whoami /PRIV | find "SeLoadDriverPrivilege" >NUL
if not errorlevel 1 goto start

@echo runas
powershell.exe -Command Start-Process "%0" -Verb Runas
rem runas /user:administrator %0
goto :EOF

:start
echo Uninstalling MSVC integration...
cd /d %~dp0

for %%p in (x64 Win32) do (
	echo %%p
	call :platform %%p
	if errorlevel 1 goto failed
)

setx IWYUCL_ROOT ""
@echo Done!
:end
goto :EOF

:failed
echo MSVC integration uninstall failed.
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
if exist %D% call :uninstall
SET D="%ProgramFiles(x86)%\MSBuild\Microsoft.Cpp\v4.0\%1\Platforms\%PLATFORM%\PlatformToolsets"
if exist %D% call :uninstall
exit /b 0

:vswhere
for /f "tokens=*" %%x in ( 'vswhere.bat -version %1 -requires Microsoft.Component.MSBuild -find MSBuild\**\%PLATFORM%\PlatformToolsets' ) do (
	if exist %%x call :vswhere_uninstall "%%x"
)
exit /b 0

:vswhere_uninstall
SET D=%1
goto uninstall

:uninstall
echo uninstall to %D% ...
if exist %D%\Include-What-You-Use\toolset.props   del %D%\Include-What-You-Use\toolset.props
if exist %D%\Include-What-You-Use\toolset.targets del %D%\Include-What-You-Use\toolset.targets
if exist %D%\Include-What-You-Use\Microsoft.Cpp.Win32.Include-What-You-Use.props   del %D%\Include-What-You-Use\Microsoft.Cpp.Win32.Include-What-You-Use.props
if exist %D%\Include-What-You-Use\Microsoft.Cpp.Win32.Include-What-You-Use.targets del %D%\Include-What-You-Use\Microsoft.Cpp.Win32.Include-What-You-Use.targets
if exist %D%\Include-What-You-Use rmdir %D%\Include-What-You-Use

exit /b 0
