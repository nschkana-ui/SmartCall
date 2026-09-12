# SmartCall 📞

A Flutter dialer and voicemail application with intelligent call management and voice message handling.

## Features

✨ **Keypad Dialing**
- Numeric keypad (0-9, *, #) with letter labels
- Direct phone call launching
- Real-time number display
- Easy deletion with backspace

🎙️ **Voicemail Management**
- View voicemail messages with caller details
- Play/pause audio messages
- Transcribed message text
- Caller information and timestamps

🎨 **UI/UX**
- Material 3 design
- Marathi language support
- Clean, intuitive interface
- Bottom navigation for easy access

## Dependencies

- `flutter` - UI framework
- `url_launcher: ^6.3.0` - Launch phone calls
- `audioplayers: ^6.0.0` - Audio playback

## Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio or Xcode for emulator/device setup

### Installation

```bash
# Clone the repository
git clone https://github.com/nschkana-ui/SmartCall.git
cd SmartCall

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── main.dart              # Main app file with all components
├── widgets/
│   ├── keypad_view.dart   # Dialing keypad screen
│   └── voicemail_view.dart # Voicemail management screen
pubspec.yaml              # Project dependencies
```

## Usage

### Making a Call
1. Navigate to the **डायलपॅड** (Keypad) tab
2. Tap the digit buttons to enter a phone number
3. Press the green **call button** to initiate the call
4. Use the **backspace button** to delete the last digit

### Listening to Voicemail
1. Navigate to the **व्हॉईसमेल** (Voicemail) tab
2. Select a message from the list
3. Tap the **play button** to listen to the audio
4. Tap again to pause

## Platform Support

- ✅ Android
- ✅ iOS
- 🔄 Web (partial support)

## License

MIT License - Feel free to use and modify this project.

## Author

Created by **nschkana-ui**

---

**Enjoy using SmartCall!** 🚀
