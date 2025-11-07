# User Profile Display Logic

## Dashboard Greeting

The dashboard now intelligently displays the user's name fetched from the Supabase database with a smart fallback system.

## Display Name Priority

The system uses the following priority to determine what name to display:

1. **Full Name** (`full_name` field)

   - If the user has set their full name in their profile, this is displayed
   - Example: "Good morning, John Doe! 👋"

2. **Business Name** (`business_name` field)

   - If no full name is set, but a business name exists, it's used
   - Example: "Good afternoon, Acme Consulting! 👋"

3. **Email Username** (part before @)

   - If neither full name nor business name is set, extracts the username from email
   - Example: "Good evening, john.doe! 👋"

4. **Fallback** ("User")
   - Only shown if profile is completely unavailable
   - Example: "Good morning, User! 👋"

## Business Name Display

If a business name is set in the profile, it's displayed as a subtitle below the greeting in the primary color:

```
Good morning, John Doe! 👋
Acme Consulting LLC
Friday, November 7, 2025
```

## Data Source

The user profile is fetched from Supabase using the `userProfileProvider`:

```dart
final userProfile = ref.watch(userProfileProvider);
```

This provider:

- Automatically fetches data from the `profiles` table
- Caches the result
- Refreshes when auth state changes
- Returns a `UserProfile?` object

## User Profile Model

The `UserProfile` model includes:

```dart
class UserProfile {
  final String id;
  final String email;
  final String? fullName;        // Used for greeting
  final String? businessName;    // Used as fallback and subtitle
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final String? timezone;
  final String? currency;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

## Time-Based Greeting

The greeting changes based on the time of day:

- **Morning** (00:00 - 11:59): "Good morning"
- **Afternoon** (12:00 - 16:59): "Good afternoon"
- **Evening** (17:00 - 23:59): "Good evening"

## Updating User Profile

Users can update their profile information in the Settings screen:

1. Navigate to Settings
2. Go to Business Settings
3. Update Full Name or Business Name
4. Changes are saved to Supabase
5. Dashboard automatically refreshes to show new name

## Database Schema

The profile data is stored in the `profiles` table in Supabase:

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  full_name TEXT,
  business_name TEXT,
  -- other fields...
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);
```

## Implementation Details

### Welcome Card Component

```dart
Widget _buildWelcomeCard(BuildContext context, UserProfile? profile) {
  // Time-based greeting
  final hour = DateTime.now().hour;
  String greeting = hour < 12 ? 'Good morning'
    : hour < 17 ? 'Good afternoon'
    : 'Good evening';

  // Smart name selection
  String displayName = 'User';
  if (profile != null) {
    if (profile.fullName != null && profile.fullName!.isNotEmpty) {
      displayName = profile.fullName!;
    } else if (profile.businessName != null && profile.businessName!.isNotEmpty) {
      displayName = profile.businessName!;
    } else {
      displayName = profile.email.split('@').first;
    }
  }

  return _GlassCard(
    child: // ... greeting display
  );
}
```

## Testing

To test the display logic:

1. **With Full Name**: Set full_name in database → Shows full name
2. **Without Full Name**: Clear full_name, set business_name → Shows business name
3. **Email Only**: Clear both → Shows email username
4. **No Profile**: Simulate null profile → Shows "User"

## Future Enhancements

- [ ] Add user avatar display
- [ ] Show last login time
- [ ] Display user role/subscription tier
- [ ] Add profile completion percentage
- [ ] Show personalized tips based on profile data
