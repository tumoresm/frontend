# Profile Completion Data Specification

## 📋 **Data Flow Overview**

The "Complete Your Profile" page (`verification_page.dart`) collects user data and sends it to the FastAPI backend via the `updateUserProfile` method.

## 🔍 **Data Collection (Frontend)**

### **Form Fields Collected:**
1. **Address** (`_addressController.text`)
   - Type: `String`
   - Validation: Required (cannot be empty)
   - Input Type: `TextInputType.streetAddress`
   - Example: `"1925 Derby Ave. Roodepoort, 1734"`

2. **ID Number** (`_idNumberController.text`)
   - Type: `String`
   - Validation: Required + 13-digit format
   - Regex: `r'^\d{13}$'`
   - Input Type: `TextInputType.number`
   - Example: `"0122265320873"`

3. **Role** (`_selectedRole`)
   - Type: `String`
   - Options: `['Rep', 'Admin', 'Manager']`
   - Default: `'Rep'`
   - Validation: Required
   - Example: `"Rep"`

4. **Profile Image** (`_profileImageFile`)
   - Type: `File?` (optional)
   - Source: Image picker (gallery)
   - Format: Image file (jpg, png, etc.)
   - Example: `File('/path/to/image.jpg')` or `null`

5. **User ID** (from session)
   - Type: `String`
   - Source: `currentUserDetailsProvider` → `user.id`
   - Example: `"user_123456"`

## 📤 **Data Sent to Backend**

### **Method Call:**
```dart
await ref.read(authControllerProvider.notifier).updateUserProfile(
  userId: user.id,                    // From session
  address: _addressController.text,   // Form input
  idNumber: _idNumberController.text, // Form input
  profileImage: _profileImageFile,    // Optional file
  role: _selectedRole,               // Form selection
  context: context,
);
```

### **Backend Request Format:**

#### **Scenario 1: Without Profile Image (JSON)**
```http
PATCH /users/{userId}
Headers:
  X-Appwrite-JWT: <access_token>
  Content-Type: application/json
  Accept: application/json

Body:
{
  "address": "1925 Derby Ave. Roodepoort, 1734",
  "idNumber": "0122265320873",
  "role": "Rep",
  "verificationStatus": "Pending"
}
```

#### **Scenario 2: With Profile Image (Multipart)**
```http
PATCH /users/{userId}
Headers:
  X-Appwrite-JWT: <access_token>
  Accept: application/json

Body (multipart/form-data):
--boundary
Content-Disposition: form-data; name="address"

1925 Derby Ave. Roodepoort, 1734
--boundary
Content-Disposition: form-data; name="idNumber"

0122265320873
--boundary
Content-Disposition: form-data; name="role"

Rep
--boundary
Content-Disposition: form-data; name="verificationStatus"

Pending
--boundary
Content-Disposition: form-data; name="profileImage"; filename="profile.jpg"
Content-Type: image/jpeg

[binary image data]
--boundary--
```

## 🔧 **Data Processing (Backend)**

### **Required Fields:**
- `userId` (URL parameter)
- `address` (string, required)
- `idNumber` (string, required, 13 digits)
- `role` (string, required)
- `verificationStatus` (string, auto-set to "Pending")

### **Optional Fields:**
- `profileImage` (file, optional)

### **Authentication:**
- `X-Appwrite-JWT` header (required)

## 📊 **Complete Data Example**

### **Real Data from Your Error Log:**
```
userId: "user_123456" (from URL path)
address: "1925 Derby Ave. Roodepoort, 1734"
idNumber: "012226532087" (Note: This is 12 digits, should be 13)
role: "Rep"
verificationStatus: "Pending"
profileImage: null (no file selected)
```

### **Expected FastAPI Pydantic Model:**
```python
from pydantic import BaseModel, Field
from typing import Optional

class ProfileUpdateRequest(BaseModel):
    address: str = Field(..., min_length=1, description="User's address")
    idNumber: str = Field(..., regex=r'^\d{13}$', description="13-digit ID number")
    role: str = Field(..., description="User role")
    verificationStatus: str = Field(default="Pending", description="Verification status")

# For multipart requests
@router.patch("/users/{user_id}")
async def update_profile_multipart(
    user_id: str,
    address: str = Form(...),
    idNumber: str = Form(..., regex=r'^\d{13}$'),
    role: str = Form(...),
    verificationStatus: str = Form(default="Pending"),
    profileImage: Optional[UploadFile] = File(None),
    x_appwrite_jwt: str = Header(..., alias="X-Appwrite-JWT")
):
    # Process the data
    pass
```

## 🎯 **Key Points for Backend Implementation**

1. **URL Structure**: `PATCH /users/{user_id}`
2. **Authentication**: `X-Appwrite-JWT` header required
3. **Content Types**: Support both JSON and multipart
4. **Validation**: 13-digit ID number validation
5. **File Handling**: Optional profile image upload
6. **Status**: Auto-set `verificationStatus` to "Pending"

## 🔍 **Data Validation Rules**

### **Frontend Validation:**
- Address: Cannot be empty
- ID Number: Must be exactly 13 digits
- Role: Must be one of ['Rep', 'Admin', 'Manager']
- Profile Image: Optional

### **Backend Validation Should Include:**
- JWT token validation
- User ID exists and matches token
- Address is not empty
- ID Number is exactly 13 digits
- Role is valid enum value
- File type validation (if image provided)
- File size limits (if image provided)

## 📝 **Sample Backend Response**

### **Success Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "userId": "user_123456",
    "address": "1925 Derby Ave. Roodepoort, 1734",
    "idNumber": "0122265320873",
    "role": "Rep",
    "verificationStatus": "Pending",
    "profileImage": "https://example.com/images/profile_123456.jpg"
  }
}
```

### **Error Response:**
```json
{
  "success": false,
  "detail": [
    {
      "type": "string_pattern_mismatch",
      "loc": ["body", "idNumber"],
      "msg": "String should match pattern '^\\d{13}$'",
      "input": "012226532087"
    }
  ]
}
```

This is the complete data specification for what the profile completion page sends to your FastAPI backend!