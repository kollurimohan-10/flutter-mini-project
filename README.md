# Hostel Student Management System (Flutter + MongoDB)

A complete, production-grade, functional mobile application built with **Flutter**, **Dart**, **Material Design 3**, and **MongoDB** (`mongo_dart`), created for a College Flutter Lab Mini Project.

---

## 1. Project Abstract

The **Hostel Student Management System** is a cross-platform mobile application engineered to streamline, digitize, and automate day-to-day administrative and residential operations in university hostels. Traditional paper-based registers and fragmented spreadsheets frequently lead to data redundancy, room over-allocation, delayed grievance redressal, and inaccurate fee dues tracking.

This system provides a modern, role-based architecture with two dedicated workflows:
1. **Hostel Warden / Administrator Portal**: Complete control over student registrations, room bed capacity allocations, daily attendance recording, fee payment logging with real-time dues calculation, grievance tracking, outstation leave approvals, and campus notices.
2. **Student Resident Portal**: Self-service access to view assigned room and roommate details, fee payment history and pending receipts, daily attendance metrics, direct submission and tracking of maintenance complaints, outstation leave applications, and mess timings/rules.

The application is powered by **MongoDB** document collections and implements an offline-resilient architecture with preloaded sample data and a one-click database seeder, ensuring flawless demonstration during college evaluations and lab viva voce examinations.

---

## 2. Technology Stack

| Layer | Technology | Details |
| :--- | :--- | :--- |
| **Frontend Framework** | Flutter SDK (v3.0.0+) | Material Design 3, Responsive UI |
| **Language** | Dart (v3.0+) | Null-safe, Object-Oriented |
| **Database** | MongoDB | Document Store using `mongo_dart: ^0.10.0` |
| **Formatting & Dates** | `intl: ^0.19.0` | Currency (₹) and Date (`yyyy-MM-dd`) formatting |
| **Architecture** | Layered MVC / Repository Pattern | Models, Services, Widgets, Screens, Utils |
| **Theme / Design** | Material 3 Deep Navy & Teal | `#0F172A` (Navy), `#1E3A8A` (Blue), `#0EA5E9` (Teal) |
| **Deployment Platforms** | Android, iOS, Web, Windows | Runs on Android Phone / Emulator |

---

## 3. Project Structure

```
flutter_mini_project/
├── pubspec.yaml                 # Dependencies and asset declarations
├── README.md                    # Project documentation & Viva prep
├── android/                     # Android build files and manifests
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/AndroidManifest.xml
│   └── build.gradle
└── lib/
    ├── main.dart                # Application entrypoint & route management
    ├── models/                  # BSON / JSON Serializable data models
    │   ├── user_model.dart          # System user & credentials
    │   ├── student_model.dart       # Student bio, academic, room, and fees
    │   ├── room_model.dart          # Room occupancy, beds, and rent
    │   ├── attendance_model.dart    # Daily attendance records
    │   ├── fee_payment_model.dart   # Payment transactions & receipts
    │   ├── complaint_model.dart     # Maintenance complaints & resolution notes
    │   ├── leave_request_model.dart # Outstation leave applications
    │   └── announcement_model.dart  # Circulars & broadcasts
    ├── services/                # Business logic & Database layer
    │   ├── mongo_config.dart        # Connection URIs & collection names
    │   ├── mongo_service.dart       # Live driver connection, CRUD, offline fallback
    │   ├── auth_service.dart        # Role session management & demo auth
    │   └── sample_data_service.dart # Preloaded realistic test datasets
    ├── utils/                   # Theme tokens and validators
    │   ├── app_theme.dart           # Material 3 Navy & Teal theme
    │   ├── constants.dart           # Enums, statuses, mess menu, hostel rules
    │   └── validators.dart          # Regex validators (Phone, Email, Numbers)
    ├── widgets/                 # Reusable modular UI components
    │   ├── stat_card.dart           # Dashboard metric cards
    │   ├── status_badge.dart        # Dynamic color-coded status chips
    │   ├── custom_text_field.dart   # Standard input with borders & icons
    │   ├── custom_button.dart       # Elevated & outlined action buttons
    │   ├── app_drawer.dart          # Role-based sidebar navigation
    │   ├── empty_state_view.dart    # Clean visual empty state handler
    │   └── confirm_dialog.dart      # Action confirmation modal dialog
    └── screens/                 # All 21 functional screens
        ├── splash_screen.dart       # Animated launch screen
        ├── login_screen.dart        # Dual-role login with quick demo buttons
        ├── admin/                   # Administrator Module
        │   ├── admin_dashboard_screen.dart
        │   ├── student_list_screen.dart
        │   ├── student_form_screen.dart
        │   ├── student_details_screen.dart
        │   ├── room_list_screen.dart
        │   ├── room_form_screen.dart
        │   ├── room_details_screen.dart
        │   ├── attendance_screen.dart
        │   ├── fee_management_screen.dart
        │   ├── admin_complaints_screen.dart
        │   ├── admin_leaves_screen.dart
        │   ├── admin_announcements_screen.dart
        │   └── reports_screen.dart
        ├── student/                 # Student Resident Module
        │   ├── student_dashboard_screen.dart
        │   ├── student_profile_screen.dart
        │   ├── student_room_screen.dart
        │   ├── student_fees_screen.dart
        │   ├── student_attendance_screen.dart
        │   ├── student_complaints_screen.dart
        │   ├── student_leaves_screen.dart
        │   └── student_announcements_screen.dart
        └── common/                  # Shared Utility Screens
            ├── hostel_info_screen.dart
            └── settings_screen.dart
```

