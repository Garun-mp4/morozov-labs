@echo off
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"
set "GRADLE_VERSION=9.3.1"
set "WRAPPER_HOME=%SCRIPT_DIR%.gradle-wrapper"
set "GRADLE_HOME=%WRAPPER_HOME%\gradle-%GRADLE_VERSION%"
set "ZIP=%WRAPPER_HOME%\gradle-%GRADLE_VERSION%-bin.zip"
set "URL=https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip"
if not exist "%GRADLE_HOME%\bin\gradle.bat" (
  if not exist "%WRAPPER_HOME%" mkdir "%WRAPPER_HOME%"
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP%'; Expand-Archive -Path '%ZIP%' -DestinationPath '%WRAPPER_HOME%' -Force; Remove-Item '%ZIP%' -Force"
  if errorlevel 1 exit /b %errorlevel%
)
call "%GRADLE_HOME%\bin\gradle.bat" %*
exit /b %errorlevel%
