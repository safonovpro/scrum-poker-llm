import 'package:flutter/material.dart';

class RevealPanel extends StatelessWidget {
  final List<Map<String, dynamic>> votes;

  const RevealPanel({super.key, required this.votes});

  @override
  Widget build(BuildContext context) {
    final values = votes
        .map((v) => v['value'] as int?)
        .where((v) => v != null)
        .cast<int>()
        .toList();

    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final sum = values.fold(0, (a, b) => a + b);
    final average = sum / values.length;
    final sorted = List<int>.from(values)..sort();
    final min = sorted.first;
    final max = sorted.last;
    final median = values.length % 2 == 0
        ? (sorted[values.length ~/ 2 - 1] + sorted[values.length ~/ 2]) / 2
        : sorted[values.length ~/ 2];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Результаты',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // Таблица голосов
            ...votes.map((v) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(v['player_nickname'] as String),
                      Text(
                        '${v['value']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 24),
            // Статистика
            _statRow('Среднее', average.toStringAsFixed(1)),
            _statRow('Медиана', median.toStringAsFixed(1)),
            _statRow('Мин', '$min'),
            _statRow('Макс', '$max'),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
