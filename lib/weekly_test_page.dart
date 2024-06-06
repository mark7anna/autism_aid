import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:googleapis/speech/v1.dart' as speech;
import 'package:googleapis_auth/auth_io.dart';

class WeeklyTestPage extends StatefulWidget {
  @override
  _WeeklyTestPageState createState() => _WeeklyTestPageState();
}

class _WeeklyTestPageState extends State<WeeklyTestPage> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  final String _currentQuestion = 'blah';
  String _recordedAnswer = '';
  String _correctAnswer = 'Paris';
  String _userTranscription = '';

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeRecorder();
    _initializePlayer();
  }

  Future<void> _initializeRecorder() async {
    try {
      final PermissionStatus permissionStatus = await _getPermission();
      if (permissionStatus != PermissionStatus.granted) {
        print('Microphone permission not granted');
        return;
      }
      await _recorder!.openRecorder();
      print('Recorder initialized');
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  Future<void> _initializePlayer() async {
    try {
      await _player!.openPlayer();
      print('Player initialized');
    } catch (e) {
      print('Error initializing player: $e');
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.microphone.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.microphone].request();
      return permissionStatus[Permission.microphone] ?? PermissionStatus.denied;
    } else {
      return permission;
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    super.dispose();
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_currentQuestion.wav';
  }

  Future<void> _recordAudio() async {
    try {
      final path = await _getFilePath();
      await _recorder!.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
      );
      print('Recording started');
      _showRecordingDialog();
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      final path = await _getFilePath();
      print('Recording stopped: $path');
      if (File(path).existsSync()) {
        setState(() {
          _recordedAnswer = path;
        });
      } else {
        print('Recording file not found at path: $path');
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _playRecordedAudio() async {
    try {
      if (_recordedAnswer.isNotEmpty && File(_recordedAnswer).existsSync()) {
        await _player!.startPlayer(
          fromURI: _recordedAnswer,
          codec: Codec.pcm16WAV,
          whenFinished: () {
            setState(() {});
          },
        );
        print('Playback started');
      } else {
        print('No recording found');
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _showRecordingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Recording in Progress'),
          content: Text('Recording your answer.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await _stopRecording();
                Navigator.of(context).pop();
                await _transcribeAudio();
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _transcribeAudio() async {
    final path = await _getFilePath();
    if (!File(path).existsSync()) {
      print('No recording found for transcription');
      return;
    }

    final credentials = ServiceAccountCredentials.fromJson(r'''
{
  "type": "",
  "project_id": "",
  "private_key": "",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/your-service-account-email"
}
''');

    final httpClient = await clientViaServiceAccount(
        credentials, [speech.SpeechApi.cloudPlatformScope]);
    final speechApi = speech.SpeechApi(httpClient);

    final audioBytes = await File(path).readAsBytes();
    final base64Audio = base64Encode(audioBytes);

    final request = speech.RecognizeRequest.fromJson({
      'config': {
        'encoding': 'LINEAR16',
        'sampleRateHertz': 16000,
        'languageCode': 'en-US',
      },
      'audio': {
        'content': base64Audio,
      },
    });

    final response = await speechApi.speech.recognize(request);
    final transcription = response.results!
        .map((result) => result.alternatives!.first.transcript)
        .join(' ');

    setState(() {
      _userTranscription = transcription;
    });

    _compareAnswers();
  }

  void _compareAnswers() {
    if (_userTranscription.toLowerCase() == _correctAnswer.toLowerCase()) {
      print('Correct Answer');
    } else {
      print('Incorrect Answer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Test'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question: $_currentQuestion',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _recordAudio,
              child: Text('Record Answer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playRecordedAudio,
              child: Text('Play Recorded Answer'),
            ),
            SizedBox(height: 20),
            Text(
              'Recorded Answer: $_recordedAnswer',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20),
            Text(
              'Transcription: $_userTranscription',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
