@echo off
echo ========================================
echo QUICK FILE UNLOCK FIX
echo ========================================
echo.

echo Fixing: Unable to delete directory build\app\intermediates\assets\debug
echo Cause: Files locked by running processes
echo.

echo Step 1: Killing all Flutter/Java processes...
taskkill /f /im flutter.exe 2>nul
taskkill /f /im dart.exe 2>nul
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul
taskkill /f /im gradle.exe 2>nul
taskkill /f /im gradlew.exe 2>nul

echo.
echo Step 2: Stopping Gradle daemon...
cd android
call gradlew --stop 2>nul
cd ..

echo.
echo Step 3: Waiting for file handles to release...
timeout /t 3 /nobreak >nul

echo.
echo Step 4: Force deleting build directory...
rmdir /s /q "build" 2>nul

echo.
echo Step 5: Flutter clean...
call flutter clean

echo.
echo Step 6: Rebuilding...
call flutter pub get
call flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ SUCCESS! File lock issue fixed!
) else (
    echo.
    echo ❌ Still failing. Run the comprehensive fix:
    echo ./fix_file_lock_issue.bat
)

pause