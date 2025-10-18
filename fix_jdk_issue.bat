@echo off
echo Fixing JDK image transformation issue...

echo.
echo Step 1: Stopping Gradle daemon...
cd android
call gradlew --stop
cd ..

echo.
echo Step 2: Clearing Flutter build cache...
call flutter clean

echo.
echo Step 3: Clearing Gradle caches (including JDK transforms)...
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-3" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\caches\jars-9" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\caches\modules-2" 2>nul

echo.
echo Step 4: Clearing Android SDK build cache...
rmdir /s /q "%ANDROID_HOME%\build-cache" 2>nul

echo.
echo Step 5: Clearing local build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "build" 2>nul

echo.
echo Step 6: Getting dependencies...
call flutter pub get

echo.
echo Step 7: Building with stable configuration...
call flutter build apk --debug

echo.
echo Done! The JDK image transformation issue should be resolved.
echo If you still get errors, try running this script again or restart your computer.
pause