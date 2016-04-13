@echo off

where msbuild 2>NUL
if errorlevel 1 (
	if defined VS140COMNTOOLS call "%VS140COMNTOOLS%\vsvars32.bat" & goto build
	if defined VS120COMNTOOLS call "%VS120COMNTOOLS%\vsvars32.bat" & goto build
	if defined VS110COMNTOOLS call "%VS110COMNTOOLS%\vsvars32.bat" & goto build
	if defined VS100COMNTOOLS call "%VS100COMNTOOLS%\vsvars32.bat" & goto build
)

:build
msbuild cl.csproj
if errorlevel 1 pause
