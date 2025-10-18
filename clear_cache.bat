@echo off
echo Clearing Flutter and Gradle caches...

echo.
echo 1. Stopping Gradle daemon...
cd android
call gradlew --stop
cd ..

echo.
echo 2. Clearing Flutter cache...
call flutter clean

echo.
echo 3. Clearing Gradle cache...
rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\wrapper" 2>nul

echo.
echo 4. Clearing Android build cache...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "build" 2>nul

echo.
echo 5. Getting Flutter dependencies...
call flutter pub get

echo.
echo 6. Rebuilding project...
call flutter build apk --debug

echo.
echo Cache clearing and rebuild complete!
pause