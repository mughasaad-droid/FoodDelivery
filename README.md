# 🍔 SaadFood - Full Stack Food Delivery App & Admin Panel

SaadFood is a modern, full-featured Food Delivery application built with Flutter and powered by Firebase. The repository includes two complete Flutter applications: a **Customer / Delivery App** for ordering food and live tracking, and an **Admin Panel** for restaurant management, order fulfillment, menu configuration, and user feedback monitoring.

---

## 📱 System Overview

```
                          ┌──────────────────────────┐
                          │     Firebase Backend     │
                          │ Auth | Firestore| Storage│
                          └─────────────┬────────────┘
                                        │
                    ┌───────────────────┴───────────────────┐
                    ▼                                       ▼
    ┌───────────────────────────────┐       ┌───────────────────────────────┐
    │     SaadFood Customer App     │       │      SaadFood Admin Panel     │
    │  - Browsing & Customization   │       │  - Live Orders Dashboard      │
    │  - Cart & Checkout            │       │  - Order Status Updates       │
    │  - Real-time Order Tracking   │       │  - Add / Edit / Delete Menu   │
    │  - Location & Profile         │       │  - Customer Feedback Views    │
    └───────────────────────────────┘       └───────────────────────────────┘
```

---

## ✨ Features Breakdown

### 🛒 1. Customer / Delivery App (`lib/main.dart`)
- **User Authentication:** Secure Sign Up and Log In powered by Firebase Authentication.
- **Dynamic Food Menu & Categories:**
  - Categorized browsing: *Classic*, *Spicy*, *Sliders*, *Combo*.
  - Real-time search bar to search food items instantly.
  - Interactive promotional banners.
- **Burger Customization & Add-ons:**
  - Free toppings selection (Tomato, Pickles, Onions).
  - Paid sides & drinks selection (Fries, Onion Rings, Salate, Pepsi, Coke, Sprite).
  - Real-time total calculation based on selected add-ons.
- **Cart & Subtotal Breakdown:**
  - Quantity controls (increment, decrement, remove).
  - Detailed pricing breakdown: Subtotal, Additional Toppings, Tax, Delivery Fee, and Final Total.
- **Seamless Checkout & Location Picker:**
  - GPS-based current location detection using `geolocator` and `geocoding`.
  - Manual location picker option.
  - Phone contact number entry.
  - Multiple payment methods (Credit Card, Debit Card, Cash on Delivery).
- **Real-Time Order Tracking:**
  - Live order tracking pipeline: `Order Confirmed` ➔ `Preparing` ➔ `On the way` ➔ `Delivered`.
  - Automatic status updates synced directly from Cloud Firestore.
  - Ability to cancel/delete active orders.
- **User Profile & Feedback System:**
  - View profile info.
  - Directly submit feedback and suggestions to the restaurant admin.
  - Dark Mode and Light Mode theme toggle.
  - Modern UI with glassmorphism floating bottom navigation bar.

---

### 🛡️ 2. Admin Panel (`lib/main_admin.dart`)
- **Admin Authentication:** Restricted authentication access for admin accounts (`admin@saadfood.com`).
- **Real-Time Analytics Dashboard:**
  - Total Orders counter.
  - Pending orders status count.
  - Orders currently in preparation.
  - Total revenue metric calculated in real-time.
- **Order Management:**
  - Real-time orders stream from Firestore.
  - View full customer details: Email, Contact Number, Delivery Address, Ordered Items & Custom Extra Toppings.
  - Customer Active/Deleted status indicator.
  - Instant status update selector (`Order Confirmed`, `Preparing`, `On the way`, `Delivered`).
  - Permanent order deletion from Firestore.
- **Menu & Inventory Management:**
  - View all active menu items.
  - Add new burgers with image upload support (Firebase Storage) for both Mobile & Web platforms.
  - Specify price, category, rating, and detailed descriptions.
  - Delete items from the menu.
- **Customer Feedback Monitoring:**
  - Live feedback stream from app users with user email and timestamp.
  - Option to clear or purge customer comments.

---

## 🛠️ Tech Stack & Dependencies

- **Framework:** [Flutter](https://flutter.dev/) (Dart SDK `^3.12.2`)
- **State Management:** [Provider](https://pub.dev/packages/provider) (`^6.1.1`)
- **Backend & Database:**
  - [Firebase Core](https://pub.dev/packages/firebase_core) (`^3.2.0`)
  - [Firebase Auth](https://pub.dev/packages/firebase_auth) (`^5.1.3`)
  - [Cloud Firestore](https://pub.dev/packages/cloud_firestore) (`^5.1.0`)
  - [Firebase Storage](https://pub.dev/packages/firebase_storage) (`^12.1.0`)
- **Location Services:**
  - [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter) (`^2.5.0`)
  - [Geolocator](https://pub.dev/packages/geolocator) (`^10.1.0`)
  - [Geocoding](https://pub.dev/packages/geocoding) (`^2.1.1`)
- **Media & Utilities:**
  - [Image Picker](https://pub.dev/packages/image_picker) (`^1.1.2`)
  - [Intl](https://pub.dev/packages/intl) (`^0.19.0`)
  - [URL Launcher](https://pub.dev/packages/url_launcher) (`^6.2.5`)

---

## 📂 Project Directory Structure

```
saadfood/
├── android/                   # Android native configuration
├── ios/                       # iOS native configuration
├── web/                       # Web platform support
├── assets/                    # Image assets, icons, and food banners
├── lib/
│   ├── main.dart              # Customer App Entry Point
│   ├── main_admin.dart        # Admin Panel Entry Point
│   ├── admin/                 # Admin Panel Screens & Controls
│   │   ├── add_burger_screen.dart
│   │   ├── admin_burger_list_screen.dart
│   │   ├── admin_comments_screen.dart
│   │   ├── admin_dashboard_screen.dart
│   │   ├── admin_order_details_screen.dart
│   │   └── admin_orders_list_screen.dart
│   ├── models/                # Data Models (Burger, Order, Cart, Comment)
│   ├── providers/             # State Management Providers (Auth, Cart, Order, Location, Theme, Burger, Comment, Nav)
│   ├── views/                 # Customer App Screens
│   │   ├── auth_intro_screen.dart
│   │   ├── burger_details_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   ├── home_screen.dart
│   │   ├── location_picker_screen.dart
│   │   ├── login_screen.dart
│   │   ├── orders_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── splash_screen.dart
│   │   └── track_order_screen.dart
│   └── widgets/               # Reusable UI Components
├── pubspec.yaml               # Project dependencies and configurations
└── README.md                  # Comprehensive Documentation
```

---

## 🚀 How to Run the Applications

### Prerequisites
- Flutter SDK installed (`>=3.12.2`)
- Android Studio / VS Code with Flutter extension
- Configured Firebase project

### 1. Customer Application
To run the primary customer food delivery app:
```bash
flutter run -t lib/main.dart
```

### 2. Admin Panel Application
To run the admin panel (supports Web & Mobile):
```bash
# On Mobile / Emulator
flutter run -t lib/main_admin.dart

# On Web Browser
flutter run -d chrome -t lib/main_admin.dart
```

---

## 🔑 Admin Credentials
- **Admin Email:** `admin@saadfood.com`
- Accessing `lib/main_admin.dart` verifies if the logged-in user is `admin@saadfood.com` before granting access to the Admin Dashboard.

---

## 📄 License
This project is for demonstration and personal/commercial food delivery management.
