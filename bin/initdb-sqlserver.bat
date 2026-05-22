@echo off
REM Initialize Davinci system database on SQL Server (requires sqlcmd in PATH)
setlocal
if "%DAVINCI3_HOME%"=="" (
  echo DAVINCI3_HOME is not set
  exit /b 1
)
set SERVER=localhost
set DB=davinci
set USER=sa
set PASS=your_password
sqlcmd -S %SERVER% -U %USER% -P %PASS% -Q "IF DB_ID('%DB%') IS NULL CREATE DATABASE [%DB%]"
sqlcmd -S %SERVER% -U %USER% -P %PASS% -d %DB% -i "%DAVINCI3_HOME%\bin\davinci.sqlserver.sql"
endlocal
