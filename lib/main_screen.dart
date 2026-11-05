import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:thinking_orbs_flutter/thinking_orbs_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  String? _apiKey;
  String _reply = 'Tap the orb and start talking.';
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final apiKey = preferences.getString('openrouter_api_key');

      final speechAvailable = await _speech.initialize(
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _reply = 'Speech recognition error: ${error.errorMsg}';
          });
        },
      );

      await _tts.setLanguage('en-US');

      if (!mounted) return;
      setState(() {
        _apiKey = apiKey;
        _speechAvailable = speechAvailable;
        if (apiKey == null || apiKey.isEmpty) {
          _reply = 'No API key found. Please set up Silly again.';
        } else if (!speechAvailable) {
          _reply = 'Speech recognition is unavailable.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _reply = 'Something went wrong during setup.');