import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TalkToMePage extends StatefulWidget {
  @override
  _TalkToMePageState createState() => _TalkToMePageState();
}

class _TalkToMePageState extends State<TalkToMePage> {
  final FlutterTts flutterTts = FlutterTts();
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talk to Me'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                labelText: 'Enter text',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _speakText(),
              child: Text('Play'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speakText() async {
    String text = textEditingController.text;
    await flutterTts.speak(text);
  }
}
