# FieldForce Frontend

A Flutter application for freelance field sales representatives, following MVVM architecture.

## Project Structure

- `lib/models/` - Data models (User, Company, Order, etc.)
- `lib/viewmodels/` - ViewModels for MVVM (business logic, state management)
- `lib/views/` - UI screens and widgets
- `lib/services/` - Service classes for API, authentication, etc.
- `lib/utils/` - Utilities and seed/mock data logic
- `lib/mock_data/` - Mock data for development/testing
- `lib/env.dart` - Environment variable access (uses `flutter_dotenv`)
- `lib/app.dart` - App root and routing
- `main.dart` - Entry point (loads env, starts app)

## Environment Variables

Create a `.env` file in the project root with the following keys:

```
APPWRITE_ENDPOINT=your_appwrite_endpoint
APPWRITE_PROJECT_ID=your_appwrite_project_id
APPWRITE_PHONE_AUTH_API=your_phone_auth_api_endpoint
```

Add any other secrets as needed. See `lib/env.dart` for access.

## Authentication
- Phone OTP authentication is scaffolded in `lib/services/auth_service.dart` and `lib/viewmodels/auth_viewmodel.dart`.
- Placeholders for Google and Apple sign-in are commented in the same files.

## Maps Integration
- The order creation view (`lib/views/order_create_view.dart`) includes a placeholder and comments for integrating a map widget (e.g., Google Maps) for location pin and reverse geocoding.

## Mock Data & Seeding
- Mock data is provided in `lib/mock_data/` for companies, users, and orders.
- Use `lib/utils/seed_data.dart` to seed mock data into providers or in-memory stores for development/testing.

## Running the App
1. Install dependencies:
   ```
   flutter pub get
   ```
2. Run the app:
   ```
   flutter run
   ```

## Next Steps
- Implement real API integration with Appwrite in services.
- Build out UI screens in `lib/views/` for onboarding, dashboard, company discovery, order creation, etc.
- Integrate maps and authentication logic as described in the PRD.
