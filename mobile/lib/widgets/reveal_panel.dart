import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class RevealPanel extends StatefulWidget {
  final List<Map<String, dynamic>> votes;

  const RevealPanel({super.key, required this.votes});

  @override
  State<RevealPanel> createState() => _RevealPanelState();
}

class _RevealPanelState extends State<RevealPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_values.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.results,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...widget.votes.map((v) => Padding(
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
              _statRow(l10n.average, _average.toStringAsFixed(1)),
              _statRow(l10n.median, _median.toStringAsFixed(1)),
              _statRow(l10n.min, '$_min'),
              _statRow(l10n.max, '$_max'),
            ],
          ),
        ),
      ),
    );
  }

  List<int> get _values {
    return widget.votes
        .map((v) => v['value'] as int?)
        .whereType<int>()
        .toList();
  }

  int get _min {
    if (_values.isEmpty) return 0;
    final sorted = List<int>.from(_values)..sort();
    return sorted.first;
  }

  int get _max {
    if (_values.isEmpty) return 0;
    final sorted = List<int>.from(_values)..sort();
    return sorted.last;
  }

  double get _average {
    if (_values.isEmpty) return 0;
    return _values.fold(0, (a, b) => a + b) / _values.length;
  }

  double get _median {
    if (_values.isEmpty) return 0;
    final sorted = List<int>.from(_values)..sort();
    if (sorted.length % 2 == 0) {
      return (sorted[sorted.length ~/ 2 - 1] + sorted[sorted.length ~/ 2]) / 2;
    }
    return sorted[sorted.length ~/ 2].toDouble();
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
