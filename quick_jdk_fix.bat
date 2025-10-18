@echo off
echo ========================================
echo QUICK JDK IMAGE TRANSFORMATION FIX
echo ========================================
echo.

echo This is a quick fix for the JDK image transformation error.
echo If this doesn't work, run fix_jdk_image_transform_error.bat for comprehensive fix.
echo.

echo Step 1: Stopping Gradle processes...
cd android
call gradlew --stop 2>nul
cd ..

echo.
echo Step 2: Clearing specific problematic cache...
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-3" 2>nul

echo.
echo Step 3: Flutter clean...
call flutter clean

echo.
echo Step 4: Rebuilding...
call flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo ✅ Quick fix successful!
) else (
    echo ❌ Quick fix failed. Run fix_jdk_image_transform_error.bat for comprehensive fix.
)

pause