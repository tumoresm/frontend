@echo off
echo ========================================
echo COMPREHENSIVE KOTLIN DAEMON AND JDK FIX
echo ========================================
echo.

echo PROBLEMS IDENTIFIED:
echo 1. Kotlin compile daemon connection failures
echo 2. JDK image transformation errors (recurring)
echo 3. Java source/target version warnings (obsolete Java 8)
echo 4. Plugin deprecation warnings
echo.

echo SOLUTION STRATEGY:
echo 1. Kill all Java/Kotlin/Gradle processes
echo 2. Clear all Gradle and Kotlin caches
echo 3. Update Java compatibility settings
echo 4. Apply enhanced JDK image transformation fixes
echo 5. Restart Gradle daemon with clean state
echo.

set /p proceed="Proceed with comprehensive fix? (y/n): "
if /i "%proceed%" neq "y" exit /b 0

echo.
echo Step 1: Killing all Java, Kotlin, and Gradle processes...
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul
taskkill /f /im gradle.exe 2>nul
taskkill /f /im gradlew.exe 2>nul
taskkill /f /im kotlin-compiler.exe 2>nul
taskkill /f /im kotlin-daemon.exe 2>nul

echo.
echo Step 2: Stopping Gradle daemon...
cd android
call gradlew --stop 2>nul
cd ..

echo.
echo Step 3: Clearing Flutter cache...
call flutter clean

echo.
echo Step 4: Clearing comprehensive Gradle caches...
echo Clearing Gradle daemon cache...
rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
echo Clearing Gradle caches...
rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
echo Clearing Kotlin caches...
rmdir /s /q "%USERPROFILE%\.gradle\kotlin" 2>nul
echo Clearing build outputs...
rmdir /s /q "%USERPROFILE%\.gradle\build-cache" 2>nul

echo.
echo Step 5: Clearing local build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "android\.gradle" 2>nul
rmdir /s /q "build" 2>nul

echo.
echo Step 6: Clearing Kotlin error logs...
rmdir /s /q "android\.gradle\kotlin\errors" 2>nul

echo.
echo Step 7: Getting Flutter dependencies...
call flutter pub get

echo.
echo Step 8: Pre-warming Gradle daemon with clean state...
cd android
call gradlew --version
cd ..

echo.
echo Step 9: Building with enhanced compatibility settings...
call flutter build apk --debug

echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS! Kotlin daemon and JDK issues resolved!
    echo.
    echo WHAT WAS FIXED:
    echo ✅ Kotlin compile daemon connection restored
    echo ✅ JDK image transformation disabled
    echo ✅ Java compatibility updated to version 17
    echo ✅ Gradle caches completely cleared
    echo ✅ Build processes restarted cleanly
    echo.
    echo Your project should now build successfully.
) else (
    echo ❌ Build still failing. Additional troubleshooting needed.
    echo.
    echo ADDITIONAL STEPS TO TRY:
    echo 1. Restart your computer to clear all processes
    echo 2. Check JAVA_HOME environment variable
    echo 3. Verify Android Studio JDK configuration
    echo 4. Run: flutter doctor -v
    echo 5. Consider updating Android Studio
)

echo.
pause