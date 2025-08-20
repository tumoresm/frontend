# FastAPI Backend Implementation Checklist

## 🚀 **Quick Start Guide**

### Prerequisites
- [ ] FastAPI project setup with authentication working
- [ ] Database models created (SQLAlchemy/Tortoise ORM)
- [ ] JWT authentication middleware implemented
- [ ] CORS middleware configured

## 📋 **Implementation Checklist**

### Phase 1: Critical Endpoints (Week 1)
#### Order Management
- [ ] `GET /orders/rep/{rep_id}` - Get orders by rep ID
- [ ] `POST /orders` - Create new order
- [ ] Database table: `orders` with all OrderModel fields

#### Company Management  
- [ ] `GET /companies` - Get all companies
- [ ] `GET /companies/{company_id}` - Get company by ID
- [ ] Database table: `companies` with all CompanyModel fields

### Phase 2: Financial System (Week 2)
#### Wallet System
- [ ] `GET /wallet/{user_id}` - Get user wallet
- [ ] `POST /wallet` - Create wallet
- [ ] `PATCH /wallet/{wallet_id}` - Update wallet
- [ ] Database table: `wallets`

#### Transactions
- [ ] `GET /transactions/{user_id}` - Get user transactions
- [ ] `POST /transactions` - Create transaction
- [ ] Database table: `transactions`

### Phase 3: Banking & Relations (Week 3)
#### Bank Accounts
- [ ] `GET /bank-accounts/{user_id}` - Get user bank accounts
- [ ] `POST /bank-accounts` - Add bank account
- [ ] Database table: `bank_accounts`

#### Withdrawal Requests
- [ ] `GET /withdrawal-requests/{user_id}` - Get withdrawal requests
- [ ] `POST /withdrawal-requests` - Create withdrawal request
- [ ] Database table: `withdrawal_requests`

#### Rep-Company Relations
- [ ] `POST /rep-company-relations` - Add relation
- [ ] `GET /rep-company-relations/{user_id}` - Get user relations
- [ ] Database table: `rep_company_relations`

## 🔧 **Technical Implementation Notes**

### Database Schema Mapping
```sql
-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rep_id UUID NOT NULL,
    company_id UUID NOT NULL,
    product_id UUID NOT NULL,
    addons TEXT,
    accessories TEXT,
    invoice_total DECIMAL(10,2) NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(50) NOT NULL,
    customer_email VARCHAR(255),
    customer_address TEXT NOT NULL,
    customer_location JSONB NOT NULL,
    order_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    status_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Companies table
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    industry_id UUID,
    logo_url VARCHAR(500),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    address TEXT,
    website VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Wallets table
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    current_balance DECIMAL(10,2) DEFAULT 0.00,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    pending_earnings DECIMAL(10,2) DEFAULT 0.00,
    reserved_amount DECIMAL(10,2) DEFAULT 0.00,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Authentication Middleware
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

### Response Format Template
```python
from pydantic import BaseModel
from typing import Optional, Any

class BaseResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Any] = None

# Usage in endpoints
@app.get("/orders/rep/{rep_id}")
async def get_rep_orders(rep_id: str, current_user: str = Depends(get_current_user)):
    try:
        orders = await get_orders_by_rep_id(rep_id)
        return BaseResponse(
            success=True,
            message="Orders retrieved successfully",
            data=orders
        )
    except Exception as e:
        return BaseResponse(
            success=False,
            message=str(e),
            data=None
        )
```

## 🧪 **Testing Strategy**

### Test Each Endpoint
```python
import pytest
from fastapi.testclient import TestClient

def test_get_rep_orders():
    response = client.get(
        "/orders/rep/test-rep-id",
        headers={"Authorization": "Bearer valid-jwt-token"}
    )
    assert response.status_code == 200
    assert response.json()["success"] == True
    assert "data" in response.json()
```

## 🔄 **Flutter Integration Steps**

After implementing each endpoint:

1. **Update Flutter API classes** to use FastAPI instead of Appwrite
2. **Remove graceful degradation** from providers
3. **Test with Flutter app** to ensure data flows correctly
4. **Update field mappings** if needed (e.g., `companyName` vs `name`)

## 📊 **Progress Tracking**

### Week 1 Goals
- [ ] Orders API fully functional
- [ ] Companies API fully functional
- [ ] Flutter app shows real orders and companies

### Week 2 Goals  
- [ ] Wallet system functional
- [ ] Transaction history working
- [ ] Financial features enabled in Flutter

### Week 3 Goals
- [ ] Banking features complete
- [ ] Rep-company relations working
- [ ] All Appwrite dependencies removed

## 🚨 **Critical Success Factors**

1. **Field Name Mapping**: Ensure Flutter model field names match API responses
2. **Date Format**: Return ISO 8601 strings, Flutter will parse them
3. **Error Handling**: Return consistent error format for Flutter to handle
4. **Authentication**: Verify JWT tokens on every protected endpoint
5. **Data Validation**: Validate all input data before database operations

## 📞 **Support & Communication**

- **Flutter Team**: Notify when endpoints are ready for testing
- **Database Team**: Coordinate schema changes and migrations
- **DevOps Team**: Ensure proper deployment and environment variables

---

**Priority**: Implement Phase 1 endpoints first to restore core app functionality, then proceed with financial features in Phase 2 and 3.