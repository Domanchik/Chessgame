import 'package:flutter/material.dart';
import '../../../../core/settings/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_rebuild);
  }

  @override
  void dispose() {
    _settings.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121110),
        title: const Text('Настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ─── Тема доски ─────────────────────────────────────────────────
          _SectionHeader(label: 'Тема доски'),
          const SizedBox(height: 16),
          _BoardThemePicker(settings: _settings),
          const SizedBox(height: 32),

          // ─── Язык ────────────────────────────────────────────────────────
          // ─── О приложении ────────────────────────────────────────────────
          _SectionHeader(label: 'О приложении'),
          const SizedBox(height: 16),

          _SettingsCard(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline, color: Color(0xFFD6B37A)),
                  title: Text(
                    'Версия',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    '1.0',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                Divider(
                  color: Color(0xFF3B352F),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                ListTile(
                  leading: Icon(Icons.person_outline, color: Color(0xFFD6B37A)),
                  title: Text(
                    'Разработчик',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Канжарбеков Азамат Медетбекович',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                Divider(
                  color: Color(0xFF3B352F),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                ListTile(
                  leading: Icon(Icons.code, color: Color(0xFFD6B37A)),
                  title: Text(
                    'Технологии',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Flutter • Dart • Minimax AI',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── Прочее ──────────────────────────────────────────────────────
          _SectionHeader(label: 'Игра'),
          const SizedBox(height: 16),
          _SettingsCard(
            child: Column(
              children: [
                _SwitchTile(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Подсказки ходов',
                  subtitle: 'Подсвечивать доступные ходы',
                  value: _settings.showHints,
                  onChanged: (_) => _settings.toggleHints(),
                ),
                _Divider(),
                _SwitchTile(
                  icon: Icons.volume_up_rounded,
                  label: 'Звук',
                  subtitle: 'Звуки ходов и событий',
                  value: _settings.soundEnabled,
                  onChanged: (_) => _settings.toggleSound(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Board Theme Picker ───────────────────────────────────────────────────────

class _BoardThemePicker extends StatelessWidget {
  final AppSettings settings;
  const _BoardThemePicker({required this.settings});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppSettings.boardThemes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final theme = AppSettings.boardThemes[i];
          final selected = settings.boardThemeId == theme.id;

          return GestureDetector(
            onTap: () => settings.setBoardTheme(theme.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF81B64C)
                      : const Color(0xFF3B352F),
                  width: selected ? 2.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  // Мини-превью 4×4 клетки
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: SizedBox(
                      width: double.infinity,
                      height: 72,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4),
                        itemCount: 16,
                        itemBuilder: (_, idx) {
                          final r = idx ~/ 4;
                          final c = idx % 4;
                          final isLight = (r + c) % 2 == 0;
                          return Container(
                              color: isLight ? theme.light : theme.dark);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        theme.label,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF81B64C)
                              : Colors.white54,
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF26231F),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF3B352F)),
    ),
    child: child,
  );
}

class _LangTile extends StatelessWidget {
  final String flag;
  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.flag,
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(flag, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF81B64C))
          : null,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFFD6B37A)),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.white38, fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF81B64C),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
    color: Color(0xFF3B352F),
    height: 1,
    indent: 16,
    endIndent: 16,
  );
}