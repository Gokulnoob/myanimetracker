# MyAnimeTracker 🎌

A beautiful and modern anime tracking application built with Flutter and Material 3 design. Keep track of your favorite anime, discover new series, and manage your watch lists with an elegant and intuitive interface.

## ✨ Features

### 🏠 **Home Dashboard**

- **Trending Anime**: Discover what's popular right now
- **Seasonal Anime**: Explore anime from the current season
- **Top Rated**: Browse the highest-rated anime of all time
- **Continue Watching**: Quick access to anime you're currently watching
- **Personal Statistics**: Track your anime watching progress

### 🔍 **Advanced Search**

- **Powerful Filters**: Search by genre, status, type, rating, and more
- **Smart Suggestions**: Get recommendations based on your search history
- **Real-time Results**: Instant search with live API integration

### 📝 **List Management**

- **Multiple Lists**: Watching, Completed, Plan to Watch, On Hold, Dropped
- **Progress Tracking**: Track episodes watched and overall progress
- **Personal Ratings**: Rate anime and keep your own scores
- **Smart Organization**: Sort and filter your lists efficiently

### 🎨 **Beautiful Design**

- **Material 3 Design**: Modern, accessible, and beautiful UI
- **Dynamic Theming**: Adapts to your device's theme preferences
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Responsive Layout**: Works great on phones and tablets

### 🚀 **Performance**

- **Offline Support**: View your lists even without internet
- **Smart Caching**: Efficient data storage with Hive
- **Optimized Images**: Fast image loading with caching
- **Smooth Scrolling**: Optimized list rendering for large collections

## 🛠️ Technical Stack

- **Framework**: Flutter 3.27.3
- **State Management**: Riverpod
- **Database**: Hive (Local Storage)
- **API**: Jikan API (MyAnimeList)
- **Design System**: Material 3
- **Architecture**: Clean Architecture with Provider pattern

## 📱 Screenshots

_Coming soon - Screenshots will be added here_

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.27.3 or higher
- Dart SDK 3.6.0 or higher
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/myanimetracker.git
   cd myanimetracker
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate required files**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── core/                   # Core functionality
│   ├── models/            # Data models
│   ├── providers/         # State management
│   ├── services/          # API and local services
│   ├── theme/            # App theming
│   └── utils/            # Utility functions
├── screens/              # App screens
│   ├── home/            # Home dashboard
│   ├── search/          # Search functionality
│   ├── lists/           # List management
│   └── details/         # Anime details
└── widgets/             # Reusable widgets
```

## 🔧 Configuration

The app uses the [Jikan API](https://jikan.moe/) which provides access to MyAnimeList data. No API key is required, but please be respectful of rate limits.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Jikan API](https://jikan.moe/) for providing free access to MyAnimeList data
- [Material Design](https://material.io/) for the beautiful design system
- The Flutter community for amazing packages and resources

## 📞 Contact

Project Link: [https://github.com/yourusername/myanimetracker](https://github.com/yourusername/myanimetracker)

---

**Made with ❤️ and Flutter**
