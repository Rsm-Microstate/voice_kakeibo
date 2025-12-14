import 'package:flutter/material.dart';
import '../providers/asset_provider.dart';

class AssetHistoryScreen extends StatelessWidget {
  const AssetHistoryScreen({super.key, required this.history});

  final List<AssetSnapshot> history;

  String _formatYen(int amount) {
    final isNegative = amount < 0;
    final absText = amount.abs().toString();
    final withCommas = absText.replaceAllMapped(
      RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'),
      (match) => '${match[1]},',
    );
    return '${isNegative ? '-' : ''}¥$withCommas';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('総資産推移'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _LineChart(history: history),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: history.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = history[index];
                  return ListTile(
                    title: Text(item.month),
                    trailing: Text(
                      _formatYen(item.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _LineChart extends StatelessWidget {
  const _LineChart({required this.history});

  final List<AssetSnapshot> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('データがありません'));
    }
    return CustomPaint(
      painter: _LineChartPainter(history),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.history);

  final List<AssetSnapshot> history;

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF4F46E5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..color = const Color(0x334F46E5)
      ..style = PaintingStyle.fill;

    final paintPoint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.fill;

    final values = history.map((e) => e.total.toDouble()).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final span = (maxVal - minVal).abs() < 0.1 ? 1.0 : (maxVal - minVal);

    final dx = history.length == 1 ? 0.0 : size.width / (history.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final norm = (values[i] - minVal) / span;
      final y = size.height - norm * size.height;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    for (final p in points) {
      canvas.drawCircle(p, 4, paintPoint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
