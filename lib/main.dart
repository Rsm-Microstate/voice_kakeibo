import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'models/expense.dart';
import 'screens/history_screen.dart';
import 'providers/asset_provider.dart'; 
import 'screens/assets_screen.dart'; 


void main() {
  runApp(const VoiceKakeiboApp());
}

class VoiceKakeiboApp extends StatelessWidget {
  const VoiceKakeiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider()..loadExpenses(),
        ),
        ChangeNotifierProvider(
          create: (_) => AssetProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Voice Kakeibo',
        theme: _buildAppTheme(),
        home: const RootScreen(),
      ),
    );
  }

  static ThemeData _buildAppTheme() {
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  bool _isAvailable = false;
  bool _isListening = false;
  String _lastWords = '';

  String _detectAssetId(String text) {
    final lower = text.toLowerCase();
    if (text.contains('現金')) return 'cash';
    if (text.contains('銀行') || text.contains('口座')) return 'bank';
    if (text.contains('ポイント')) return 'points';
    if (lower.contains('cash')) return 'cash';
    if (lower.contains('bank')) return 'bank';
    return 'cash';
  }


  String _formatYen(int amount) {
    final isNegative = amount < 0;
    final absText = amount.abs().toString();
    final withCommas = absText.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '${isNegative ? '-' : ''}¥$withCommas';
  }

  String _detectCategory(String text) {
    final lower = text.toLowerCase();
    final Map<String, String> mapping = {
      '食': '食費',
      '飯': '食費',
      'ランチ': '食費',
      'ディナー': '食費',
      '夕飯': '食費',
      '昼ごはん': '食費',
      '夜ごはん': '食費',
      'ラーメン': '食費',
      'カフェ': '食費',
      'コーヒー': '食費',
      '寿司': '食費',
      'お菓子': '食費',
      'コンビニ': '食費',

      '友達': '交際費',
      '飲み会': '交際費',
      '飲み': '交際費',
      'プレゼント': '交際費',
      'デート': '交際費',

      '電車': '交通費',
      'バス': '交通費',
      'タクシー': '交通費',
      '交通': '交通費',

      '服': '衣料品',
      'シャツ': '衣料品',
      'パンツ': '衣料品',
      '靴': '衣料品',
      'コート': '衣料品',

      '雑費': '雑費',
      '日用品': '雑費',
    };

    for (final entry in mapping.entries) {
      if (text.contains(entry.key) || lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return '雑費';
  }


  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final speech = stt.SpeechToText();
    final available = await speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
      },
      onError: (error) {
        debugPrint('Speech error: $error');
      },
      debugLogging: true,
    );

    setState(() {
      _speech = speech;
      _isAvailable = available;
    });

    debugPrint('Speech initialize available: $available');
  }

  Future<void> _startListening() async {
    if (!_isAvailable) {
      return;
    }
    await _speech.listen(
      localeId: 'ja_JP',
      onResult: (result) {
        final words = result.recognizedWords;
        setState(() {
          _lastWords = words;
        });
        debugPrint('Recognized: $words');

        if (result.finalResult) {
          _saveExpenseFromText(words);
        }
      },
    );
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onMicPressed() {
    if (!_isAvailable) {
      setState(() {
        _lastWords = 'このデバイスでは音声認識を利用できません。';
      });
      return;
    }

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

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

  Widget _buildSummaryCard(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final todayTotal = provider.getTodayTotal();
    final monthTotal = provider.getMonthTotal();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(
              label: '今日の支出',
              amountText: _formatYen(todayTotal),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              label: '今月の支出',
              amountText: _formatYen(monthTotal),
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
          onPressed: _onMicPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isListening ? '聞き取り中...' : 'タップして話す',
        ),
        const SizedBox(height: 8),
        Text(
          _lastWords.isEmpty ? 'まだ何も認識されていません' : _lastWords,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            const sampleText = 'テストで500円使った';
            _saveExpenseFromText(sampleText);
            setState(() {
              _lastWords = sampleText;
            });
          },
          child: const Text('テストで500円追加'),
        ),
      ],
    );
  }
  
  Widget _buildDebugStatus() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('speech available: $_isAvailable'),
        Text('listening: $_isListening'),
      ],
    );
  }
  
  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildSummaryCard(context),
        const Spacer(),
        _buildMicButton(),
        const SizedBox(height: 16),
        _buildDebugStatus(),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _buildBody(context),
    );
  }

  int? _extractAmount(String text) {
    final cleaned = text.replaceAll(RegExp(r'[,\s，]'), '');
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(cleaned);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }

    if (text.contains('万')) return 10000;
    if (text.contains('千')) return 1000;
    if (text.contains('百')) return 100;
    return null;
  }

  void _saveExpenseFromText(String text) {
    final amount = _extractAmount(text);
    if (amount == null) {
      return;
    }

    final expense = Expense.create(
      amount: amount,
      category: _detectCategory(text),
      memo: text,
    );

    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final assetProvider = Provider.of<AssetProvider>(
      context,
      listen: false,
    );
    expenseProvider.addExpense(expense);
    final assetId = _detectAssetId(text);
    assetProvider.decreaseAsset(assetId, amount);
  }
}
