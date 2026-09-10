import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedColor = 'white';
  int? _selectedTime; // null = без лимита

  static const List<_TimeOption> _timeOptions = [
    _TimeOption(label: 'Без лимита', seconds: null, icon: '∞'),
    _TimeOption(label: '1 мин',  seconds: 60,   icon: '⚡'),
    _TimeOption(label: '3 мин',  seconds: 180,  icon: '🔥'),
    _TimeOption(label: '5 мин',  seconds: 300,  icon: '⏱'),
    _TimeOption(label: '10 мин', seconds: 600,  icon: '🕐'),
  ];

  void _startGame() {
    Navigator.pushNamed(
      context,
      AppRouter.game,
      arguments: GameArgs(
        playerColor: _selectedColor,
        timeSeconds: _selectedTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1A17),
      body: Row(
        children: [
          // ─── Боковая панель ──────────────────────────────────────────────
          Container(
            width: 72,
            color: const Color(0xFF121110),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _NavIcon(
                  icon: Icons.home_rounded,
                  label: 'Главная',
                  active: true,
                  onTap: () {},
                ),
                _NavIcon(
                  icon: Icons.person_rounded,
                  label: 'Профиль',
                  onTap: () => Navigator.pushNamed(context, AppRouter.profile),
                ),
                _NavIcon(
                  icon: Icons.settings_rounded,
                  label: 'Настройки',
                  onTap: () => Navigator.pushNamed(context, AppRouter.settings),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.asset(
                    'assets/images/wk.png',
                    width: 36,
                    height: 36,
                  ),
                ),
              ],
            ),
          ),

          // ─── Основной контент ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  const Text(
                    'Chess AI: Robert Paulson',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Сыграй против Роберта Полсона (≈1500 Elo)',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ─── Быстрая игра ────────────────────────────────────────
                  _SectionLabel(label: 'Быстрая игра'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _QuickCard(
                        icon: '♟',
                        title: 'Играть',
                        subtitle: 'Против ИИ',
                        color: const Color(0xFF81B64C),
                        onTap: _startGame,
                      ),
                      const SizedBox(width: 16),
                      _QuickCard(
                        icon: '🎲',
                        title: 'Случайный',
                        subtitle: 'Рандомный цвет',
                        color: const Color(0xFFD6B37A),
                        onTap: () {
                          setState(() => _selectedColor = 'random');
                          _startGame();
                        },
                      ),
                      const SizedBox(width: 16),
                      _QuickCard(
                        icon: '📊',
                        title: 'Профиль',
                        subtitle: 'Статистика',
                        color: const Color(0xFF5B8ED6),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.profile),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // ─── Настройки партии ────────────────────────────────────
                  _SectionLabel(label: 'Настройки партии'),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Выбор цвета
                      Expanded(
                        child: _Card(
                          title: 'Цвет фигур',
                          child: Row(
                            children: [
                              _ColorChoice(
                                label: '♔ Белые',
                                selected: _selectedColor == 'white',
                                onTap: () =>
                                    setState(() => _selectedColor = 'white'),
                              ),
                              const SizedBox(width: 10),
                              _ColorChoice(
                                label: '♚ Чёрные',
                                selected: _selectedColor == 'black',
                                onTap: () =>
                                    setState(() => _selectedColor = 'black'),
                              ),
                              const SizedBox(width: 10),
                              _ColorChoice(
                                label: '🎲 Авто',
                                selected: _selectedColor == 'random',
                                onTap: () =>
                                    setState(() => _selectedColor = 'random'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Выбор времени
                      Expanded(
                        child: _Card(
                          title: 'Контроль времени',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _timeOptions.map((t) {
                              final selected = _selectedTime == t.seconds;
                              return _TimeChip(
                                label: '${t.icon} ${t.label}',
                                selected: selected,
                                onTap: () =>
                                    setState(() => _selectedTime = t.seconds),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Кнопка старта
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF81B64C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('▶  Начать игру'),
                    ),
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

// ─── Виджеты ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFFD6B37A),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF81B64C).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: active ? const Color(0xFF81B64C) : Colors.white38,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF26231F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF3B352F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF26231F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B352F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ColorChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF81B64C).withOpacity(0.2)
              : const Color(0xFF1E1B18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF81B64C)
                : const Color(0xFF3B352F),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF81B64C) : Colors.white54,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFD6B37A).withOpacity(0.15)
              : const Color(0xFF1E1B18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xFFD6B37A)
                : const Color(0xFF3B352F),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFD6B37A) : Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TimeOption {
  final String label;
  final int? seconds;
  final String icon;
  const _TimeOption({
    required this.label,
    required this.seconds,
    required this.icon,
  });
}