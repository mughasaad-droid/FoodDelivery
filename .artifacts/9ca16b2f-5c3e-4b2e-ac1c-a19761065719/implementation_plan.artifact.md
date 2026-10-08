# Phase 10: Firebase Authentication Implementation

Hum app mein **Firebase Authentication** ko mukammal taur par implement karenge taake user real accounts ke sath login kar saken.

## User Review Required

> [!IMPORTANT]
> - Hum email/password authentication use karenge.
> - Aapko Firebase Console par ja kar **Authentication** section mein **Email/Password** provider ko **Enable** karna hoga.
> - Build ke waqt agar `google-services.json` ka error aaye, toh aik baar `flutter clean` karna zaroori ho sakta hai.

## Proposed Changes

### [Project Configuration]

#### [MODIFY] [pubspec.yaml](file:///C:/Users/hp/Desktop/my apps/saadfood/pubspec.yaml)
- `firebase_core: ^3.2.0` aur `firebase_auth: ^5.1.3` add karenge.

#### [MODIFY] [settings.gradle.kts](file:///C:/Users/hp/Desktop/my apps/saadfood/android/settings.gradle.kts)
- `id("com.google.gms.google-services") version "4.4.2" apply false` add karenge.

#### [MODIFY] [app/build.gradle.kts](file:///C:/Users/hp/Desktop/my apps/saadfood/android/app/build.gradle.kts)
- `id("com.google.gms.google-services")` apply karenge.

### [Logic & State]

#### [NEW] [auth_provider.dart](file:///C:/Users/hp/Desktop/my apps/saadfood/lib/providers/auth_provider.dart)
- Methods: `signUp(email, password)`, `signIn(email, password)`, `signOut()`.
- Error handling ke liye custom messages.

### [UI Screens]

#### [NEW] [login_screen.dart](file:///C:/Users/hp/Desktop/my apps/saadfood/lib/views/login_screen.dart)
- Orange theme ke sath login form.

#### [NEW] [signup_screen.dart](file:///C:/Users/hp/Desktop/my apps/saadfood/lib/views/signup_screen.dart)
- Naya account banane ke liye form.

### [Main Integration]

#### [MODIFY] [main.dart](file:///C:/Users/hp/Desktop/my apps/saadfood/lib/main.dart)
- Firebase initialize karna.
- `AuthProvider` register karna.

## Verification Plan

### Manual Verification
1. App run karein aur Signup screen par jayein.
2. Naya email aur password dal kar account banayein.
3. Check karein ke kya Firebase Console (Auth section) mein user nazar aa raha hai.
4. Login karke Home Screen tak transition verify karein.
