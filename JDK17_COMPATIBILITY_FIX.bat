@echo off
echo ========================================
echo JDK 17 COMPATIBILITY FIX
echo ========================================
echo.

echo Current Java version:
java -version
echo.

echo PROBLEM IDENTIFIED:
echo - JDK 17 requires compatible Gradle and Android Gradle Plugin versions
echo - Your previous configuration was using outdated versions
echo.

echo SOLUTION APPLIED:
echo 1. Upgraded Gradle: 7.6.3 → 8.5 (supports JDK 17)
echo 2. Upgraded Android Gradle Plugin: 7.4.2 → 8.2.2 (compatible with Gradle 8.5)
echo 3. Updated Java target: 8 → 17 (matches your JDK version)
echo 4. Maintained compatibility with Flutter and Android
echo.

echo COMPATIBILITY MATRIX:
echo - JDK 17 ✓
echo - Gradle 8.5 ✓ 
echo - Android Gradle Plugin 8.2.2 ✓
echo - Flutter (latest) ✓
echo.

set /p proceed="Proceed with cache clearing and build? (y/n): "
if /i "%proceed%" neq "y" exit /b 0

echo.
echo Step 1: Stopping all processes...
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul
cd android
call gradlew --stop 2>nul
cd ..

echo.
echo Step 2: Clearing Flutter cache...
call flutter clean

echo.
echo Step 3: Clearing Gradle caches...
rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul

echo.
echo Step 4: Clearing build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "android\.gradle" 2>nul
rmdir /s /q "build" 2>nul

echo.
echo Step 5: Getting dependencies...
call flutter pub get

echo.
echo Step 6: Building with JDK 17 compatible configuration...
call flutter build apk --debug

echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS! Build completed successfully!
    echo.
    echo Your project is now using:
    echo - JDK 17 LTS ✓
    echo - Gradle 8.5 ✓
    echo - Android Gradle Plugin 8.2.2 ✓
    echo - Java target 17 ✓
    echo.
    echo This configuration is stable and recommended for production.
) else (
    echo ❌ Build failed. 
    echo.
    echo Troubleshooting steps:
    echo 1. Verify JDK 17 is properly installed and JAVA_HOME is set
    echo 2. Check that no other JDK versions are interfering
    echo 3. Ensure Android SDK is up to date
    echo 4. Try running: flutter doctor -v
)

echo.
pause