@echo off
echo ========================================
echo ROLLING BACK TO BEFORE GOOGLE MAPS INTEGRATION
echo ========================================
echo.

echo TARGET COMMIT: 6d4571c2d269a6ba7de2a92e8d28036c1de664dd
echo COMMIT MESSAGE: "fix: Add missing logoutEndpoint to ApiConstants"
echo DATE: Thu Aug 21 04:54:54 2025 +0200
echo.

echo This will remove:
echo - Google Maps Flutter integration
echo - Geolocator package
echo - Geocoding package  
echo - Permission handler package
echo - Location picker widget
echo - All Google Maps related Android configurations
echo - Maps API key configurations
echo.

set /p proceed="Proceed with rollback? This will discard all current changes! (y/n): "
if /i "%proceed%" neq "y" exit /b 0

echo.
echo Step 1: Stopping all processes...
taskkill /f /im java.exe 2>nul
taskkill /f /im javaw.exe 2>nul
cd android
call gradlew --stop 2>nul
cd ..

echo.
echo Step 2: Performing hard reset to target commit...
git reset --hard 6d4571c2d269a6ba7de2a92e8d28036c1de664dd

echo.
echo Step 3: Cleaning Flutter cache...
call flutter clean

echo.
echo Step 4: Getting dependencies for rolled back version...
call flutter pub get

echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS! Rolled back to before Google Maps integration
    echo.
    echo WHAT WAS REMOVED:
    echo - google_maps_flutter: ^2.2.8
    echo - geolocator: ^10.1.0
    echo - geocoding: ^2.1.1
    echo - permission_handler: ^11.3.1
    echo - lib/common/widgets/location_picker.dart
    echo - Android Maps API configurations
    echo - Location permissions in AndroidManifest.xml
    echo - Google Maps secrets configuration
    echo.
    echo Your project is now at the state before Google Maps was added.
    echo All Google Maps related code and configurations have been removed.
) else (
    echo ❌ Rollback failed. 
    echo.
    echo You may need to manually resolve any conflicts.
    echo Check git status for more information.
)

echo.
pause