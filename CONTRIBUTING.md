# Contributing to MyAnimeTracker

Thank you for considering contributing to MyAnimeTracker! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.27.3 or higher
- Dart SDK 3.6.0 or higher
- Git
- Android Studio or VS Code with Flutter extension

### Setting Up Development Environment

1. **Fork the repository**

   ```bash
   git clone https://github.com/yourusername/myanimetracker.git
   cd myanimetracker
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Set up pre-commit hooks** (optional but recommended)
   ```bash
   # Format code before commits
   git config core.hooksPath .githooks
   ```

## 🏗️ Project Structure

```
lib/
├── core/                   # Core functionality
│   ├── models/            # Data models (Hive models)
│   ├── providers/         # Riverpod providers
│   ├── services/          # API and local services
│   ├── theme/            # Material 3 theming
│   └── utils/            # Utility functions
├── screens/              # App screens
│   ├── home/            # Home dashboard
│   ├── search/          # Search functionality
│   ├── lists/           # List management
│   └── details/         # Anime details
└── widgets/             # Reusable widgets
```

## 📝 Development Guidelines

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format your code
- Run `flutter analyze` to check for issues
- Maximum line length: 120 characters

### State Management

- Use **Riverpod** for state management
- Create providers in `lib/core/providers/`
- Follow the established provider patterns
- Use `AsyncNotifier` for async operations

### API Integration

- All API calls go through `JikanService`
- Use proper error handling with try-catch
- Implement offline fallbacks where possible
- Respect API rate limits

### UI/UX Guidelines

- Follow **Material 3** design principles
- Use the established theme from `app_theme.dart`
- Ensure accessibility (proper semantics, contrast)
- Test on different screen sizes
- Implement proper loading states and error handling

### Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Aim for meaningful test coverage
- Place tests in `test/` directory

## 🔧 Making Changes

### Branch Naming

- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `hotfix/description` - Critical fixes
- `refactor/description` - Code refactoring
- `docs/description` - Documentation updates

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat(search): add genre filtering
fix(home): resolve overflow in anime cards
docs(readme): update installation instructions
refactor(providers): simplify anime list provider
```

### Pull Request Process

1. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**

   - Write clean, well-documented code
   - Add tests for new functionality
   - Update documentation if needed

3. **Test your changes**

   ```bash
   flutter test
   flutter analyze
   dart format .
   ```

4. **Commit your changes**

   ```bash
   git add .
   git commit -m "feat(scope): your description"
   ```

5. **Push and create PR**

   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Use the PR template
   - Link relevant issues
   - Add screenshots for UI changes
   - Request review from maintainers

### PR Requirements

- [ ] Code follows project style guidelines
- [ ] All tests pass
- [ ] No analyzer warnings
- [ ] Documentation updated (if needed)
- [ ] Screenshots included (for UI changes)
- [ ] Breaking changes documented

## 🐛 Bug Reports

When reporting bugs, please include:

- **Device/Platform**: iOS 17, Android 14, etc.
- **Flutter Version**: Run `flutter --version`
- **Steps to Reproduce**: Clear step-by-step instructions
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Screenshots**: If applicable
- **Logs**: Any relevant error messages

## 💡 Feature Requests

For feature requests, please:

- Check if the feature already exists
- Search existing issues to avoid duplicates
- Provide clear use cases and motivation
- Consider implementation complexity
- Be open to discussion and feedback

## 🏷️ Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements to docs
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `priority-high` - Critical issues
- `priority-low` - Nice to have features

## 🤝 Code Review Process

1. **Automated Checks**: CI/CD pipeline runs tests and analysis
2. **Peer Review**: At least one maintainer reviews the PR
3. **Testing**: Changes are tested on different devices/platforms
4. **Documentation**: Ensure docs are updated if needed
5. **Approval**: PR is approved and merged

## 📚 Resources

### Flutter Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Material 3 Guidelines](https://m3.material.io/)

### Project-Specific Resources

- [Jikan API Documentation](https://docs.api.jikan.moe/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Hive Documentation](https://docs.hivedb.dev/)

## 📞 Getting Help

- **GitHub Discussions**: For general questions and discussions
- **GitHub Issues**: For bugs and feature requests
- **Discord**: [Project Discord Server] (if applicable)

## 🙏 Recognition

Contributors will be recognized in:

- README.md contributors section
- CHANGELOG.md for significant contributions
- GitHub releases for major features

Thank you for contributing to MyAnimeTracker! 🎌
