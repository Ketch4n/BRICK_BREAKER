import 'package:brick_breaker/src/custom/hallfame.dart';
import 'package:brick_breaker/src/widgets/game_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.score,
  });

  final ValueNotifier<int> score;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: score,
      builder: (context, score, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Score: $score'.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge!,
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Hallfame()));
                  },
                  child: Icon(Icons.leaderboard)),
            ],
          ),
        );
      },
    );
  }
}
