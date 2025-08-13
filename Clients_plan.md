# FieldForce Clients App Development Plan

This document outlines the development plan for the FieldForce Flutter Client Application, aligning with the broader FieldForce Product Requirements Document (PRD) and the overall development plan.

## 1.0 Introduction

The FieldForce Clients App serves as the primary interface for freelance field sales representatives. Its core purpose is to empower reps to efficiently manage their sales activities, track orders, monitor earnings, and connect with companies.

## 2.0 Current State & Progress

The Clients App is currently in active development, focusing on core functionalities outlined in Phase 1 and initial features of Phase 2 of the FieldForce PRD.

### 2.1 Implemented Features (as of current development)

* [x] **User Authentication:** Basic user authentication flows are in place.
* [x] **Home Dashboard:** A dashboard displaying user information, a chart, and a list of orders.
* [x] **Orders Page:** A dedicated page for viewing a list of orders.
* [x] **Advanced Order Filtering (by Industry):**
    * [x] Implemented `IndustryFilterButtons` widget for selecting industries.
    * [x] "More" button functionality to expand/collapse the list of industries.
    * [x] Integrated industry filtering into both the Home Dashboard and Orders Page, allowing reps to filter orders by the associated company's industry.
    * [x] Robust handling of data models (`IndustryModel`, `CompanyModel`) for null safety during deserialization.
* [x] **Complete Wallet System:** *(Major Feature Implementation)*
    * [x] Full wallet data models with comprehensive transaction tracking
    * [x] Complete API layer with Appwrite integration
    * [x] Riverpod state management with real-time updates
    * [x] Beautiful wallet UI with gradient cards and intuitive navigation
    * [x] Withdrawal management with form validation and bank account integration
    * [x] Transaction history with filtering and status tracking
    * [x] Earnings dashboard with balance breakdown and visual indicators
* [x] **Data Fetching:** Utilizes Riverpod providers (`getIndustriesProvider`, `getCompaniesProvider`, `getOrdersProvider`, `getRepOrdersProvider`, `getUserWalletProvider`, `getUserTransactionsProvider`) for efficient data management.
* [x] **Code Quality & Maintenance:**
    * [x] Consistent imports following `package:` conventions
    * [x] Unused import cleanup for optimized performance
    * [x] Lint compliance with const constructor optimizations
    * [x] Comprehensive error handling and user feedback

### 2.2 Current Architecture & Structure

The Clients App follows a modular Flutter architecture:

*   **`lib/apis`**: Contains API service definitions (e.g., `industry_api.dart`).
*   **`lib/common`**: Houses reusable widgets and utilities (e.g., `order_card.dart`, `notifications_dialog.dart`).
*   **`lib/constants`**: Stores application-wide constants.
*   **`lib/core`**: Core functionalities like base models, logging, and Riverpod providers.
*   **`lib/features`**: Organized by feature, containing `controller`, `model`, `provider`, and `view` subdirectories for each feature (e.g., `home`, `order`, `companies`).
*   **`lib/theme`**: Defines application themes, colors, and text styles.
*   **`lib/utils`**: General utility functions.

## 3.0 Future Development (Aligned with PRD Phases)

### 3.1 Phase 1: Core Functionality Completion

* [x] **User Authentication:**
    * [x] Implement "Forgot Password" flow.
    * [ ] Ensure robust error handling and user feedback for all authentication scenarios.
* [ ] **User Verification:**
    * [ ] Implement UI for prompting ID document upload post-registration.
    * [ ] Display user verification status clearly.
    * [ ] Restrict order creation for unverified/pending users.
* [ ] **Order Creation:**
    * [ ] Complete the Order Submission Form UI/Flow.
    * [ ] Implement all core fields for order creation as per PRD.
* [ ] **Order Tracking:**
    * [ ] Enhance Order Tracking Dashboard with more detailed status updates and visual indicators.
* [ ] **User Profile:**
    * [ ] Complete Basic User Profile Screen (view only).
