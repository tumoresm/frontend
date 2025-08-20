# FastAPI Profile Update Error Fix Guide

## 🚨 **Error Analysis**

The error you encountered indicates two main issues with the FastAPI profile update endpoint:

### **Error Details:**
```json
{
  "detail": [
    {
      "type": "missing",
      "loc": ["header", "X-Appwrite-JWT"],
      "msg": "Field required",
      "input": null
    },
    {
      "type": "dict_type",
      "loc": ["body"],
      "msg": "Input should be a valid dictionary",
      "input": "multipart form data..."
    }
  ]
}
```

## 🔍 **Root Causes**

### **Issue 1: Authentication Header Mismatch**
- **Expected by Server**: `X-Appwrite-JWT` header
- **Sent by Client**: `Authorization: Bearer <token>` header
- **Solution**: Client now sends `X-Appwrite-JWT` header

### **Issue 2: Content Type Mismatch**
- **Expected by Server**: JSON data (`application/json`)
- **Sent by Client**: Multipart form data (`multipart/form-data`)
- **Solution**: Client now uses JSON for data-only updates, multipart only for file uploads

## ✅ **Client-Side Fixes Applied**

### **1. Updated Authentication Headers**
```dart
// Before (Incorrect)
'Authorization': 'Bearer <jwt_token>'

// After (Correct)
'X-Appwrite-JWT': '<jwt_token>'
```

### **2. Smart Content Type Selection**
```dart
// For profile image uploads - Use multipart
if (profileImage != null) {
  final request = http.MultipartRequest('PATCH', Uri.parse(endpoint));
  request.headers.addAll({
    'X-Appwrite-JWT': accessToken,
    'Accept': 'application/json',
  });
  // Add form fields and file
}

// For data-only updates - Use JSON
else {
  final response = await http.patch(
    Uri.parse(endpoint),
    headers: {
      'X-Appwrite-JWT': accessToken,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode(requestBody),
  );
}
```

## 🛠️ **FastAPI Server Requirements**

Your FastAPI server should handle both scenarios:

### **Option 1: JSON-Only Endpoint (Recommended)**
```python
from fastapi import APIRouter, HTTPException, Header, Depends
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

class ProfileUpdateRequest(BaseModel):
    address: str
    idNumber: str
    role: str
    verificationStatus: str = "Pending"

@router.patch("/users/{user_id}")
async def update_profile(
    user_id: str,
    profile_data: ProfileUpdateRequest,
    x_appwrite_jwt: str = Header(..., alias="X-Appwrite-JWT")
):
    # Validate JWT token
    if not validate_jwt_token(x_appwrite_jwt):
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Update user profile
    updated_user = update_user_profile(user_id, profile_data.dict())
    
    return {
        "success": True,
        "message": "Profile updated successfully",
        "data": updated_user
    }
```

### **Option 2: Multipart Support (For File Uploads)**
```python
from fastapi import APIRouter, HTTPException, Header, Form, File, UploadFile
from typing import Optional

@router.patch("/users/{user_id}")
async def update_profile_with_file(
    user_id: str,
    address: str = Form(...),
    idNumber: str = Form(...),
    role: str = Form(...),
    verificationStatus: str = Form(default="Pending"),
    profileImage: Optional[UploadFile] = File(None),
    x_appwrite_jwt: str = Header(..., alias="X-Appwrite-JWT")
):
    # Validate JWT token
    if not validate_jwt_token(x_appwrite_jwt):
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Handle file upload if present
    profile_image_url = None
    if profileImage:
        profile_image_url = await save_profile_image(profileImage)
    
    # Update user profile
    profile_data = {
        "address": address,
        "idNumber": idNumber,
        "role": role,
        "verificationStatus": verificationStatus,
    }
    if profile_image_url:
        profile_data["profileImage"] = profile_image_url
    
    updated_user = update_user_profile(user_id, profile_data)
    
    return {
        "success": True,
        "message": "Profile updated successfully",
        "data": updated_user
    }
```

### **Option 3: Hybrid Endpoint (Handles Both)**
```python
from fastapi import APIRouter, HTTPException, Header, Request
import json

@router.patch("/users/{user_id}")
async def update_profile_hybrid(
    user_id: str,
    request: Request,
    x_appwrite_jwt: str = Header(..., alias="X-Appwrite-JWT")
):
    # Validate JWT token
    if not validate_jwt_token(x_appwrite_jwt):
        raise HTTPException(status_code=401, detail="Invalid token")
    
    content_type = request.headers.get("content-type", "")
    
    if content_type.startswith("application/json"):
        # Handle JSON request
        body = await request.json()
        profile_data = {
            "address": body.get("address"),
            "idNumber": body.get("idNumber"),
            "role": body.get("role"),
            "verificationStatus": body.get("verificationStatus", "Pending"),
        }
    elif content_type.startswith("multipart/form-data"):
        # Handle multipart request
        form = await request.form()
        profile_data = {
            "address": form.get("address"),
            "idNumber": form.get("idNumber"),
            "role": form.get("role"),
            "verificationStatus": form.get("verificationStatus", "Pending"),
        }
        
        # Handle file upload
        if "profileImage" in form:
            profile_image = form["profileImage"]
            profile_data["profileImage"] = await save_profile_image(profile_image)
    else:
        raise HTTPException(status_code=400, detail="Unsupported content type")
    
    # Update user profile
    updated_user = update_user_profile(user_id, profile_data)
    
    return {
        "success": True,
        "message": "Profile updated successfully",
        "data": updated_user
    }
```

## 🔧 **JWT Token Validation Example**
```python
import jwt
from fastapi import HTTPException

def validate_jwt_token(token: str) -> bool:
    try:
        # Replace with your JWT secret and algorithm
        payload = jwt.decode(token, "your-secret-key", algorithms=["HS256"])
        # Add additional validation logic here
        return True
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

## 📋 **Testing the Fix**

### **Test Case 1: Data-Only Update**
```bash
curl -X PATCH "http://localhost:8000/users/123" \
  -H "X-Appwrite-JWT: your-jwt-token" \
  -H "Content-Type: application/json" \
  -d '{
    "address": "123 Main St",
    "idNumber": "1234567890123",
    "role": "Rep",
    "verificationStatus": "Pending"
  }'
```

### **Test Case 2: Update with File**
```bash
curl -X PATCH "http://localhost:8000/users/123" \
  -H "X-Appwrite-JWT: your-jwt-token" \
  -F "address=123 Main St" \
  -F "idNumber=1234567890123" \
  -F "role=Rep" \
  -F "verificationStatus=Pending" \
  -F "profileImage=@profile.jpg"
```

## 🎯 **Expected Response Format**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "userId": "123",
    "address": "123 Main St",
    "idNumber": "1234567890123",
    "role": "Rep",
    "verificationStatus": "Pending",
    "profileImage": "https://example.com/images/profile.jpg"
  }
}
```

## 🚀 **Next Steps**

1. **Update your FastAPI server** to use one of the endpoint implementations above
2. **Ensure JWT validation** is properly implemented
3. **Test both scenarios** (with and without file upload)
4. **Verify the client** now sends correct headers and content types

The client-side fixes have been applied and should now work correctly with a properly configured FastAPI server!