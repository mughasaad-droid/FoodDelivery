# Side Menu & Dark Mode Implementation Walkthrough

Humne aapki requirements ke mutabiq **Side Menu** aur **Dark Mode** feature successfully implement kar liya hai. Ab aapki app mazeed professional aur versatile ho gayi hai.

## Changes Made

### 1. State Management (Theme)
- **[theme_provider.dart](file:///C:/Users/hp/Desktop/my apps/saadfood/lib/providers/theme_provider.dart)**: Naya provider banaya jo Light aur Dark modes ke darmyan switch karne ki logic handle karta hai.
- **[main.dart](file:///C:/Users/hp/Desktop/my apps/saadfood/lib/main.dart)**: App ko `ThemeProvider` ke sath connect kiya aur Light/Dark themes define kiye.

### 2. Right Side Menu (Drawer)
- **[home_screen.dart](file:///C:/Users/hp/Desktop/my apps/saadfood/lib/views/home_screen.dart)**:
    - **Right Side Drawer**: Aik naya menu add kiya jo right side se slide hokar aata hai aur aadhi screen (`50% width`) cover karta hai.
    - **Toggle Button**: Drawer mein **"Dark Mode"** ki option di. Jab aap ise click karenge:
        - Light Mode mein **Moon (Chand)** icon dikhega.
        - Dark Mode mein **Sun (Suraj)** icon dikhega.
    - **Bars Icon**: Teen bars wala icon ab Right side par move kar diya gaya hai taake woh Drawer ko open kar sake.

### 3. Theme-Aware Colors
- Humne saari screens (`Cart`, `Checkout`, `Orders`, `Burger Details`, `Location Picker`) ko update kiya hai.
- Hardcoded safaid backgrounds ko **`Theme.of(context).cardColor`** ya **`scaffoldBackgroundColor`** se replace kiya gaya hai taake Dark Mode on hote hi poori app ka rang badal jaye.

## Verification
- [x] Right side bars click karne par menu (drawer) khul raha hai.
- [x] Menu width aadhi screen ke barabar hai.
- [x] Dark mode on karne par background dark ho jata hai aur icons (Sun/Moon) sahi se badal rahe hain.
- [x] Saara text aur cards dark background par wazay nazar aa rahe hain.

> [!TIP]
> Ab aap Home screen par ja kar right side ke menu icon ko click karein aur Dark Mode on/off karke check karein. App ka look foran change ho jayega!
