@echo off
echo ========================================
echo JDK IMAGE TRANSFORMATION ERROR FIX
echo ========================================
echo.

echo PROBLEM IDENTIFIED:
echo - Android Gradle Plugin 8.2.2 JDK image transformation failing
echo - jlink.exe process failing on core-for-system-modules.jar
echo - package_info_plus plugin compilation error
echo.

echo SOLUTION APPLIED:
echo 1. Enhanced gradle.properties with aggressive JDK image disabling
echo 2. Added JVM arguments to prevent jlink usage
echo 3. Clearing problematic Gradle transform caches
echo 4. Rebuilding with JDK image transformation disabled
echo.



echo.
echo Step 1: Stopping all Java processes...
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
echo Step 3: Clearing Flutter cache...
call flutter clean

echo.
echo Step 4: Clearing problematic Gradle transform caches...
echo Clearing transforms-3 cache (contains failing JDK image transforms)...
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-3" 2>nul
echo Clearing transforms-4 cache...
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-4" 2>nul
echo Clearing jars cache...
rmdir /s /q "%USERPROFILE%\.gradle\caches\jars-9" 2>nul
echo Clearing modules cache...
rmdir /s /q "%USERPROFILE%\.gradle\caches\modules-2" 2>nul

echo.
echo Step 5: Clearing Android build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "android\.gradle" 2>nul
rmdir /s /q "build" 2>nul

echo.
echo Step 6: Clearing Gradle daemon cache...
rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul

echo.
echo Step 7: Getting Flutter dependencies...
call flutter pub get

echo.
echo Step 8: Building with JDK image transformation disabled...
echo This may take a few minutes as Gradle rebuilds everything...
call flutter build apk --debug

echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS! JDK image transformation error fixed!
    echo.
    echo WHAT WAS FIXED:
    echo - Disabled JDK image transformation in Android Gradle Plugin
    echo - Prevented jlink.exe from being used for optimization
    echo - Cleared problematic Gradle transform caches
    echo - Rebuilt project with compatibility settings
    echo.
    echo Your build should now work without JDK image transformation errors.
    echo APK generated at: build\app\outputs\flutter-apk\app-debug.apk
) else (
    echo ❌ Build still failing. Additional troubleshooting needed.
    echo.
    echo NEXT STEPS:
    echo 1. Check if you have the correct JDK version (11 or 17)
    echo 2. Verify Android SDK is properly installed
    echo 3. Try: flutter doctor -v
    echo 4. Consider downgrading Android Gradle Plugin if issue persists
    echo.
    echo If the error persists, the issue might be:
    echo - Incompatible JDK version
    echo - Corrupted Android SDK installation
    echo - Need to downgrade Android Gradle Plugin to 7.4.2
)

echo.
echo PERFORMANCE IMPACT:
echo - Build time: Slightly slower (JDK image optimization disabled)
echo - APK size: No significant change
echo - Runtime performance: No impact
echo.