import 'package:shared_preferences/shared_preferences.dart';

class PlayerStats {
  static final PlayerStats _instance = PlayerStats._();
  factory PlayerStats() => _instance;
  PlayerStats._();

  int wins = 0;
  int losses = 0;
  int draws = 0;
  int totalMoves = 0;
  Duration totalPlayTime = Duration.zero;

  String nickname = "Игрок";

  int get totalGames => wins + losses + draws;

  double get winRate =>
      totalGames == 0 ? 0 : (wins / totalGames * 100);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    wins = prefs.getInt('wins') ?? 0;
    losses = prefs.getInt('losses') ?? 0;
    draws = prefs.getInt('draws') ?? 0;
    totalMoves = prefs.getInt('totalMoves') ?? 0;

    print('LOAD WINS: $wins');
    print('LOAD LOSSES: $losses');
    print('LOAD DRAWS: $draws');
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('wins', wins);
    await prefs.setInt('losses', losses);
    await prefs.setInt('draws', draws);
    await prefs.setInt('totalMoves', totalMoves);

    await prefs.setString('nickname', nickname);

    await prefs.setInt(
      'playTime',
      totalPlayTime.inSeconds,
    );
  }

  Future<void> setNickname(String value) async {
    nickname = value.trim();

    if (nickname.isEmpty) {
      nickname = "Игрок";
    }

    await save();
  }

  Future<void> recordWin(int moves, Duration time) async {
    wins++;
    totalMoves += moves;
    totalPlayTime += time;

    await save();
  }

  Future<void> recordLoss(int moves, Duration time) async {
    losses++;
    totalMoves += moves;
    totalPlayTime += time;

    await save();
  }

  Future<void> recordDraw(int moves, Duration time) async {
    draws++;
    totalMoves += moves;
    totalPlayTime += time;

    await save();
  }

  String get formattedTotalTime {
    final h = totalPlayTime.inHours;
    final m = totalPlayTime.inMinutes.remainder(60);

    if (h > 0) {
      return '${h}ч ${m}м';
    }

    return '${m}м';
  }
}