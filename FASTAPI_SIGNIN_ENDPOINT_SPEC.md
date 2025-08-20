# FastAPI User Sign-In Endpoint Specification

## Overview
This document specifies the expected FastAPI endpoint for user sign-in that the Flutter client will consume. The client expects specific response formats to properly parse user data and manage authentication sessions.

## Endpoint Details

### **POST** `/auth/login`

**Base URL**: `http://your-host:8000` (configurable via environment variables)

**Full URL**: `http://your-host:8000/auth/login`

---

## Request Specification

### Headers
```http
Content-Type: application/json; charset=UTF-8
Accept: application/json
```

### Request Body
```json
{
  "email": "user@example.com",
  "password": "userPassword123"
}
```

**Request Body Schema:**
- `email` (string, required): User's email address
- `password` (string, required): User's password

---

## Response Specification

### Success Response (HTTP 200)

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "userId": "user_unique_id_123",
    "email": "user@example.com",
    "fullName": "John Doe",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "verificationStatus": "Verified",
    "profile": {
      "phoneNumber": "+1234567890",
      "role": "Rep",
      "address": "123 Main St, City, Country",
      "idNumber": "123456789012",
      "profileImage": "profile_image_url_or_id",
      "selectedAvatar": "avatar_identifier"
    }
  }
}
```

### Error Response (HTTP 400/401/422)

```json
{
  "success": false,
  "message": "Sign-in failed",
  "detail": "Invalid email or password"
}
```

---

## Response Schema Details

### Root Response Object
- `success` (boolean, required): Indicates if the operation was successful
- `message` (string, required): Human-readable message about the operation
- `data` (object, optional): Contains user data when success is true

### SignInData Object (data field)
- `userId` (string, required): Unique identifier for the user
  - **Alternative field names**: `user_id` (snake_case support)
- `email` (string, required): User's email address
- `fullName` (string, required): User's full name
  - **Alternative field names**: `full_name` (snake_case support)
- `accessToken` (string, required): JWT access token for API authentication
  - **Alternative field names**: `access_token` (snake_case support)
- `refreshToken` (string, required): JWT refresh token for token renewal
  - **Alternative field names**: `refresh_token` (snake_case support)
- `verificationStatus` (string, required): User's verification status
  - **Alternative field names**: `verification_status` (snake_case support)
  - **Valid values**: `"Unverified"`, `"Pending"`, `"Verified"`, `"Rejected"`
- `profile` (object, optional): User's profile information

### UserProfile Object (profile field)
- `phoneNumber` (string, optional): User's phone number
  - **Alternative field names**: `phone_number` (snake_case support)
- `role` (string, optional): User's role in the system
  - **Default**: `"Rep"` if not provided
  - **Valid values**: `"Rep"`, `"Admin"`, `"Manager"`, etc.
- `address` (string, optional): User's address
- `idNumber` (string, optional): User's ID number
  - **Alternative field names**: `id_number` (snake_case support)
- `profileImage` (string, optional): URL or identifier for user's profile image
  - **Alternative field names**: `profile_image` (snake_case support)
- `selectedAvatar` (string, optional): Identifier for user's selected avatar
  - **Alternative field names**: `selected_avatar` (snake_case support)

---

## Error Response Formats

The client can handle multiple error response formats:

### Format 1: Simple Detail String
```json
{
  "detail": "Invalid credentials"
}
```

### Format 2: Message Field
```json
{
  "message": "Authentication failed"
}
```

### Format 3: Error Field
```json
{
  "error": "User not found"
}
```

### Format 4: Detailed Error List (FastAPI Validation)
```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

## HTTP Status Codes

- **200 OK**: Successful authentication
- **400 Bad Request**: Invalid request format or missing fields
- **401 Unauthorized**: Invalid credentials
- **422 Unprocessable Entity**: Validation errors
- **500 Internal Server Error**: Server-side errors

---

## Implementation Notes

