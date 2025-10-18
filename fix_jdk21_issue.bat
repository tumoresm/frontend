@echo off
echo ========================================
echo JDK 21 COMPATIBILITY FIX
echo ========================================
echo.
echo ISSUE DETECTED: JDK 21 causing module system errors
echo SOLUTION: Downgrade to JDK 17 for Android compatibility
echo.

echo [1/6] Current Java Version Check...
java -version
echo.
echo JAVA_HOME: %JAVA_HOME%
echo.

echo [2/6] Checking for JDK 17 installation...
if exist "C:\Program Files\Eclipse Adoptium\jdk-17*" (
    echo ✅ JDK 17 found in Eclipse Adoptium folder
    for /d %%i in ("C:\Program Files\Eclipse Adoptium\jdk-17*") do set "JDK17_PATH=%%i"
    echo JDK 17 Path: %JDK17_PATH%
) else (
    echo ❌ JDK 17 not found
    echo.
    echo Please download and install JDK 17 from:
    echo https://adoptium.net/temurin/releases/?version=17
    echo.
    echo After installation, run this script again.
    pause
    exit /b 1
)

echo.
echo [3/6] Setting JAVA_HOME to JDK 17...
set "JAVA_HOME=%JDK17_PATH%"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo New JAVA_HOME: %JAVA_HOME%
echo.

echo [4/6] Verifying JDK 17 is active...
java -version
if %errorlevel% neq 0 (
    echo ❌ Failed to switch to JDK 17
    pause
    exit /b 1
)

echo.
echo [5/6] Clearing all caches...
echo Cleaning Flutter cache...
flutter clean

echo Clearing Gradle cache...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
    echo ✅ Gradle cache cleared
) else (
    echo ⚠️  Gradle cache not found
)

echo Clearing project Gradle cache...
if exist "android\.gradle" (
    rmdir /s /q "android\.gradle"
    echo ✅ Project Gradle cache cleared
) else (
    echo ⚠️  Project Gradle cache not found
)

echo.
echo [6/6] Getting fresh dependencies...
flutter pub get

echo.
echo ========================================
echo JDK 21 FIX COMPLETE
echo ========================================
echo.
echo ✅ Switched from JDK 21 to JDK 17
echo ✅ Cleared all caches
echo ✅ Updated dependencies
echo.
echo NEXT STEPS:
echo 1. Test the build: flutter build apk --debug
echo 2. If successful, the JDK issue is resolved
echo 3. Make JAVA_HOME permanent in system environment variables
echo.

echo To make JAVA_HOME permanent:
echo 1. Open System Properties → Environment Variables
echo 2. Set JAVA_HOME = %JDK17_PATH%
echo 3. Update PATH to include %%JAVA_HOME%%\bin
echo.

echo Testing build now...
echo Running: flutter build apk --debug
echo.

flutter build apk --debug

if %errorlevel% equ 0 (
    echo.
    echo 🎉 SUCCESS! Build completed successfully!
    echo ✅ JDK 21 issue resolved
    echo ✅ APK generated in build\app\outputs\flutter-apk\
) else (
    echo.
    echo ❌ Build still failing
    echo Check the output above for additional errors
    echo You may need to run additional fix scripts
)

echo.
pause