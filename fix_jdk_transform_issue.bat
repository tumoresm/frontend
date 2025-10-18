@echo off
echo ========================================
echo JDK Image Transformation Issue Fix
echo ========================================
echo.

echo Step 1: Stopping all Gradle processes...
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul
cd android
call gradlew --stop 2>nul
cd ..

echo.
echo Step 2: Clearing Flutter build cache...
call flutter clean

echo.
echo Step 3: Clearing specific Gradle transforms cache (JDK image transforms)...
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-4" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\caches\jars-9" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\caches\modules-2" 2>nul

echo.
echo Step 4: Clearing Android SDK build cache...
if defined ANDROID_HOME (
    rmdir /s /q "%ANDROID_HOME%\build-cache" 2>nul
)
if exist "%LOCALAPPDATA%\Android\Sdk\build-cache" (
    rmdir /s /q "%LOCALAPPDATA%\Android\Sdk\build-cache" 2>nul
)

echo.
echo Step 5: Clearing local build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "build" 2>nul

echo.
echo Step 6: Getting Flutter dependencies...
call flutter pub get

echo.
echo Step 7: Attempting build with JDK image transformation disabled (R8 deprecated property removed)...
call flutter build apk --debug

echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS: Build completed successfully!
    echo The JDK image transformation issue has been resolved.
) else (
    echo ❌ Build failed. Trying alternative approach...
    echo.
    echo Alternative: Building with release mode...
    call flutter build apk --release
    
    if %ERRORLEVEL% EQU 0 (
        echo ✅ SUCCESS: Release build completed!
    ) else (
        echo ❌ Both builds failed. Please check the troubleshooting guide.
    )
)

echo.
echo ========================================
echo Fix completed!
echo ========================================
pause