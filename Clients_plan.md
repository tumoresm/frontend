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
* [x] **Data Fetching:** Utilizes Riverpod providers (`getIndustriesProvider`, `getCompaniesProvider`, `getOrdersProvider`, `getRepOrdersProvider`) for efficient data management.
* [x] **Consistent Imports:** All Dart files adhere to `package:` import conventions for better maintainability.

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
* [ ] **Wallet System:**
    * [x] **Data Models & Foundation:**
        * [x] WalletModel - Core wallet with balance tracking
        * [x] TransactionModel - Financial transaction tracking
        * [x] BankAccountModel - Bank account management
        * [x] WithdrawalRequestModel - Withdrawal request tracking
        * [x] Wallet enums - Transaction types and statuses
        * [x] Null-safe serialization and error handling
    * [ ] **Earnings Tracking Dashboard:**
        * [ ] Display total earnings for the current week.
        * [ ] Show cumulative earnings across all weeks.
        * [ ] Breakdown of earnings by order/commission type.
        * [ ] Visual charts/graphs for earnings trends over time.
    * [ ] **Payment History:**
        * [ ] List of all payments made to rep's bank account.
        * [ ] Payment status indicators (pending, completed, failed).
        * [ ] Payment dates and amounts with transaction references.
        * [ ] Filter payments by date range and status.
    * [ ] **Withdrawal Management:**
        * [ ] Add "Withdraw" option to floating action button menu.
        * [ ] Withdrawal request form with amount validation.
        * [ ] Minimum withdrawal amount enforcement.
        * [ ] Bank account verification before withdrawal.
        * [ ] Withdrawal history and status tracking.
    * [ ] **Wallet Balance Display:**
        * [ ] Current available balance prominently displayed.
        * [ ] Pending earnings (orders not yet paid out).
        * [ ] Reserved amounts (processing withdrawals).
        * [ ] Clear distinction between available and total earnings.
    * [ ] **Weekly Earnings Summary:**
        * [ ] Week-by-week breakdown of earnings.
        * [ ] Comparison with previous weeks.
        * [ ] Goal tracking and achievement indicators.
        * [ ] Export functionality for personal records.
    * [ ] **Bank Account Management:**
        * [ ] Add/edit bank account details for withdrawals.
        * [ ] Bank account verification process.
        * [ ] Multiple bank account support.
        * [ ] Default account selection for withdrawals.
    * [ ] **Notifications & Alerts:**
        * [ ] Payment received notifications.
        * [ ] Withdrawal status updates.
        * [ ] Weekly earnings summary notifications.
        * [ ] Low balance or withdrawal limit alerts.

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