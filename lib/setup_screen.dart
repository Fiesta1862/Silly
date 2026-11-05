import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _apiKeyController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your OpenRouter API key.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('openrouter_api_key', apiKey);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const MainScreen(),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your API key.')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.graphic_eq,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Set up Silly',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your OpenRouter API key to get started.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: const InputDecoration(
                      labelText: 'OpenRouter API key',
                      hintText: 'sk-or-...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _saveApiKey(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isSaving ? null : _saveApiKey,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save and continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}