---

## 4. MongoDB Database Design & Collections

The application uses **MongoDB** (`mongo_dart`) as its primary database. The database is titled `hostel_db` and contains 8 distinct collections:

### 1. `users`
| Field | Type | Description |
| :--- | :--- | :--- |
| `_id` | ObjectId / String | Primary key |
| `username` | String | Login username (e.g. `admin`, `rahul`) |
| `password` | String | User password |
| `role` | String | `admin` or `student` |
| `student_id` | String? | Reference to student profile |
| `name` | String | Display name |
| `email` | String | Contact email |

### 2. `students`
| Field | Type | Description |
| :--- | :--- | :--- |
| `student_id` | String (Unique) | e.g. `STU1001` |
| `name` | String | Full student name |
| `gender` | String | `Male`, `Female`, `Other` |
| `dob` | String | Date of birth (`yyyy-MM-dd`) |
| `college` | String | Name of the institution |
| `course` | String | Course and branch |
| `year` | String | Study year (`1st Year` to `4th Year`) |
| `roll_no` | String (Unique) | Academic roll number |
| `phone` | String | 10-digit mobile number |
| `email` | String | Student email address |
| `parent_name` | String | Father / Mother / Guardian |
| `parent_phone` | String | Emergency parent contact number |
| `address` | String | Permanent residential address |
| `admission_date` | String | Hostel enrollment date |
| `room_number` | String? | Allocated room code (or `null`) |
| `fee_amount` | Double | Total semester/annual hostel fee |
| `emergency_contact` | String | Alternate emergency number |

### 3. `rooms`
| Field | Type | Description |
| :--- | :--- | :--- |
| `room_id` | String | Unique room ID |
| `room_number` | String (Unique) | e.g. `A-101`, `B-201` |
| `floor` | Int | Floor level (1, 2, 3) |
| `room_type` | String | `AC Standard`, `Non-AC Deluxe`, etc. |
| `total_beds` | Int | Total capacity (e.g. 2, 3, 4 beds) |
| `occupied_beds` | Int | Currently allocated bed count |
| `monthly_fee` | Double | Monthly room rent |
| `status` | String | `Available`, `Partially Occupied`, `Full` |

### 4. `attendance`
| Field | Type | Description |
| :--- | :--- | :--- |
| `attendance_id` | String | Unique compound key (`ATT_Date_StudentID`) |
| `student_id` | String | Student identifier |
| `student_name` | String | Denormalized name for quick display |
| `date` | String | Date of roll call (`yyyy-MM-dd`) |
| `status` | String | `Present`, `Absent`, `On Leave` |
| `remarks` | String? | Optional notes (e.g. approved leave) |

### 5. `fee_payments`
| Field | Type | Description |
| :--- | :--- | :--- |
| `payment_id` | String | Unique transaction ID |
| `student_id` | String | Target student ID |
| `student_name` | String | Student name |
| `amount` | Double | Paid installment amount (₹) |
| `payment_date` | String | Transaction date |
| `payment_method` | String | `UPI / GPay`, `Cash`, `Net Banking`, `Card` |
| `receipt_no` | String | Official receipt reference |
| `remarks` | String? | Notes or bank reference number |

