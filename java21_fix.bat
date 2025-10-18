@echo off
echo Fixing Java 21 compatibility with Gradle...

echo.
echo Step 1: Checking Java version...
java -version

echo.
echo Step 2: Stopping Gradle daemon...
cd android
call gradlew --stop
cd ..

echo.
echo Step 3: Clearing Flutter cache...
call flutter clean

echo.
echo Step 4: Clearing Gradle caches for Java 21 compatibility...
rmdir /s /q "%USERPROFILE%\.gradle\caches\7.5" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\caches\8.4" 2>nul
rmdir /s /q "%USERPROFILE%\.gradle\wrapper\dists\gradle-7.5-bin" 2>nul

echo.
echo Step 5: Clearing local build directories...
rmdir /s /q "android\app\build" 2>nul
rmdir /s /q "android\build" 2>nul
rmdir /s /q "build" 2>nul

echo.
echo Step 6: Getting dependencies with Java 21 + Gradle 8.4...
call flutter pub get

echo.
echo Step 7: Building with Java 21 compatible configuration...
call flutter build apk --debug

echo.
echo Java 21 compatibility fix complete!
echo Configuration: Gradle 8.4 + AGP 8.1.4 + Java 21
pause