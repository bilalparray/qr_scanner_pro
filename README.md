# QR & Barcode Scanner Flutter App

A modern, fast, and feature-rich **Flutter app** for scanning and generating QR codes and barcodes.  
Supports navigation with GoRouter, scan via camera or gallery, local history, settings, and more.

## Features

- Scan QR codes and various barcode types using your device’s camera.
- Scan a code directly from an image in your gallery.
- Generate QR codes and 1D/2D barcodes with customization.
- Save generated codes as images or share them instantly.
- View full scan and generate history in-app.
- User-friendly navigation with App Drawer and GoRouter.
- Material 3 theme, responsive design.
- Ad support (optionally), settings screen, privacy policy, etc.

---

## Getting Started

### Prerequisites

- **Flutter SDK** (3.13+ recommended)
- Dart 3+
- Android SDK/iOS tools as needed

### Installation

1. **Clone the repo**

   ```
   git clone https://github.com/bilalparray/qr_scanner_generator.git
   navigate to folder
   ```

2. **Install dependencies**

   ```
   flutter pub get
   ```

3. **(Android) Configure Permissions**

   _In `android/app/src/main/AndroidManifest.xml`:_

   ```
   <uses-permission android:name="android.permission.CAMERA"/>
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>

   ```

4. **(iOS) Configure Permissions**

   _In `ios/Runner/Info.plist`:_

   ```
   <key>NSCameraUsageDescription</key>
   <string>This app requires camera access for scanning codes.</string>
   <key>NSPhotoLibraryAddUsageDescription</key>
   <string>This app saves barcode images to your photo gallery.</string>
   ```

5. **Run the app**

   ```
   flutter run
   ```

---

## Main Packages Used

- [`go_router`](https://pub.dev/packages/go_router) – declarative and type-safe navigation
- [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) – camera and barcode scanning
- [`qr_flutter`](https://pub.dev/packages/qr_flutter) – QR code generation
- [`syncfusion_flutter_barcodes`](https://pub.dev/packages/syncfusion_flutter_barcodes) – 1D/2D barcode widgets
- [`image_picker`](https://pub.dev/packages/image_picker) – gallery upload for image scanning
- [`provider`](https://pub.dev/packages/provider) – state management
- [`path_provider`](https://pub.dev/packages/path_provider), [`permission_handler`](https://pub.dev/packages/permission_handler)
- [`google_mobile_ads`](https://pub.dev/packages/google_mobile_ads) – (optional) ad display

---

## Key Navigation Routes

| Route                     | Screen          | Description                         |
| ------------------------- | --------------- | ----------------------------------- |
| `/`                       | HomeScreen      | App home/landing page               |
| `/scan`                   | ScanScreen      | Camera or gallery scan page         |
| `/scan?startGallery=true` | ScanScreen      | Scan page auto-opens gallery picker |
| `/generate`               | BarcodeHomePage | Barcode/QR code generator           |
| `/history`                | HistoryPage     | Scan & generate history             |
| `/settings`               | SettingsPage    | Settings                            |

---

## Usage Examples

- **Scan from camera**: Tap "Scan" in the drawer/app bar.
- **Scan from gallery**:
  - Use the "Scan from Gallery" option in the drawer (navigates to `/scan?startGallery=true`).
  - The scan page will immediately prompt you to pick an image from your gallery.
- **Generate code**: Tap "Generate Barcode" in the drawer, enter details, and customize.
- **Save/share**: Save codes as images or share them instantly from preview screens.
- **View history**: Access full scan/generation history, re-share or download as needed.

---

## Code Quality & Structure

- Each route declared in [`lib/app_routes.dart`](lib/app_routes.dart)
- Modular widgets for fields, customization, preview, download, etc.
- ScanScreen supports both live camera and gallery import, with correct buffer management and no camera leaks.
- Drawer navigation protected against context/locking errors.

---

## Frequently Asked Questions

**Q: I get "no routes for location X"?**  
A: Add every destination route to your GoRouter in `app_routes.dart`.

**Q: Why doesn't "Scan from Gallery" open picker again if already on scan page?**  
A: Use `context.push('/scan?startGallery=true')` (not `context.go`) to always push a new screen.

**Q: I'm seeing "Unable to acquire a buffer item..." warnings!**  
A: Handled automatically: camera stream is stopped during heavy operations to free buffers.

---

## Contributions

PRs and issues welcome!  
See [CONTRIBUTING.md](CONTRIBUTING.md) if present, or open an issue with your feature or bug request.

---

## License

MIT (or your chosen license)

---

## Credits

- [Syncfusion](https://www.syncfusion.com/flutter-widgets/flutter-barcode-generator)
- [Google ML Kit](https://pub.dev/packages/mobile_scanner)
- [Flutter Community](https://flutter.dev/)