### 6. `complaints`
| Field | Type | Description |
| :--- | :--- | :--- |
| `complaint_id` | String | Unique ticket ID |
| `student_id` | String | Filed by student |
| `student_name` | String | Student name |
| `room_number` | String | Room location |
| `title` | String | Issue summary |
| `description` | String | Complete issue details |
| `category` | String | `Electricity`, `Water`, `Food`, `Wi-Fi`, etc. |
| `priority` | String | `Low`, `Medium`, `High` |
| `status` | String | `Pending`, `In Progress`, `Resolved` |
| `submission_date`| String | Date ticket was raised |
| `resolution_notes`| String? | Action taken by warden / maintenance team |

### 7. `leave_requests`
| Field | Type | Description |
| :--- | :--- | :--- |
| `leave_id` | String | Unique leave application ID |
| `student_id` | String | Applicant student ID |
| `student_name` | String | Student name |
| `start_date` | String | Outstation departure date |
| `return_date` | String | Expected return date (>= start_date) |
| `reason` | String | Reason for travel |
| `parent_contact` | String | Verified parent phone |
| `status` | String | `Pending`, `Approved`, `Rejected` |
| `decision_notes` | String? | Warden approval or rejection comment |
| `applied_date` | String | Application date |

### 8. `announcements`
| Field | Type | Description |
| :--- | :--- | :--- |
| `announcement_id`| String | Unique notice ID |
| `title` | String | Circular headline |
| `message` | String | Notice body text |
| `date` | String | Published date |
| `priority` | String | `Normal` or `Urgent` |
| `author` | String | Issuing authority |

---

## 5. Demo Credentials & Evaluation Mode

The application includes **one-tap demo buttons** on the login screen for rapid college lab evaluation:

| Role | Username | Password | Access Details |
| :--- | :--- | :--- | :--- |
| **Admin / Warden** | `admin` | `admin123` | Full administrative control over all 8 modules |
| **Student Resident** | `rahul` | `student123` | Student portal for Rahul Sharma (`STU1001`) |
| **Student Resident (Alt)**| `priya` | `student123` | Student portal for Priya Patel (`STU1002`) |

### Resilient Offline Mode & MongoDB Seeding:
- The app automatically connects to MongoDB if reachable (via MongoDB Atlas or local daemon).
- If tested in an offline lab or computer without a running MongoDB service, **the app seamlessly falls back to its in-memory sample dataset** and will never crash or display blank screens in front of the evaluator!
- In **Settings**, tap **"Seed / Reload Sample Data"** to reset and populate all 8 collections into MongoDB instantly.

---

## 6. How to Set Up and Run the Application

### Prerequisites:
1. **Flutter SDK** (Version 3.0.0 or higher) installed on your system.
2. An IDE such as **VS Code** (with Flutter & Dart extensions) or **Android Studio**.
3. An **Android Emulator** or a physical Android phone with USB Debugging enabled.
4. *(Optional for live MongoDB)* **MongoDB Community Server** locally or a free cluster on **MongoDB Atlas**.

### Step 1: Open the Project Directory
```bash
cd "c:\Users\kisho\OneDrive\Desktop\web-devlop\flutter_mini_project"
```

### Step 2: Install Flutter Dependencies
Run the following command to download `mongo_dart`, `intl`, and other dependencies:
```bash
flutter pub get
```

