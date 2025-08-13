# Deploying FastAPI Function to Appwrite Functions

## Prerequisites
1. Appwrite CLI installed: `npm install -g appwrite-cli`
2. Your FastAPI server code ready
3. Appwrite project configured

## Steps to Deploy

### 1. Initialize Appwrite CLI
```bash
appwrite login
appwrite init project
```

### 2. Create Function Structure
```bash
mkdir appwrite-functions
cd appwrite-functions
mkdir update-user-profile
cd update-user-profile
```

### 3. Create Function Files

**appwrite.json** (in project root):
```json
{
    "projectId": "686a7ec600267548efae",
    "functions": [
        {
            "$id": "update-user-profile",
            "name": "Update User Profile",
            "runtime": "python-3.9",
            "execute": ["any"],
            "events": [],
            "schedule": "",
            "timeout": 15,
            "enabled": true,
            "logging": true,
            "entrypoint": "src/main.py",
            "commands": "pip install -r requirements.txt",
            "ignore": [".git", "node_modules", ".appwrite"]
        }
    ]
}
```

**requirements.txt**:
```txt
appwrite
fastapi
pydantic
```

**src/main.py**:
```python
import json
import os
from appwrite.client import Client
from appwrite.services.databases import Databases

def main(req, res):
    try:
        # Parse request body
        if req.payload:
            data = json.loads(req.payload)
        else:
            return res.json({'error': 'No data provided'}, 400)
        
        # Initialize Appwrite client
        client = Client()
        client.set_endpoint(os.environ.get('APPWRITE_FUNCTION_ENDPOINT'))
        client.set_project(os.environ.get('APPWRITE_FUNCTION_PROJECT_ID'))
        client.set_key(os.environ.get('APPWRITE_FUNCTION_API_KEY'))
        
        databases = Databases(client)
        
        # Update user profile
        result = databases.update_document(
            database_id=os.environ.get('DATABASE_ID', 'fieldforce_db'),
            collection_id='users',
            document_id=data['userId'],
            data={
                'address': data['address'],
                'idDocumentUrl': data['idDocumentUrl'],
                'role': data['role'],
                'verificationStatus': data['verificationStatus'],
                'profileImageUrl': data.get('profileImageUrl', '')
            }
        )
        
        return res.json({
            'success': True,
            'message': 'Profile updated successfully',
            'data': result
        })
        
    except Exception as e:
        return res.json({
            'success': False,
            'error': str(e)
        }, 500)
```

### 4. Deploy Function
```bash
appwrite deploy function
```

### 5. Set Environment Variables
In Appwrite Console > Functions > update-user-profile > Settings:
- `DATABASE_ID`: fieldforce_db
- `APPWRITE_FUNCTION_ENDPOINT`: http://192.168.100.5/v1
- `APPWRITE_FUNCTION_PROJECT_ID`: 686a7ec600267548efae

## Testing the Function
```bash
curl -X POST http://192.168.100.5/v1/functions/update-user-profile/executions \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: 686a7ec600267548efae" \
  -d '{
    "userId": "test-user-id",
    "address": "123 Test St",
    "idDocumentUrl": "https://example.com/id.jpg",
    "role": "Rep",
    "verificationStatus": "pending"
  }'
```