@echo off
echo ========================================
echo COMPLETING GOOGLE MAPS ROLLBACK
echo ========================================
echo.

echo Step 1: Stopping all processes...
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul
cd android
call gradlew --stop 2>nul
cd ..

echo.
echo Step 2: Cleaning Flutter cache...
call flutter clean

echo.
echo Step 3: Getting dependencies for rolled back version...
call flutter pub get

echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS! Google Maps rollback completed successfully!
    echo.
    echo WHAT WAS REMOVED:
    echo - google_maps_flutter: ^2.2.8
    echo - geolocator: ^10.1.0  
    echo - geocoding: ^2.1.1
    echo - permission_handler: ^11.3.1
    echo - mime: ^1.0.5
    echo - lib/common/widgets/location_picker.dart
    echo - Android Maps API configurations
    echo - Location permissions in AndroidManifest.xml
    echo - Google Maps secrets configuration files
    echo - Maps API key metadata
    echo.
    echo Your project is now at the state before Google Maps integration.
    echo All Google Maps related code and configurations have been removed.
    echo.
    echo You can now build your project without Google Maps dependencies.
) else (
    echo ❌ Rollback completion failed.
    echo.
    echo Please check for any remaining dependency issues.
    echo Run: flutter doctor -v
)

echo.
pause