### Step 3: Configure MongoDB (Optional)
By default, the app is pre-configured with `mongodb://10.0.2.2:27017/hostel_db` (which routes to your host machine's `localhost` from the Android emulator).
- If using **MongoDB Atlas**, enter your Atlas URI in `lib/services/mongo_config.dart` or directly in the app's **Settings** screen:
  `mongodb+srv://<username>:<password>@cluster0.mongodb.net/hostel_db?retryWrites=true&w=majority`
- If using desktop or web: `mongodb://127.0.0.1:27017/hostel_db`

### Step 4: Run the Application
To run on your connected Android device or emulator:
```bash
flutter run
```

To run on Chrome / Web for a quick demonstration:
```bash
flutter run -d chrome
```

---

## 7. Key System Modules & Features

1. **Dashboard & Dynamic Analytics**:
   - Live statistic cards: Total Students, Total Rooms, Available Beds, Pending Fees, Active Complaints.
   - Quick navigation shortcuts to common workflows.
   - Real-time updates as data is inserted, updated, or deleted.

2. **Student Directory & Profile Management**:
   - Search by name, student ID, roll number, or room code.
   - Filter by allocation status (`All`, `Allocated`, `Unallocated`).
   - Duplicate prevention for Student ID and Roll Number.
   - Form validation for 10-digit phone numbers, emails, and required inputs.

3. **Room Allocation Engine**:
   - Visual bed capacity indicators (e.g. Bed 1, Bed 2, Bed 3).
   - Prevents over-allocation when room reaches maximum capacity.
   - Automatic room status updates (`Available` -> `Partially Occupied` -> `Full`).
   - Clean bed release when a student is deleted or room is vacated.

4. **Batch Attendance Tracking**:
   - Calendar date picker for any day.
   - 3-way toggle per student (`Present`, `Absent`, `On Leave`).
   - Real-time calculation of student attendance percentages.
   - Unique compound keys to prevent duplicate records for the same student and date.

5. **Fee Management & Outstanding Dues**:
   - Automatic dues calculation: `Total Fee - Sum of Payments`.
   - Recording payments with date, amount, method (UPI, Cash, Net Banking), and receipt references.
   - Dynamic payment status chips (`Fully Paid`, `Partially Paid`, `Pending`).

6. **Grievance / Maintenance Redressal**:
   - Students file complaints categorized into Electricity, Water, Food, Cleaning, Wi-Fi, etc.
   - Wardens can update status (`Pending` -> `In Progress` -> `Resolved`) and append resolution notes.

7. **Outstation Leave Requests**:
   - Automated date validation: Ensures Return Date is never prior to Start Date.
   - Wardens can review reasons, verify parent phone numbers, and record approval/rejection notes.

8. **Hostel Rules & Campus Notices**:
   - Chronological broadcast noticeboard with `Urgent` and `Normal` tags.
   - Hostel curfew rules, visitor guidelines, and full weekly mess timings and menus.

---

## 8. College Lab Viva Voce Preparation Guide (25 Questions & Answers)

Here is a curated set of questions commonly asked by lab examiners and university professors during Flutter and database mini-project viva evaluations:

### Section A: Flutter & Dart Fundamentals

#### Q1: What is Flutter and why is it called a cross-platform framework?
**Answer:** Flutter is an open-source UI software development kit created by Google. It allows developers to build natively compiled applications for mobile (Android/iOS), web, and desktop from a **single codebase** using the **Dart** programming language.

#### Q2: What is the difference between a `StatelessWidget` and a `StatefulWidget`?
**Answer:** 
- A `StatelessWidget` is immutable. Its configuration and appearance cannot change once built (e.g. `StatCard`, `StatusBadge`).
- A `StatefulWidget` maintains mutable state across its lifetime via a separate `State` class. Calling `setState()` notifies the framework to re-run the `build()` method with updated data (e.g. `StudentFormScreen`, `AttendanceScreen`).

#### Q3: What is the role of `BuildContext` in Flutter?
**Answer:** `BuildContext` represents a handle to the location of a widget in the widget tree. It is used to look up inherited widgets and themes (e.g. `Theme.of(context)`), navigate between screens (`Navigator.push()`), and query media screen sizes (`MediaQuery.of(context)`).

#### Q4: What does `setState()` do under the hood?
**Answer:** `setState()` marks the current widget element as "dirty". During the next frame pipeline, Flutter's rendering engine schedules a rebuild of that widget element, calling its `build()` method and updating only the affected parts of the render tree.

#### Q5: What is null safety in Dart?
**Answer:** Sound null safety ensures that variables cannot contain `null` unless explicitly marked with a `?` (e.g. `String? roomNumber`). This eliminates null pointer exceptions at runtime and catches potential crashes during compile time.

#### Q6: Why do we need to call `dispose()` on `TextEditingController`?
**Answer:** `TextEditingController` attaches listeners to the underlying native text input. Calling `dispose()` frees system resources and prevents memory leaks when the widget is permanently removed from the widget tree.

---

### Section B: Database & Architecture (MongoDB)

#### Q7: Why did you choose MongoDB over a traditional relational database (RDBMS)?
**Answer:** MongoDB is a NoSQL document database. It stores records as flexible, JSON-like **BSON** documents. This is ideal for mobile applications where data models (like student emergency contacts, roommate lists, and resolution notes) have hierarchical or nested structures and do not require rigid schema migrations.

#### Q8: How does Flutter communicate with MongoDB in your project?
**Answer:** We use the official `mongo_dart` driver package. It establishes a direct TCP socket connection to the MongoDB server using connection strings like `mongodb://` or `mongodb+srv://`, sends BSON binary queries, and maps documents into Dart `Map<String, dynamic>` objects.

#### Q9: What is the purpose of `toMap()` and `fromMap()` in your Model classes?
**Answer:** 
- `toMap()` serializes a Dart object (e.g. `StudentModel`) into a `Map<String, dynamic>` suitable for insertion into MongoDB collections.
- `fromMap()` deserializes a MongoDB BSON/JSON map retrieved from a query back into a strongly typed Dart model instance.

#### Q10: How does your application handle an offline environment or absent MongoDB connection during evaluation?
**Answer:** In `MongoService`, we implemented a **resilient cache/service pattern**. The service pre-loads verified sample datasets into memory on startup and attempts to connect to MongoDB with a short timeout. If MongoDB is offline, the app continues to operate seamlessly on the local dataset without crashing, and allows one-tap seeding to MongoDB once connected.

#### Q11: What are MongoDB Collections and Documents?
**Answer:** 
- A **Document** is a single record composed of field-and-value pairs (analogous to a row in SQL).
- A **Collection** is a grouping of related MongoDB documents (analogous to a table in SQL). Our app uses 8 collections: `users`, `students`, `rooms`, `attendance`, `fee_payments`, `complaints`, `leave_requests`, and `announcements`.

#### Q12: What is `ObjectId` in MongoDB?
**Answer:** An `ObjectId` is a 12-byte BSON type uniquely generated by MongoDB to serve as the default primary key (`_id`) for every document. It contains a 4-byte timestamp, 5-byte random value, and a 3-byte incrementing counter.

---

### Section C: Business Logic & Functional Validation

#### Q13: How does the system prevent room over-allocation?
**Answer:** In `room_details_screen.dart` and `mongo_service.dart`, when allocating a student, the system queries the room's `total_beds` capacity and compares it against current occupants. If `occupants.length >= totalBeds`, the system rejects the allocation and disables the button.

#### Q14: How are student fee dues calculated?
**Answer:** Dues are computed dynamically rather than stored as a static number:
$$\text{Outstanding Due} = \text{Student.feeAmount} - \sum (\text{FeePayment.amount for that student})$$
This guarantees that whenever a new installment is paid, the due amount is immediately accurate across both the admin and student dashboards.

#### Q15: How do you prevent duplicate attendance for the same student on the same date?
**Answer:** Each attendance record generates a unique compound key: `ATT_${date}_${studentId}`. When saving attendance batches, `mongo_service.dart` checks if a record with the same student ID and date already exists, and updates the existing status instead of inserting a duplicate.

#### Q16: How is outstation leave date validation handled?
**Answer:** In `student_leaves_screen.dart`, the date picker enforces that the `returnDate` cannot be before the `startDate`. If a user attempts to select a return date earlier than their departure, the system displays an error SnackBar and resets the date constraint.

#### Q17: What is role-based authentication in your project?
**Answer:** The `AuthService` inspects the `role` field (`admin` vs `student`) upon login. Administrators are directed to the comprehensive administrative dashboard with full CRUD privileges, while students are restricted to the student portal showing only their personal room, fees, and leave records.

---

### Section D: UI/UX & Material Design 3

#### Q18: What is Material Design 3 (M3) and how did you configure it?
**Answer:** Material 3 is Google's latest design system featuring dynamic color schemes, rounded corners (12-16px radii), subtle elevations, and accessible contrast. We enabled `useMaterial3: true` in `ThemeData` and configured a custom `ColorScheme.fromSeed` with deep navy and cyan/teal accents.

#### Q19: How did you implement named route navigation?
**Answer:** In `main.dart`, we registered a `routes` map with paths like `/login`, `/admin_dashboard`, and `/student_list`. For screens requiring parameters (such as `StudentDetailsScreen(studentId)`), we used `onGenerateRoute` with `settings.arguments` to safely pass data between pages.

#### Q20: What is an `EmptyStateView` widget?
**Answer:** It is a reusable widget that displays an informative illustration, title, and optional call-to-action button when a query returns zero items (e.g. empty search results or zero complaints), preventing the screen from appearing blank or broken.

---

## 9. Conclusion & Mini Project Summary

This Hostel Student Management System provides a complete, modern, and practical software engineering demonstration for a college Flutter lab. It covers all fundamental and intermediate Flutter concepts:
- **Widget composition** (Stateless & Stateful)
- **Asynchronous Dart** (`Future`, `async/await`)
- **NoSQL document database operations** (CRUD via `mongo_dart`)
- **Layered software architecture** (Separation of concerns)
- **Form validation and error handling**
- **Dynamic data calculations and reporting**
- **Responsive Material 3 user interfaces**
