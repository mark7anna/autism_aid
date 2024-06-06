import 'package:flutter/material.dart';
import 'EditProfilePage.dart';
import 'weekly_test_page.dart';
import 'performance_report_page.dart';
import 'snap_it_page.dart';
import 'talk_to_me_page.dart';
import 'about.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Stack(
        children: [
          _buildPanel(0),
          _buildPanel(1),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(int index) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: _selectedIndex == index
          ? _buildPanelContent(index)
          : SizedBox.shrink(),
    );
  }

  Widget _buildPanelContent(int index) {
    switch (index) {
      case 0:
        return LeftPanel();
      case 1:
        return MiddlePanel();
      case 2:
        return RightPanel();
      default:
        return SizedBox.shrink();
    }
  }
}

class LeftPanel extends StatelessWidget {
  const LeftPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hintColor: Colors.blue,
      ),
      child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          children: [
            Text('Left Panel', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            _buildImageButton(
              context,
              'Talk to Me',
              TalkToMePage(),
              'assets/talktome.png',
            ),
            SizedBox(height: 10),
            _buildImageButton(
              context,
              'Snap It',
              SnapItPage(),
              'assets/snapit.png',
            ),
            SizedBox(height: 10),
            _buildImageButton(
              context,
              'Weekly Test',
              WeeklyTestPage(),
              'assets/test.png',
            ),
            SizedBox(height: 10),
            _buildImageButton(
              context,
              'Performance Report',
              PerformanceReportPage(),
              'assets/report.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton(
    BuildContext context,
    String label,
    Widget page,
    String imagePath,
  ) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.blue,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiddlePanel extends StatelessWidget {
  const MiddlePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hintColor: Colors.blue,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
              child: Text('About'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class RightPanel extends StatelessWidget {
  const RightPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hintColor: Colors.blue,
      ),
      child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          children: [
            Center(
              child: Text('Right Panel', style: TextStyle(fontSize: 20)),
            ),
            SizedBox(height: 20),
            Center(
              child: Text('User Profile Content'),
            ),
            SizedBox(height: 10),
            _buildEditProfileButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfilePage()),
          );
        },
        child: Text('Edit Profile'),
      ),
    );
  }
}
