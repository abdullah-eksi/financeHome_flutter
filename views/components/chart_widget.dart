import 'package:flutter/material.dart';
import 'package:finanshome/models/finance_model.dart';
import 'package:finanshome/utils/formatters.dart';

class ChartWidget extends StatelessWidget {
  final List<ChartData> chartData;
  final String title;

  const ChartWidget({super.key, required this.chartData, required this.title});

  @override
  Widget build(BuildContext context) {
    double total = chartData.fold(0, (sum, item) => sum + item.amount);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (total > 0)
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _PieChart(data: chartData, total: total),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: chartData
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: _LegendItem(
                                    color: item.color,
                                    label: item.category,
                                    amount: item.amount,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'Henüz veri yok',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  final List<ChartData> data;
  final double total;

  const _PieChart({required this.data, required this.total});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PieChartPainter(data: data, total: total),
      child: Container(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double total;

  _PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius =
        (size.width < size.height ? size.width : size.height) / 2 - 8;

    double currentAngle = -90 * (3.14159 / 180);

    for (var item in data) {
      final sweep = (item.amount / total) * 360 * (3.14159 / 180);
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        currentAngle,
        sweep,
        true,
        paint,
      );

      currentAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) => true;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${MoneyFormatter.format(amount)} TL',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
