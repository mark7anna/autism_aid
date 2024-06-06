import 'package:flutter/material.dart';

class PerformanceReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder data for the performance report
    final List<Map<String, dynamic>> performanceData = [
      {'testName': 'Weekly Test 1', 'score': '80%', 'date': '2024-05-10'},
      {'testName': 'Weekly Test 2', 'score': '75%', 'date': '2024-05-17'},
      {'testName': 'Weekly Test 3', 'score': '90%', 'date': '2024-05-24'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Report'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Performance Report',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: performanceData.length,
                itemBuilder: (context, index) {
                  final testData = performanceData[index];
                  return ListTile(
                    title: Text(testData['testName']),
                    subtitle: Text('Score: ${testData['score']}'),
                    trailing: Text('Date: ${testData['date']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
