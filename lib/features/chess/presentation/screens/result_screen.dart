import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';

class ResultArgs {
  final bool win;
  final bool draw;
  final int moves;
  final Duration duration;

  const ResultArgs({
    required this.win,
    required this.draw,
    required this.moves,
    required this.duration,
  });
}

class ResultScreen extends StatelessWidget {
  final ResultArgs args;

  const ResultScreen({
    super.key,
    required this.args,
  });

  String get _title {
    if (args.draw) return '🤝 Ничья';
    return args.win ? '🏆 Победа' : '💀 Поражение';
  }

  String get _subtitle {
    if (args.draw) {
      return 'Партия завершилась вничью';
    }

    return args.win
        ? 'Ты победил Роберта Полсона'
        : 'Роберт Полсон победил';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1A17),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF26231F),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF3B352F),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              _InfoRow(
                label: 'Ходов',
                value: '${args.moves}',
              ),

              const SizedBox(height: 8),

              _InfoRow(
                label: 'Время',
                value:
                '${args.duration.inMinutes} мин ${args.duration.inSeconds.remainder(60)} сек',
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.home,
                          (route) => false,
                    );
                  },
                  child: const Text('В главное меню'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}