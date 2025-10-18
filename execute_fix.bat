@echo off
echo ========================================
echo EXECUTING JDK IMAGE TRANSFORMATION FIX
echo ========================================
echo.

echo Problem: device_info_plus JDK image transformation error
echo Solution: Clearing caches and rebuilding with disabled JDK image transformation
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

echo.
echo Step 5: Clearing Android build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "android\.gradle" 2>nul
rmdir /s /q "build" 2>nul

echo.
echo Step 6: Getting Flutter dependencies...
call flutter pub get

echo.
echo Step 7: Building with JDK image transformation disabled...
echo This may take a few minutes as Gradle rebuilds everything...
call flutter build apk --debug

echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS! JDK image transformation error fixed!
    echo.
    echo APK generated at: build\app\outputs\flutter-apk\app-debug.apk
) else (
    echo ❌ Build still failing. Trying nuclear fix...
    echo.
    echo Clearing ALL Gradle caches...
    rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
    rmdir /s /q "%USERPROFILE%\.gradle\wrapper" 2>nul
    rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul
    
    echo Getting dependencies again...
    call flutter pub get
    
    echo Trying build again...
    call flutter build apk --debug
    
    if %ERRORLEVEL% EQU 0 (
        echo ✅ SUCCESS after nuclear cache clear!
    ) else (
        echo ❌ Build still failing. Manual intervention needed.
        echo.
        echo Please check:
        echo 1. JDK version: java -version
        echo 2. Flutter doctor: flutter doctor -v
        echo 3. Android SDK installation
    )
)

echo.
echo Fix execution completed!
pause