import 'package:flutter/material.dart';
import '../../../../core/stats/player_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = PlayerStats();

    return Scaffold(
      backgroundColor: const Color(0xFF1C1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121110),
        title: const Text('Профиль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ─── Аватар ─────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF26231F),
                    border: Border.all(
                        color: const Color(0xFFD6B37A), width: 2.5),
                  ),
                  child: const Center(
                    child: Text('♔', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Азамат',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Сыграно ${stats.totalGames} партий',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ─── Основная статистика ─────────────────────────────────────────
          _SectionHeader(label: 'Статистика'),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(
                value: '${stats.wins}',
                label: 'Победы',
                color: const Color(0xFF81B64C),
                icon: '🏆',
              ),
              const SizedBox(width: 12),
              _StatCard(
                value: '${stats.losses}',
                label: 'Поражения',
                color: const Color(0xFFCC3333),
                icon: '💀',
              ),
              const SizedBox(width: 12),
              _StatCard(
                value: '${stats.draws}',
                label: 'Ничьи',
                color: const Color(0xFF5B8ED6),
                icon: '🤝',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Доп. статистика ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF26231F),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF3B352F)),
            ),
            child: Column(
              children: [
                _StatRow(
                  label: 'Процент побед',
                  value: '${stats.winRate.toStringAsFixed(1)}%',
                ),
                const _Divider(),
                _StatRow(
                  label: 'Всего ходов сделано',
                  value: '${stats.totalMoves}',
                ),
                const _Divider(),
                _StatRow(
                  label: 'Время в игре',
                  value: stats.totalGames == 0
                      ? '—'
                      : stats.formattedTotalTime,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ─── Прогресс-бар победы ─────────────────────────────────────────
          if (stats.totalGames > 0) ...[
            _SectionHeader(label: 'Соотношение результатов'),
            const SizedBox(height: 16),
            _ResultBar(stats: stats),
            const SizedBox(height: 32),
          ],

          // ─── Пустой экран ────────────────────────────────────────────────
          if (stats.totalGames == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: const [
                    Text('♟', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 16),
                    Text(
                      'Сыграй первую партию!',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  final PlayerStats stats;
  const _ResultBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.totalGames;
    final wFlex = total == 0 ? 1 : stats.wins;
    final dFlex = total == 0 ? 0 : stats.draws;
    final lFlex = total == 0 ? 0 : stats.losses;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                if (wFlex > 0)
                  Expanded(
                    flex: wFlex,
                    child: Container(color: const Color(0xFF81B64C)),
                  ),
                if (dFlex > 0)
                  Expanded(
                    flex: dFlex,
                    child: Container(color: const Color(0xFF5B8ED6)),
                  ),
                if (lFlex > 0)
                  Expanded(
                    flex: lFlex,
                    child: Container(color: const Color(0xFFCC3333)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BarLegend(color: const Color(0xFF81B64C), label: 'Победы'),
            _BarLegend(color: const Color(0xFF5B8ED6), label: 'Ничьи'),
            _BarLegend(color: const Color(0xFFCC3333), label: 'Поражения'),
          ],
        ),
      ],
    );
  }
}

class _BarLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _BarLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }
}

// ─── Вспомогательные виджеты ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: const TextStyle(
      color: Color(0xFFD6B37A),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final String icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF26231F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3B352F)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
    color: Color(0xFF3B352F),
    height: 1,
  );
}