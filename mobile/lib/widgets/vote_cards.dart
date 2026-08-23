import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_bloc.dart';

class VoteCards extends StatelessWidget {
  final String playerId;
  final ValueChanged<int> onVote;

  const VoteCards({
    super.key,
    required this.playerId,
    required this.onVote,
  });

  static const List<int> fibonacciValues = [
    0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 120),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fibonacciValues.length,
            itemBuilder: (context, index) {
              final value = fibonacciValues[index];
              final isMyVote = state.myVoteValue == value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: GestureDetector(
                  onTap: () => onVote(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isMyVote
                          ? Colors.indigo
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isMyVote
                            ? Colors.indigo.shade700
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isMyVote
                          ? [
                              BoxShadow(
                                color: Colors.indigo.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '$value',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isMyVote
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (isMyVote)
                          const Positioned(
                            top: 2,
                            right: 2,
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
