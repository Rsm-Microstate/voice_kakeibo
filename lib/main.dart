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

  Widget _buildSummaryRow({
    required String label,
    required String amountText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          amountText,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(
              label: '今日の支出',
              amountText: '¥ 0',
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              label: '今月の支出',
              amountText: '¥ 0',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            // TODO: ここに音声入力開始処理を実装していきます。
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: const Icon(
            Icons.mic,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        const Text('タップして話す'),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSummaryCard(),
        const Spacer(),
        _buildMicButton(),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _buildBody(),
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