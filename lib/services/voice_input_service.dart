import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class VoiceInputService {
  static final VoiceInputService _instance = VoiceInputService._internal();
  factory VoiceInputService() => _instance;
  VoiceInputService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  bool get isPlatformSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<bool> initialize() async {
    if (!isPlatformSupported) {
      return false;
    }

    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }

  Future<String?> startListening() async {
    if (!_isInitialized) await initialize();
    String? recognizedText;

    if (!_speech.isListening) {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            recognizedText = result.recognizedWords;
          }
        },
      );

      // Wait for the recognition to complete
      await Future.delayed(const Duration(seconds: 5));
      stopListening(); // Remove await here since stopListening() returns void
      return recognizedText;
    }
    return null;
  }

  void stopListening() {
    _speech.stop();
  }

  bool get isListening => _speech.isListening;

  Map<String, dynamic> parseClientDescription(String text) {
    final Map<String, dynamic> result = {};

    // Parse name
    final nameMatch = RegExp(r'name is (\w+)').firstMatch(text);
    if (nameMatch != null) {
      result['name'] = nameMatch.group(1);
    }

    // Parse email
    final emailMatch = RegExp(r'email is ([^\s]+@[^\s]+)').firstMatch(text);
    if (emailMatch != null) {
      result['email'] = emailMatch.group(1);
    }

    // Parse phone
    final phoneMatch = RegExp(r'phone is (\d+)').firstMatch(text);
    if (phoneMatch != null) {
      result['phone'] = phoneMatch.group(1);
    }

    // Parse budget
    final budgetMatch = RegExp(r'budget (?:is |of )?(\d+)').firstMatch(text);
    if (budgetMatch != null) {
      result['budgetMax'] = double.tryParse(budgetMatch.group(1)!);
    }

    // Parse square meters
    final metersMatch = RegExp(r'(\d+) square meters').firstMatch(text);
    if (metersMatch != null) {
      result['minSquareMeters'] = double.tryParse(metersMatch.group(1)!);
    }

    // Parse locations
    if (text.contains('location')) {
      final locations = text
          .split('location is ')[1]
          .split(' and ')[0]
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (locations.isNotEmpty) {
        result['preferredLocations'] = locations;
      }
    }

    // Parse rooms
    final roomsMatch = RegExp(r'(\d+) rooms').firstMatch(text);
    if (roomsMatch != null) {
      result['preferredRooms'] = [int.parse(roomsMatch.group(1)!)];
    }

    // Parse property type
    final propertyTypes = ['apartment', 'house', 'villa', 'penthouse'];
    for (final type in propertyTypes) {
      if (text.toLowerCase().contains(type)) {
        result['propertyTypes'] = [type];
        break;
      }
    }

    // Parse notes
    if (text.contains('notes')) {
      final notes = text.split('notes are ')[1].trim();
      result['notes'] = notes;
    }

    return result;
  }
}
