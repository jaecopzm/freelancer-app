# Supabase Connection Troubleshooting Guide

## ✅ Fixed Issues

### 1. Android Internet Permission

**Problem**: Android apps need explicit permission to access the internet.

**Solution**: Added to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 2. iOS Network Security

**Problem**: iOS requires App Transport Security (ATS) configuration for network requests.

**Solution**: Added to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>supabase.co</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

## 🔍 Common Issues & Solutions

### Issue 1: "SocketException: Failed host lookup"

**Symptoms**: Cannot connect to Supabase, network errors

**Causes**:

- Missing internet permissions (Android)
- Wrong Supabase URL
- No internet connection
- Firewall blocking requests

**Solutions**:

1. ✅ Verify internet permissions are added (see above)
2. Check Supabase URL in `lib/core/config/supabase_config.dart`
3. Test internet connection on device
4. Try on different network (WiFi vs Mobile Data)

### Issue 2: "Invalid API key"

**Symptoms**: 401 Unauthorized errors

**Causes**:

- Wrong anon key
- Expired key
- Key not matching project

**Solutions**:

1. Go to Supabase Dashboard → Settings → API
2. Copy the correct `anon` key (not service_role key!)
3. Update `lib/core/config/supabase_config.dart`
4. Rebuild the app

### Issue 3: "Row Level Security policy violation"

**Symptoms**: Can't read/write data, permission errors

**Causes**:

- RLS policies not set up correctly
- User not authenticated
- Policies don't match user_id

**Solutions**:

1. Check if user is logged in
2. Verify RLS policies in Supabase Dashboard → Authentication → Policies
3. Ensure policies use `auth.uid()` correctly
4. Run the SQL setup script: `supabase_setup.sql`

### Issue 4: "Table does not exist"

**Symptoms**: Errors about missing tables

**Causes**:

- Database not set up
- Wrong table names
- Migration not run

**Solutions**:

1. Run `supabase_setup.sql` in Supabase SQL Editor
2. Verify table names match your code
3. Check table exists in Supabase Dashboard → Table Editor

### Issue 5: "CORS error" (Web only)

**Symptoms**: CORS policy errors in browser console

**Causes**:

- Supabase CORS not configured for your domain

**Solutions**:

1. Go to Supabase Dashboard → Settings → API
2. Add your domain to allowed origins
3. For local development, add `http://localhost:*`

### Issue 6: Connection works on WiFi but not Mobile Data

**Symptoms**: Works on WiFi, fails on cellular

**Causes**:

- Carrier blocking certain domains
- VPN or proxy issues
- DNS issues

**Solutions**:

1. Try different mobile network
2. Disable VPN if active
3. Use mobile hotspot to test
4. Check if carrier blocks certain ports

### Issue 7: "Certificate verification failed"

**Symptoms**: SSL/TLS errors

**Causes**:

- Device date/time incorrect
- Old Android/iOS version
- Certificate issues

**Solutions**:

1. Check device date and time are correct
2. Update device OS if possible
3. Ensure using HTTPS URL (not HTTP)

## 🧪 Testing Supabase Connection

### Method 1: Add Debug Logging

Add this to your `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔄 Initializing Supabase...');
    print('URL: ${SupabaseConfig.supabaseUrl}');

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: true, // Enable debug mode
    );

    print('✅ Supabase initialized successfully');

    // Test connection
    final response = await Supabase.instance.client
        .from('profiles')
        .select('count')
        .limit(1);

    print('✅ Connection test successful: $response');
  } catch (e, stackTrace) {
    print('❌ Supabase initialization failed: $e');
    print('Stack trace: $stackTrace');
  }

  runApp(const ProviderScope(child: MainApp()));
}
```

### Method 2: Create Test Screen

