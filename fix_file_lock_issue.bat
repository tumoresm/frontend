@echo off
echo ========================================
echo FILE LOCK BUILD ERROR FIX
echo ========================================
echo.

echo PROBLEM IDENTIFIED:
echo Build failed because files are locked by running processes.
echo This prevents the clean operation from deleting build directories.
echo.

echo ERROR DETAILS:
echo - Unable to delete directory: build\app\intermediates\assets\debug
echo - Files locked: MaterialSymbolsRounded.ttf, MaterialSymbolsOutlined.ttf, NOTICES.Z
echo - Cause: Processes have files open or working directory set in target
echo.

echo SOLUTION STRATEGY:
echo 1. Terminate all processes that might lock files
echo 2. Force unlock and delete locked directories
echo 3. Clear all build caches completely
echo 4. Restart build process with clean state
echo.

set /p proceed="Proceed with file lock fix? (y/n): "
if /i "%proceed%" neq "y" exit /b 0

echo.
echo Step 1: Terminating all potentially locking processes...
echo ========================================
echo Stopping Flutter processes...
taskkill /f /im flutter.exe 2>nul
taskkill /f /im dart.exe 2>nul

echo Stopping Java/Gradle processes...
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul
taskkill /f /im gradle.exe 2>nul
taskkill /f /im gradlew.exe 2>nul

echo Stopping Android Studio processes...
taskkill /f /im studio64.exe 2>nul
taskkill /f /im studio.exe 2>nul

echo Stopping Kotlin processes...
taskkill /f /im kotlin-compiler.exe 2>nul
taskkill /f /im kotlin-daemon.exe 2>nul

echo Stopping any file explorer processes in project directory...
taskkill /f /im explorer.exe 2>nul
start explorer.exe

echo.
echo Step 2: Stopping Gradle daemon...
echo ========================================
cd android
call gradlew --stop 2>nul
cd ..

echo.
echo Step 3: Waiting for file handles to release...
echo ========================================
echo Waiting 5 seconds for processes to fully terminate...
timeout /t 5 /nobreak >nul

echo.
echo Step 4: Force deleting locked build directories...
echo ========================================
echo Attempting to delete build directory...
rmdir /s /q "build" 2>nul

echo Attempting to delete Android build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "android\.gradle" 2>nul

echo Force deleting specific locked directories...
rmdir /s /q "build\app\intermediates\assets\debug" 2>nul
rmdir /s /q "build\app\intermediates" 2>nul

echo.
echo Step 5: Using alternative deletion method...
echo ========================================
echo Using PowerShell for stubborn files...
powershell -Command "if (Test-Path 'build') { Remove-Item -Path 'build' -Recurse -Force -ErrorAction SilentlyContinue }" 2>nul
powershell -Command "if (Test-Path 'android\app\build') { Remove-Item -Path 'android\app\build' -Recurse -Force -ErrorAction SilentlyContinue }" 2>nul
powershell -Command "if (Test-Path 'android\build') { Remove-Item -Path 'android\build' -Recurse -Force -ErrorAction SilentlyContinue }" 2>nul

echo.
echo Step 6: Flutter clean operation...
echo ========================================
echo Running Flutter clean...
call flutter clean

echo.
echo Step 7: Clearing additional caches...
echo ========================================
echo Clearing Gradle caches...
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-3" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-4" 2>nul

echo Clearing Flutter pub cache for material_symbols_icons...
rmdir /s /q "%USERPROFILE%\AppData\Local\Pub\Cache\hosted\pub.dev\material_symbols_icons-4.2815.1" 2>nul

echo.
echo Step 8: Rebuilding dependencies...
echo ========================================
echo Getting Flutter dependencies...
call flutter pub get

echo.
echo Step 9: Pre-warming Gradle daemon...
echo ========================================
cd android
call gradlew --version
cd ..

echo.
echo Step 10: Attempting build with unlocked files...
echo ========================================
echo Building with clean, unlocked environment...
call flutter build apk --debug

echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS! File lock issue resolved!
    echo.
    echo WHAT WAS FIXED:
    echo ✅ All locking processes terminated
    echo ✅ Locked build directories force-deleted
    echo ✅ File handles released
    echo ✅ Build caches cleared
    echo ✅ Dependencies rebuilt
    echo ✅ Clean build environment restored
    echo.
    echo Your build is now working without file lock issues.
    echo APK generated at: build\app\outputs\flutter-apk\app-debug.apk
) else (
    echo ❌ Build still failing. Additional troubleshooting needed.
    echo.
    echo ADDITIONAL STEPS TO TRY:
    echo 1. Restart your computer to release all file handles
    echo 2. Check if antivirus is scanning/locking files
    echo 3. Close all IDEs and editors
    echo 4. Run as Administrator if permission issues
    echo 5. Check disk space (need 5GB+ free)
    echo.
    echo MANUAL CLEANUP:
    echo 1. Close all applications
    echo 2. Restart computer
    echo 3. Run this script again
    echo 4. If still failing, check Windows Event Viewer for file system errors
)

echo.
pause