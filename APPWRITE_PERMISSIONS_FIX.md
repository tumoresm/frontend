# FieldForce Appwrite Permissions Fix

## Problem Description

Users were experiencing authentication issues where they could sign in successfully but encountered `user_unauthorized` (401) errors when the system tried to create missing user documents in the database.

### Error Symptoms:
- User authentication succeeds
- System detects missing user document in database
- Attempt to create missing document fails with "user_unauthorized" error
- User cannot access the application properly

## Root Cause

The issue was caused by insufficient permissions in the Appwrite users collection. When a user document was missing from the database (which can happen if the signup process was interrupted or failed), the system attempted to create the missing document using the user's own session. However, the users collection didn't have the proper permissions configured to allow users to create their own documents.

## Solution Implemented

### 1. Enhanced Document Creation with Secure Client

Modified the `_createMissingUserDocument` function in `auth_controller.dart` to:

- Use the `SecureAppwriteClient` which handles permissions properly
- Set explicit permissions for user documents
- Implement a fallback mechanism if the secure client fails
- Provide detailed error logging for debugging

### 2. Proper Permission Configuration

The fix implements proper document-level permissions:

```dart
final permissions = [
  Permission.read(Role.user(currentUser.$id)),      // User can read their own document
  Permission.update(Role.user(currentUser.$id)),    // User can update their own document
  Permission.delete(Role.user(currentUser.$id)),    // User can delete their own document
  Permission.read(Role.users()),                    // Other authenticated users can read basic info
];
```

### 3. Fallback Mechanism

If the secure client approach fails, the system falls back to the basic client approach and provides detailed error messages to help with debugging.

## Required Appwrite Configuration

To fully resolve this issue, you need to configure the proper permissions in your Appwrite console:

### 1. Database Collection Permissions

Navigate to: **Appwrite Console → Database → fieldforce_db → users collection → Settings → Permissions**

#### Required Collection-Level Permissions:

**Create Permissions:**
- Add: `users` (allows any authenticated user to create documents)
- OR: `user:*` (allows users to create documents for themselves)

**Read Permissions:**
- Add: `users` (allows authenticated users to read user documents)

**Update Permissions:**
- Add: `user:*` (allows users to update their own documents)

**Delete Permissions:**
- Add: `user:*` (allows users to delete their own documents)

### 2. Document-Level Permissions

The code now automatically sets proper document-level permissions when creating user documents:

- **Read**: User can read their own document + other authenticated users can read basic info
- **Update**: Only the user can update their own document
- **Delete**: Only the user can delete their own document

## Testing the Fix

### 1. Test Missing Document Creation

1. Create a user account in Appwrite Auth (without a corresponding database document)
2. Try to sign in with that user
3. The system should automatically create the missing user document
4. User should be able to access the application normally

### 2. Test Normal Flow

1. Create a new user account through the app's signup process
2. Verify that the user document is created during signup
3. Sign out and sign back in
4. Verify that no missing document creation is needed

### 3. Monitor Logs

The enhanced logging will show:
- When missing documents are detected
- Whether secure client or fallback method is used
- Success/failure of document creation
- Specific permission errors if they occur

## Error Messages and Troubleshooting

### If you still see "user_unauthorized" errors:

1. **Check Collection Permissions**: Ensure the users collection has `users` or `user:*` in the Create permissions
2. **Check Project Settings**: Verify that your Appwrite project allows user registration
3. **Check API Keys**: Ensure your app is using the correct project ID and endpoint
4. **Check Network**: Verify that your app can reach the Appwrite server

### If document creation succeeds but data is missing:

1. **Check Required Fields**: Ensure all required fields in your UserModel are being set
2. **Check Data Types**: Verify that the data types match your collection schema
3. **Check Validation Rules**: Ensure your collection doesn't have validation rules that prevent document creation

## Additional Improvements

### 1. Enhanced Error Handling

The fix includes comprehensive error handling that:
- Logs specific error types for easier debugging
- Provides helpful error messages for common issues
- Implements graceful fallbacks

### 2. Secure Permission Management

The `SecureAppwriteClient` provides:
- Automatic permission setting based on collection type
- User context management
- Security validation for document access

### 3. Better Logging

Enhanced logging helps with:
- Debugging permission issues
- Monitoring document creation success/failure
- Understanding user authentication flow

## Prevention

To prevent this issue in the future:

1. **Ensure Robust Signup**: Make sure the signup process always creates user documents successfully
2. **Monitor Collection Permissions**: Regularly check that collection permissions are properly configured
3. **Implement Health Checks**: Add periodic checks to ensure user documents exist for authenticated users
4. **Use Transactions**: Consider using Appwrite Functions for atomic user creation operations

## Files Modified

- `lib/features/auth/controller/auth_controller.dart`: Enhanced missing document creation with secure client and fallback
- `APPWRITE_PERMISSIONS_FIX.md`: This documentation file

## Dependencies

The fix uses the existing `SecureAppwriteClient` from:
- `lib/core/secure_client.dart`
- `lib/core/secure_providers.dart`

No additional dependencies were added.