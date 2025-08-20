# FastAPI Backend Endpoints Specification

## Overview
This document provides precise instructions for implementing the missing FastAPI endpoints required for the FieldForce application migration from Appwrite.

## 🔐 **Authentication Requirements**

All endpoints (except auth endpoints) require JWT authentication:
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
import jwt

security = HTTPBearer()

async def get_current_user(token: str = Depends(security)):
    try:
        payload = jwt.decode(token.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

## 📋 **Data Models**

### Base Response Model
```python
from pydantic import BaseModel
from typing import Optional, Any
from datetime import datetime

class BaseResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Any] = None
```

## 🛒 **1. ORDER MANAGEMENT ENDPOINTS** (HIGHEST PRIORITY)

### Order Model
```python
from enum import Enum
from typing import Optional, Dict, Any
from datetime import datetime

class OrderStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    PAID = "paid"
    DELIVERED = "delivered"
    REJECTED = "rejected"
    CANCELLED = "cancelled"

class OrderCreate(BaseModel):
    rep_id: str
    company_id: str
    product_id: str
    addons: Optional[str] = None
    accessories: Optional[str] = None
    invoice_total: float
    customer_name: str
    customer_phone: str
    customer_email: Optional[str] = None
    customer_address: str
    customer_location: Dict[str, Any]
    order_status: OrderStatus = OrderStatus.PENDING
    status_reason: Optional[str] = None

class OrderResponse(BaseModel):
    id: str
    rep_id: str
    company_id: str
    product_id: str
    addons: Optional[str]
    accessories: Optional[str]
    invoice_total: float
    customer_name: str
    customer_phone: str
    customer_email: Optional[str]
    customer_address: str
    customer_location: Dict[str, Any]
    order_status: OrderStatus
    status_reason: Optional[str]
    created_at: datetime
    updated_at: datetime
```

### Endpoints

#### 1.1 Get All Orders
```python
@app.get("/orders", response_model=List[OrderResponse])
async def get_orders(current_user: str = Depends(get_current_user)):
    """Get all orders (admin only) or user's orders"""
    # Implementation: Return all orders for admin, user's orders for regular users
    pass
```

#### 1.2 Get Orders by Rep ID
```python
@app.get("/orders/rep/{rep_id}", response_model=List[OrderResponse])
async def get_rep_orders(
    rep_id: str,
    current_user: str = Depends(get_current_user)
):
    """Get orders for a specific sales representative"""
    # Implementation: Verify user can access these orders
    pass
```

#### 1.3 Create Order
```python
@app.post("/orders", response_model=BaseResponse)
async def create_order(
    order: OrderCreate,
    current_user: str = Depends(get_current_user)
):
    """Create a new order"""
    # Implementation: 
    # 1. Validate rep_id matches current_user or user has admin rights
    # 2. Validate company_id and product_id exist
    # 3. Create order with auto-generated ID
    # 4. Set created_at and updated_at to current timestamp
    pass
```

#### 1.4 Update Order
```python
@app.patch("/orders/{order_id}", response_model=BaseResponse)
async def update_order(
    order_id: str,
    order_update: OrderCreate,
    current_user: str = Depends(get_current_user)
):
    """Update an existing order"""
    # Implementation:
    # 1. Verify order exists and user has permission
    # 2. Update fields and set updated_at
    pass
```

#### 1.5 Delete Order
```python
@app.delete("/orders/{order_id}", response_model=BaseResponse)
async def delete_order(
    order_id: str,
    current_user: str = Depends(get_current_user)
):
    """Delete an order"""
    # Implementation: Soft delete or hard delete based on business rules
    pass
```

## 🏢 **2. COMPANY MANAGEMENT ENDPOINTS** (HIGH PRIORITY)

### Company Model
```python
class CompanyCreate(BaseModel):
    name: str
    description: str
    industry_id: str
    logo_url: Optional[str] = None
    contact_email: str
    contact_phone: str
    address: str
    website: Optional[str] = None
    is_active: bool = True

class CompanyResponse(BaseModel):
    id: str
    name: str
    description: str
    industry_id: str
    logo_url: Optional[str]
    contact_email: str
    contact_phone: str
    address: str
    website: Optional[str]
    is_active: bool
    created_at: datetime
    updated_at: datetime

# Note: Flutter model uses different field names, map accordingly:
# companyName -> name
# logoUrl -> logo_url
# industryId -> industry_id
# contactEmail -> contact_email
# contactPhone -> contact_phone
# isActive -> is_active
```

### Endpoints

#### 2.1 Get All Companies
```python
@app.get("/companies", response_model=List[CompanyResponse])
async def get_companies(current_user: str = Depends(get_current_user)):
    """Get all active companies"""
    # Implementation: Return all companies where is_active=True
    pass
```

#### 2.2 Get Company by ID
```python
@app.get("/companies/{company_id}", response_model=CompanyResponse)
async def get_company(
    company_id: str,
    current_user: str = Depends(get_current_user)
):
    """Get a specific company by ID"""
    # Implementation: Return company details
    pass
```

#### 2.3 Create Company (Admin Only)
```python
@app.post("/companies", response_model=BaseResponse)
async def create_company(
    company: CompanyCreate,
    current_user: str = Depends(get_current_user)
):
    """Create a new company (admin only)"""
    # Implementation: Verify admin permissions
    pass
```

#### 2.4 Update Company (Admin Only)
```python
@app.patch("/companies/{company_id}", response_model=BaseResponse)
async def update_company(
    company_id: str,
    company_update: CompanyCreate,
    current_user: str = Depends(get_current_user)
):
    """Update company details (admin only)"""
    pass
```

## 💰 **3. WALLET SYSTEM ENDPOINTS** (MEDIUM PRIORITY)

### Wallet Models
```python
class WalletCreate(BaseModel):
    user_id: str
    current_balance: float = 0.0
    total_earnings: float = 0.0
    pending_earnings: float = 0.0
    reserved_amount: float = 0.0

class WalletResponse(BaseModel):
    id: str
    user_id: str
    current_balance: float
    total_earnings: float
    pending_earnings: float
    reserved_amount: float
    last_updated: datetime
    created_at: datetime

class TransactionType(str, Enum):
    EARNING = "earning"
    PAYMENT = "payment"
    WITHDRAWAL = "withdrawal"
    REFUND = "refund"
    COMMISSION = "commission"

class TransactionStatus(str, Enum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

class TransactionCreate(BaseModel):
    user_id: str
    type: TransactionType
    amount: float
    description: str
    order_id: Optional[str] = None
    status: TransactionStatus = TransactionStatus.PENDING
    reference_number: Optional[str] = None
    bank_account_id: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None

class TransactionResponse(BaseModel):
    id: str
    user_id: str
    type: TransactionType
    amount: float
    description: str
    order_id: Optional[str]
    status: TransactionStatus
    reference_number: Optional[str]
    bank_account_id: Optional[str]
    created_at: datetime
    processed_at: Optional[datetime]
    metadata: Optional[Dict[str, Any]]
```

### Wallet Endpoints

#### 3.1 Get User Wallet
```python
@app.get("/wallet/{user_id}", response_model=WalletResponse)
async def get_user_wallet(
    user_id: str,
    current_user: str = Depends(get_current_user)
):
    """Get wallet for a specific user"""
    # Implementation: Verify user can access this wallet
    pass
```

#### 3.2 Create Wallet
```python
@app.post("/wallet", response_model=BaseResponse)
async def create_wallet(
    wallet: WalletCreate,
    current_user: str = Depends(get_current_user)
):
    """Create a new wallet for user"""
    pass
```

#### 3.3 Update Wallet Balance
```python
@app.patch("/wallet/{wallet_id}", response_model=BaseResponse)
async def update_wallet(
    wallet_id: str,
    amount: float,
    operation_type: str,  # "add" or "subtract"
    current_user: str = Depends(get_current_user)
):
    """Update wallet balance"""
    pass
```

### Transaction Endpoints

#### 3.4 Get User Transactions
```python
@app.get("/transactions/{user_id}", response_model=List[TransactionResponse])
async def get_user_transactions(
    user_id: str,
    current_user: str = Depends(get_current_user)
):
    """Get all transactions for a user"""
    pass
```

#### 3.5 Create Transaction
```python
@app.post("/transactions", response_model=BaseResponse)
async def create_transaction(
    transaction: TransactionCreate,
    current_user: str = Depends(get_current_user)
):
    """Create a new transaction"""
    pass
```

## 🏦 **4. BANK ACCOUNT ENDPOINTS**

### Bank Account Models
```python
class BankAccountCreate(BaseModel):
    user_id: str
    account_holder_name: str
    bank_name: str
    account_number: str
    routing_number: Optional[str] = None
    account_type: str  # "checking", "savings"
    is_default: bool = False

class BankAccountResponse(BaseModel):
    id: str
    user_id: str
    account_holder_name: str
    bank_name: str
    account_number: str  # Should be masked in response
    routing_number: Optional[str]
    account_type: str
    is_default: bool
    is_verified: bool
    created_at: datetime
    updated_at: datetime
```

### Endpoints

#### 4.1 Get User Bank Accounts
```python
@app.get("/bank-accounts/{user_id}", response_model=List[BankAccountResponse])
async def get_user_bank_accounts(
    user_id: str,
    current_user: str = Depends(get_current_user)
):
    """Get bank accounts for a user"""
    pass
```

#### 4.2 Add Bank Account
```python
@app.post("/bank-accounts", response_model=BaseResponse)
async def create_bank_account(
    bank_account: BankAccountCreate,
    current_user: str = Depends(get_current_user)
):
    """Add a new bank account"""
    pass
```

## 💸 **5. WITHDRAWAL REQUEST ENDPOINTS**

### Withdrawal Models
```python
class WithdrawalStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    PROCESSING = "processing"
    COMPLETED = "completed"
    REJECTED = "rejected"
    CANCELLED = "cancelled"

class WithdrawalRequestCreate(BaseModel):
    user_id: str
    amount: float
    bank_account_id: str
    notes: Optional[str] = None

class WithdrawalRequestResponse(BaseModel):
    id: str
    user_id: str
    amount: float
    bank_account_id: str
    status: WithdrawalStatus
    notes: Optional[str]
    admin_notes: Optional[str]
    requested_at: datetime
    processed_at: Optional[datetime]
```

### Endpoints

#### 5.1 Get User Withdrawal Requests
```python
@app.get("/withdrawal-requests/{user_id}", response_model=List[WithdrawalRequestResponse])
async def get_user_withdrawal_requests(
    user_id: str,
    current_user: str = Depends(get_current_user)
):
    """Get withdrawal requests for a user"""
    pass
```

#### 5.2 Create Withdrawal Request
```python
@app.post("/withdrawal-requests", response_model=BaseResponse)
async def create_withdrawal_request(
    request: WithdrawalRequestCreate,
    current_user: str = Depends(get_current_user)
):
    """Create a new withdrawal request"""
    pass
```

## 🤝 **6. REP-COMPANY RELATIONS ENDPOINTS**

### Rep-Company Relation Models
```python
class VerificationStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"

class RepCompanyRelationCreate(BaseModel):
    user_id: str
    company_id: str

class RepCompanyRelationResponse(BaseModel):
    id: str
    user_id: str
    company_id: str
    verification_status: VerificationStatus
    date_added: datetime
    verified_at: Optional[datetime]
    verified_by: Optional[str]
```

### Endpoints

#### 6.1 Add Rep-Company Relation
```python
@app.post("/rep-company-relations", response_model=BaseResponse)
async def add_rep_company_relation(
    relation: RepCompanyRelationCreate,
    current_user: str = Depends(get_current_user)
):
    """Add a rep to company relation"""
    pass
```

#### 6.2 Get User Relations
```python
@app.get("/rep-company-relations/{user_id}", response_model=List[RepCompanyRelationResponse])
async def get_user_company_relations(
    user_id: str,
    current_user: str = Depends(get_current_user)
):
    """Get company relations for a user"""
    pass
```

## 🔧 **Implementation Guidelines**

### Database Schema Considerations
1. **Use UUIDs** for all ID fields to match Flutter expectations
2. **Timestamp Fields**: Store as UTC datetime, return as ISO strings
3. **Enum Fields**: Store as strings, validate against enum values
4. **JSON Fields**: Use proper JSON columns for metadata and location data

### Error Handling
```python
from fastapi import HTTPException

# Standard error responses
@app.exception_handler(404)
async def not_found_handler(request, exc):
    return {"success": False, "message": "Resource not found", "data": None}

@app.exception_handler(403)
async def forbidden_handler(request, exc):
    return {"success": False, "message": "Access forbidden", "data": None}
```

### Response Format
All endpoints should return consistent response format:
```python
{
    "success": true,
    "message": "Operation completed successfully",
    "data": { ... }  # Actual response data
}
```

### Authentication Headers
Flutter sends JWT tokens as:
```
Authorization: Bearer <jwt_token>
```

### CORS Configuration
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 📊 **Implementation Priority**

1. **Orders Endpoints** (1.1 - 1.5) - Critical for app functionality
2. **Companies Endpoints** (2.1 - 2.2) - Critical for app functionality  
3. **Wallet Endpoints** (3.1 - 3.3) - Important for financial features
4. **Transaction Endpoints** (3.4 - 3.5) - Important for financial features
5. **Bank Account Endpoints** (4.1 - 4.2) - Medium priority
6. **Withdrawal Endpoints** (5.1 - 5.2) - Medium priority
7. **Rep-Company Relations** (6.1 - 6.2) - Lower priority

## 🧪 **Testing Requirements**

Each endpoint should include:
- Unit tests for business logic
- Integration tests with database
- Authentication/authorization tests
- Input validation tests
- Error handling tests

## 📝 **Documentation**

Use FastAPI's automatic documentation:
- Add proper docstrings to all endpoints
- Include example requests/responses
- Document all error codes and messages

---

**Note**: This specification is based on the current Flutter models and API usage patterns. Adjust field names and data types as needed to match your database schema while maintaining compatibility with the Flutter frontend.