### 1. Field Name Flexibility
The client supports both camelCase and snake_case field names:
- `userId` or `user_id`
- `fullName` or `full_name`
- `accessToken` or `access_token`
- `refreshToken` or `refresh_token`
- `verificationStatus` or `verification_status`
- `phoneNumber` or `phone_number`
- `idNumber` or `id_number`
- `profileImage` or `profile_image`
- `selectedAvatar` or `selected_avatar`

### 2. Required vs Optional Fields
**Required fields in data object:**
- `userId`
- `email`
- `fullName`
- `accessToken`
- `refreshToken`
- `verificationStatus`

**Optional fields:**
- `profile` (entire object)
- All fields within `profile` object

### 3. Default Values
- `verificationStatus`: Defaults to `"Unverified"` if not provided
- `role`: Defaults to `"Rep"` if not provided in profile

### 4. Token Requirements
- **Access Token**: Should be a valid JWT token for API authentication
- **Refresh Token**: Should be a valid JWT token for token renewal
- Both tokens will be stored securely in the client's session manager

---

## Example FastAPI Implementation

```python
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

class LoginRequest(BaseModel):
    email: str
    password: str

class UserProfile(BaseModel):
    phoneNumber: Optional[str] = None
    role: Optional[str] = "Rep"
    address: Optional[str] = None
    idNumber: Optional[str] = None
    profileImage: Optional[str] = None
    selectedAvatar: Optional[str] = None

class SignInData(BaseModel):
    userId: str
    email: str
    fullName: str
    accessToken: str
    refreshToken: str
    verificationStatus: str = "Unverified"
    profile: Optional[UserProfile] = None

class SignInResponse(BaseModel):
    success: bool
    message: str
    data: Optional[SignInData] = None

@router.post("/auth/login", response_model=SignInResponse)
async def login(request: LoginRequest):
    # Your authentication logic here
    # Validate credentials, generate tokens, fetch user data
    
    if not authenticate_user(request.email, request.password):
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )
    
    user = get_user_by_email(request.email)
    tokens = generate_tokens(user.id)
    
    return SignInResponse(
        success=True,
        message="Login successful",
        data=SignInData(
            userId=user.id,
            email=user.email,
            fullName=user.full_name,
            accessToken=tokens.access_token,
            refreshToken=tokens.refresh_token,
            verificationStatus=user.verification_status,
            profile=UserProfile(
                phoneNumber=user.phone_number,
                role=user.role,
                address=user.address,
                idNumber=user.id_number,
                profileImage=user.profile_image,
                selectedAvatar=user.selected_avatar
            )
        )
    )
```

---

## Client Session Management

After successful sign-in, the client will:

1. **Store tokens securely** using SharedPreferences
2. **Save user data** for offline access
3. **Set authentication headers** for subsequent API calls
4. **Navigate to dashboard** upon successful authentication

The stored session data will be used throughout the app for:
- API authentication via Bearer tokens
- User profile display
- Role-based access control
- Wallet and transaction operations

---

## Security Considerations

1. **HTTPS**: Always use HTTPS in production
2. **Token Expiration**: Implement proper token expiration and refresh logic
3. **Rate Limiting**: Implement rate limiting for login attempts
4. **Input Validation**: Validate all input fields
5. **Error Messages**: Don't expose sensitive information in error messages
6. **Logging**: Log authentication attempts for security monitoring

---

## Testing

### Test Cases to Implement

1. **Valid Credentials**: Test with correct email/password
2. **Invalid Credentials**: Test with wrong email/password
3. **Missing Fields**: Test with missing email or password
4. **Invalid Email Format**: Test with malformed email
5. **Server Errors**: Test error handling for 500 responses
6. **Network Timeouts**: Test timeout handling (30-second timeout)
7. **Token Validation**: Ensure tokens are valid JWTs

### Example Test Requests

```bash
# Valid login
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123"}'

# Invalid credentials
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "wrongpassword"}'
```

This specification ensures that your FastAPI backend will provide exactly what the Flutter client expects for seamless authentication and user session management.