import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class WeeklyTestPage extends StatefulWidget {
  @override
  _WeeklyTestPageState createState() => _WeeklyTestPageState();
}

class _WeeklyTestPageState extends State<WeeklyTestPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = '';
  final String _correctAnswer = 'cat'; // Example correct answer

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeStt();
  }

  Future<void> _initializeStt() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (errorNotification) => print('onError: $errorNotification'),
    );
    if (!available) {
      print('Speech recognition is not available');
    } else {
      print('Speech recognition available');
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _spokenText = val.recognizedWords;
            print('Recognized words: $_spokenText');
          }),
          listenFor: Duration(seconds: 5),
          pauseFor: Duration(seconds: 3),
          partialResults: true,
          onSoundLevelChange: (level) => print('Sound level: $level'),
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      } else {
        print('The user has denied the use of speech recognition.');
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _checkAnswer() {
    if (_spokenText.toLowerCase() == _correctAnswer.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correct!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/cat.png'), // Replace with your image asset
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text('Check Answer'),
            ),
            SizedBox(height: 20),
            Text(
              'Spoken Text: $_spokenText',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