Create `lib/test/connection_test_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String _status = 'Testing connection...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _status = 'Testing connection...';
      _isLoading = true;
    });

    try {
      // Test 1: Check if Supabase is initialized
      final client = Supabase.instance.client;
      setState(() => _status = '✅ Supabase client initialized\n');

      // Test 2: Try to fetch from a table
      final response = await client
          .from('profiles')
          .select('count')
          .limit(1);

      setState(() {
        _status += '✅ Database connection successful\n';
        _status += 'Response: $response\n';
      });

      // Test 3: Check auth state
      final user = client.auth.currentUser;
      setState(() {
        _status += user != null
            ? '✅ User authenticated: ${user.email}\n'
            : '⚠️ No user authenticated\n';
      });

      setState(() {
        _status += '\n🎉 All tests passed!';
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _status = '❌ Connection failed:\n\n$e\n\nStack trace:\n$stackTrace';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connection Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _status,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testConnection,
              child: const Text('Test Again'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📱 Platform-Specific Checks

### Android

1. **Check Manifest**: Verify internet permissions are present
2. **Check ProGuard**: If using ProGuard, add Supabase rules
3. **Check Network Security Config**: For API level 28+
4. **Test on Real Device**: Emulator might have network issues

### iOS

1. **Check Info.plist**: Verify ATS configuration
2. **Check Signing**: Ensure proper code signing
3. **Check Capabilities**: Network capabilities enabled
4. **Test on Real Device**: Simulator might behave differently

### Web

1. **Check CORS**: Supabase CORS settings
2. **Check Browser Console**: Look for specific errors
3. **Check Service Worker**: Might cache old config
4. **Try Incognito Mode**: Rule out extension issues

## 🔧 Advanced Debugging

### Enable Supabase Debug Mode

In `lib/core/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_URL';
  static const String supabaseAnonKey = 'YOUR_KEY';
  static const bool debugMode = true; // Enable this
}
```

Then in `main.dart`:

```dart
await Supabase.initialize(
  url: SupabaseConfig.supabaseUrl,
  anonKey: SupabaseConfig.supabaseAnonKey,
  debug: SupabaseConfig.debugMode, // Add this
);
```

### Check Supabase Status

Visit: https://status.supabase.com/

### Test with cURL

Test your Supabase endpoint directly:

```bash
curl -X GET 'https://YOUR_PROJECT.supabase.co/rest/v1/profiles?select=count' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

### Check Network Traffic

Use tools like:

- **Android**: Android Studio Network Profiler
- **iOS**: Xcode Network Debugger
- **All**: Charles Proxy or Proxyman

## 📋 Checklist

Before deploying, verify:

- [ ] Internet permissions added (Android)
- [ ] ATS configured (iOS)
- [ ] Correct Supabase URL
- [ ] Correct anon key
- [ ] Database tables created
- [ ] RLS policies set up
- [ ] User can authenticate
- [ ] Tested on real device
- [ ] Tested on WiFi
- [ ] Tested on mobile data
- [ ] Error handling implemented
- [ ] Logging added for debugging

## 🆘 Still Having Issues?

1. **Check Supabase Logs**: Dashboard → Logs
2. **Check Flutter Logs**: `flutter logs`
3. **Test on Different Device**: Rule out device-specific issues
4. **Test Different Network**: Rule out network issues
5. **Verify Supabase Project**: Ensure project is active
6. **Check Billing**: Ensure project hasn't been paused
7. **Contact Support**: Supabase support or Flutter community

## 📚 Useful Resources

- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Troubleshooting](https://supabase.com/docs/guides/platform/troubleshooting)
- [Flutter Network Debugging](https://docs.flutter.dev/development/data-and-backend/networking)
- [Android Network Security](https://developer.android.com/training/articles/security-config)
- [iOS App Transport Security](https://developer.apple.com/documentation/security/preventing_insecure_network_connections)

## 🔄 After Making Changes

Remember to:

1. Stop the app completely
2. Run `flutter clean`
3. Run `flutter pub get`
4. Rebuild the app: `flutter run`
5. Test on a real device (not just emulator)

---

**Most Common Fix**: Adding internet permissions to Android manifest solves 80% of connection issues!
