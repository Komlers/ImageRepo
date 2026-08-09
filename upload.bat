@echo off
setlocal enabledelayedexpansion

REM Fetch remote updates
echo Fetching remote updates...
git fetch origin
if errorlevel 1 exit /b %errorlevel%

REM Compare local and remote HEAD
for /f "delims=" %%a in ('git rev-parse HEAD') do set LOCAL=%%a
for /f "delims=" %%a in ('git rev-parse origin/main') do set REMOTE=%%a
if not "%LOCAL%"=="%REMOTE%" (
    echo Local and remote are out of sync. Attempting rebase...
    git rebase origin/main
    if errorlevel 1 (
        echo Rebase conflict detected! Please resolve manually.
        exit /b 1
    )
)

REM Add only newly created files
set NEW_FILES=
for /f "delims=" %%a in ('git ls-files --others --exclude-standard') do set NEW_FILES=!NEW_FILES! "%%a"
if "%NEW_FILES%"=="" (
    echo No new files to add. Exiting.
    exit /b 0
)
git add %NEW_FILES%

REM Commit with timestamp (using PowerShell for formatting)
for /f "delims=" %%a in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"') do set TIMESTAMP=%%a
git commit -m "Auto-add new files on %TIMESTAMP%"
if errorlevel 1 exit /b %errorlevel%

REM Push to remote
git push origin main
if errorlevel 1 exit /b %errorlevel%

echo Push successful!