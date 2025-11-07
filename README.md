# Freelance Companion

A modern Flutter application for freelancers to manage their business operations including time tracking, invoicing, client management, and project tracking.

## Features

### 🎨 Modern Dashboard

- Glass morphism design with backdrop blur effects
- Real-time financial overview with charts
- Smart insights and recommendations
- Recent activity timeline
- Quick action shortcuts

### ⏱️ Time Tracking

- Start/stop timer for projects
- Track billable hours
- View daily and weekly summaries
- Export time reports

### 📄 Invoice Management

- Create and send professional invoices
- PDF generation and export
- Payment tracking
- Invoice status management (draft, sent, paid, overdue)
- Email integration

### 👥 Client Management

- Store client information
- Track client projects
- View client history
- Contact management

### 📁 Project Management

- Create and organize projects
- Link projects to clients
- Track project status
- Monitor project hours

### ⚙️ Settings

- Business information
- Invoice customization
- Notification preferences
- Appearance settings (light/dark mode)

## Tech Stack

- **Framework**: Flutter 3.24+
- **State Management**: Riverpod 3.0
- **Backend**: Supabase
- **Navigation**: GoRouter
- **Charts**: FL Chart
- **PDF Generation**: pdf & printing packages
- **Authentication**: Supabase Auth

## Getting Started

### Prerequisites

- Flutter SDK 3.24.0 or higher
- Dart SDK 3.9.2 or higher
- Android Studio / VS Code
- Supabase account

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/freelance-companion.git
cd freelance-companion
```

2. Install dependencies:

```bash
flutter pub get
```

3. Set up Supabase:

   - Create a new Supabase project
   - Run the SQL script from `supabase_setup.sql`
   - Update Supabase credentials in your app

4. Run the app:

```bash
flutter run
```

## Building

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## CI/CD

This project uses GitHub Actions for continuous integration and deployment:

- **Automatic builds**: APK files are built on every push to main/master/develop branches
- **Artifacts**: Built APKs are available in the Actions tab for 30 days
- **Releases**: Tagged commits (v\*) automatically create GitHub releases with APK files

### Workflow Features

- Code analysis with `flutter analyze`
- Automated testing
- Multi-ABI APK builds
- App Bundle generation
- Artifact uploads

## Project Structure

```
lib/
├── core/
│   ├── router/          # Navigation configuration
│   └── theme/           # App theming
├── features/
│   ├── auth/            # Authentication
│   ├── dashboard/       # Main dashboard
│   ├── time_tracking/   # Time tracking
│   ├── invoices/        # Invoice management
│   ├── clients/         # Client management
│   ├── projects/        # Project management
│   ├── reports/         # Reports and analytics
│   └── settings/        # App settings
└── shared/
    └── widgets/         # Reusable widgets
```

## Database Schema

See `supabase_setup.sql` for the complete database schema including:

- User profiles
- Clients
- Projects
- Time entries
- Invoices
- Payments
- Settings

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- FL Chart for beautiful data visualizations
- The open-source community

## Support

For support, email support@example.com or open an issue in the GitHub repository.

## Roadmap

- [ ] Multi-currency support
- [ ] Recurring invoices
- [ ] Expense tracking
- [ ] Tax calculations
- [ ] Mobile notifications
- [ ] Cloud backup
- [ ] Team collaboration features
- [ ] API integrations (QuickBooks, Stripe, etc.)

---

Built with ❤️ using Flutter