* [x] **Wallet System:** *(Complete Implementation)*
    * [x] **Data Models & Foundation:**
        * [x] WalletModel - Core wallet with balance tracking (current, total, pending, reserved)
        * [x] TransactionModel - Financial transaction tracking with type-specific icons and status
        * [x] BankAccountModel - Bank account management with verification and masking
        * [x] WithdrawalRequestModel - Withdrawal request lifecycle management
        * [x] Wallet enums - Transaction types (earning, payment, withdrawal, commission, bonus, refund)
        * [x] Transaction statuses (pending, processing, completed, failed, cancelled)
        * [x] Withdrawal statuses (pending, approved, processing, completed, failed, cancelled, rejected)
        * [x] Null-safe serialization and comprehensive error handling
    * [x] **Complete API Layer:**
        * [x] WalletAPI - Create, update, get wallet by user, balance operations
        * [x] TransactionAPI - Create transactions, get by user/type/date range
        * [x] BankAccountAPI - CRUD operations, default account management
        * [x] WithdrawalRequestAPI - Create, update, cancel withdrawal requests
        * [x] Appwrite database integration with proper error handling
        * [x] FutureEither pattern for robust error management
    * [x] **Riverpod State Management:**
        * [x] WalletController - Comprehensive business logic and state management
        * [x] Data providers - getUserWallet, getUserTransactions, getUserBankAccounts
        * [x] Filtered providers - getTransactionsByType, getTransactionsByDateRange
        * [x] Real-time state updates with automatic data refresh
        * [x] Loading states and error handling throughout
    * [x] **Complete Wallet UI:**
        * [x] **WalletBalanceCard** - Beautiful gradient card showing:
            * [x] Current available balance (prominently displayed)
            * [x] Total earnings breakdown
            * [x] Pending earnings (orders not yet paid out)
            * [x] Reserved amounts (processing withdrawals)
            * [x] Loading and error states with user feedback
        * [x] **TransactionListWidget** - Recent transactions display:
            * [x] Type-specific icons (trending up, payment, withdrawal, etc.)
            * [x] Color-coded amounts (green for credits, red for debits)
            * [x] Status badges for transaction states
            * [x] Smart date formatting (Today, Yesterday, etc.)
            * [x] Empty state handling with appropriate messaging
        * [x] **WalletQuickActions** - Action button grid:
            * [x] Withdraw funds with validation
            * [x] Add bank account management
            * [x] View transaction history
            * [x] View withdrawal requests
            * [x] Color-coded icons with intuitive labels
        * [x] **WithdrawalRequestDialog** - Full-featured withdrawal form:
            * [x] Amount input with decimal validation
            * [x] Available balance display and validation
            * [x] Bank account selection dropdown
            * [x] Processing fee information
            * [x] Form validation and error handling
            * [x] Loading states during submission
    * [x] **Withdrawal Management:**
        * [x] "Withdraw Funds" option added to floating action button menu
        * [x] Withdrawal request form with comprehensive amount validation
        * [x] Available balance enforcement (prevents overdraft)
        * [x] Bank account requirement and verification
        * [x] Withdrawal history and status tracking
        * [x] Cancel withdrawal functionality for pending/approved requests
        * [x] Processing fee calculation and display
    * [x] **Earnings Tracking Dashboard:**
        * [x] Total earnings display with clear breakdown
        * [x] Current week earnings tracking
        * [x] Pending earnings visibility
        * [x] Transaction history with filtering capabilities
        * [x] Visual indicators for different transaction types
        * [x] Real-time balance updates
    * [x] **Payment History & Transaction Management:**
        * [x] Complete transaction list with type-specific icons
        * [x] Payment status indicators (pending, completed, failed)
        * [x] Transaction dates with smart formatting
        * [x] Amount display with credit/debit indicators
        * [x] Transaction filtering by type and date range
        * [x] Reference number tracking for payments
    * [x] **Bank Account Management:**
        * [x] Bank account model with comprehensive fields
        * [x] Account verification status tracking
        * [x] Masked account numbers for security
        * [x] Default account selection for withdrawals
        * [x] Multiple bank account support
        * [x] CRUD operations for bank account management
    * [x] **Navigation & Integration:**
        * [x] Seamless integration with existing app navigation
        * [x] Updated navbar wallet page with comprehensive interface
        * [x] Pull-to-refresh functionality for real-time data
        * [x] Error handling with user-friendly feedback
        * [x] Loading states throughout the wallet interface
    * [x] **Technical Implementation:**
        * [x] Consistent design system following app theme
        * [x] Material Symbols icons throughout
        * [x] Gradient design with proper color schemes
        * [x] Responsive layouts for different screen sizes
        * [x] Performance optimized with efficient state management
        * [x] Comprehensive error boundaries and fallback UI

### 3.2 Phase 2: Rep Expansion & Enhancements

* [ ] **Full User Profile Editing:**
    * [ ] Implement UI and logic for reps to edit their profile information.
* [ ] **Company Discovery & Management:**
    * [ ] Implement the flow for reps to browse and add companies to their profile.
* [ ] **Advanced Order Filtering & Searching:**
    * [ ] Expand filtering options beyond industry (e.g., by status, date range, customer name).
    * [ ] Implement search functionality for orders.
* [ ] **Basic Analytics for Reps (Earnings):**
    * [ ] Develop a dashboard or section to display rep earnings and performance metrics.

### 3.3 Future / Post-Launch Enhancements

* [ ] **Push Notifications:**
    * [ ] Integrate push notifications for order status updates, new company listings, etc.
* [ ] **Advanced Analytics & Reporting:**
    * [ ] Develop more comprehensive analytics and reporting tools for reps.
* [ ] **Offline Support:**
    * [ ] Implement offline capabilities for order creation and data synchronization.
* [ ] **In-app Chat/Messaging:**
    * [ ] Develop a secure in-app communication feature between reps and companies/admins.
* [ ] **Automated Invoicing and Payments:**
    * [ ] Integrate automated invoicing and payment processing functionalities.

## 4.0 Technical Considerations

* [ ] **Performance:** Continue to optimize list views and data fetching for smooth performance, especially with large datasets.
* [ ] **Error Handling:** Implement comprehensive error handling and user-friendly feedback across the application.
* [ ] **Security:** Ensure secure handling of sensitive user data and API interactions.
* [ ] **UI/UX:** Maintain a sleek, modern, and professional aesthetic consistent with the design guidelines. Ensure full support for light and dark themes.

This plan will serve as a living document, updated as development progresses and new requirements emerge.