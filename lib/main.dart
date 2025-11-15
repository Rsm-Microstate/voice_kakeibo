import 'package:flutter/material.dart';

void main() {
  runApp(const VoiceKakeiboApp());
}

class VoiceKakeiboApp extends StatelessWidget {
  const VoiceKakeiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Kakeibo',
      theme: _buildAppTheme(),
      home: const RootScreen(),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
      ),
      useMaterial3: true,
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() {
    return _RootScreenState();
  }
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return const HomeScreen();
    }
    if (_currentIndex == 1) {
      return const HistoryScreen();
    }
    return const AssetsScreen();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Voice Kakeibo'),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.mic),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Assets',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Text _buildMessage() {
    return const Text(
      'Home: 音声入力と今日のサマリーを\nここに実装していきます。',
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildMessage(),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Text _buildMessage() {
    return const Text(
      'History: 支出の履歴一覧を\nここに実装していきます。',
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildMessage(),
    );
  }
}

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  Text _buildMessage() {
    return const Text(
      'Assets: 資産サマリー（銀行・PayPayなど）を\nここに実装していきます。',
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildMessage(),
    );
  }
}