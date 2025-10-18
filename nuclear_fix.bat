@echo off
echo NUCLEAR FIX: Completely clearing all caches and using stable build configuration...

echo.
echo Step 1: Killing all Java/Gradle processes...
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul
taskkill /f /im gradle.exe 2>nul

echo.
echo Step 2: Stopping Gradle daemon...
cd android
call gradlew --stop 2>nul
cd ..

echo.
echo Step 3: Clearing Flutter cache completely...
call flutter clean

echo.
echo Step 4: Clearing ALL Gradle caches...
rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\wrapper" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\daemon" 2>nul

echo.
echo Step 5: Clearing Android SDK caches...
rmdir /s /q "%ANDROID_HOME%\build-cache" 2>nul
rmdir /s /q "%LOCALAPPDATA%\Android\Sdk\build-cache" 2>nul

echo.
echo Step 6: Clearing all local build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "android\.gradle" 2>nul
rmdir /s /q "build" 2>nul
rmdir /s /q ".dart_tool" 2>nul

echo.
echo Step 7: Clearing temporary directories...
rmdir /s /q "%TEMP%\flutter_tools*" 2>nul
rmdir /s /q "%TEMP%\gradle*" 2>nul

echo.
echo Step 8: Getting dependencies with clean slate...
call flutter pub get

echo.
echo Step 9: Building with stable AGP 7.3.1 configuration...
call flutter build apk --debug

echo.
echo NUCLEAR FIX COMPLETE!
echo If this doesn't work, the issue might be with your JDK installation.
echo Try installing JDK 8 or JDK 11 and setting JAVA_HOME properly.
pause