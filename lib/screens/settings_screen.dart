import 'package:flutter/material.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    ThemeProvider().isDarkMode().then((value) => setState(() => isDarkMode = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: isDarkMode,
            onChanged: (value) {
              setState(() => isDarkMode = value);
              ThemeProvider().toggleTheme(value);
            },
          ),
          ListTile(
            title: const Text('Buy me a coffee'),
            onTap: () {
              // TODO: Implement Stripe or BuyMeACoffee link
            },
          ),
        ],
      ),
    );
  }
}