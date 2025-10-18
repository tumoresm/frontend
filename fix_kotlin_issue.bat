@echo off
echo Fixing Kotlin version compatibility issue...

echo.
echo Step 1: Stopping Gradle daemon...
cd android
call gradlew --stop
cd ..

echo.
echo Step 2: Clearing Flutter build cache...
call flutter clean

echo.
echo Step 3: Clearing Gradle transforms cache (where the error occurs)...
rmdir /s /q "%USERPROFILE%\.gradle\caches\transforms-3" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\caches\modules-2" 2>nul

echo.
echo Step 4: Clearing local build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul

echo.
echo Step 5: Getting dependencies...
call flutter pub get

echo.
echo Step 6: Building project...
call flutter build apk --debug

echo.
echo Done! If the build succeeds, the Kotlin issue is fixed.
pause