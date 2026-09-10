import 'dart:async';
import 'result_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/stats/player_stats.dart';
import '../../../../core/utils/notation.dart';
import '../../logic/ai.dart';
import '../../logic/move_validator.dart';
import '../../models/board.dart';
import '../../models/piece.dart';
import '../widgets/chess_board.dart';
import '../../../../core/localization/app_strings.dart';


class GameScreen extends StatefulWidget {
  final GameArgs args;
  const GameScreen({super.key, required this.args});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? _statusTextOverride;

  final ChessBoard board = ChessBoard();
  final _settings = AppSettings();

  final List<MoveRecord> history = [];
  final List<String> movesText = [];

  PieceColor playerColor = PieceColor.white;
  GameResult _gameResult = GameResult.ongoing;

  Timer? _timer;
  int? _whiteTimeLeft;
  int? _blackTimeLeft;
  final Stopwatch _gameStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_rebuild);
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _settings.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _startNewGame() {
    final color = widget.args.playerColor == 'black'
        ? PieceColor.black
        : widget.args.playerColor == 'random'
        ? (DateTime.now().millisecond.isEven
        ? PieceColor.white
        : PieceColor.black)
        : PieceColor.white;

    _timer?.cancel();

    setState(() {
      playerColor = color;
      board.initializeBoard();
      board.configureGame(
        playerColor: playerColor,
        flipped: playerColor == PieceColor.black,
      );
      history.clear();
      movesText.clear();
      _gameResult = GameResult.ongoing;
      final t = widget.args.timeSeconds;
      _whiteTimeLeft = t;
      _blackTimeLeft = t;
    });

    _gameStopwatch
      ..reset()
      ..start();

    if (widget.args.timeSeconds != null) _startTimer();

    if (playerColor == PieceColor.black) {
      setState(() {
        _statusTextOverride = "🤔 Роберт Полсон думает...";
      });

      Future.delayed(
        Duration(
          milliseconds: 700 + (DateTime.now().millisecond % 400),
        ),
        _doAiMove,
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_gameResult != GameResult.ongoing) {
        _timer?.cancel();
        return;
      }
      setState(() {
        if (board.turn == PieceColor.white) {
          if (_whiteTimeLeft != null && _whiteTimeLeft! > 0) {
            _whiteTimeLeft = _whiteTimeLeft! - 1;
            if (_whiteTimeLeft == 0) _onTimeout(PieceColor.white);
          }
        } else {
          if (_blackTimeLeft != null && _blackTimeLeft! > 0) {
            _blackTimeLeft = _blackTimeLeft! - 1;
            if (_blackTimeLeft == 0) _onTimeout(PieceColor.black);
          }
        }
      });
    });
  }

  void _onTimeout(PieceColor color) {
    _timer?.cancel();
    _gameStopwatch.stop();
    final playerWon = color != playerColor;
    _recordResult(playerWon ? 'win' : 'loss');
    final winner = color == PieceColor.white ? 'Чёрные' : 'Белые';
    _showEndDialog('⏰ Время вышло!', '$winner победили по времени');
  }

  void _pushRecord(MoveRecord rec) {
    history.add(rec);
    movesText.add(Notation.toAlgebraic(rec));
  }

  void _doAiMove() {
    if (!mounted || _gameResult != GameResult.ongoing) return;

    final aiRec = ChessAI.makeMoveAndReturn(board);

    if (aiRec != null) {
      setState(() {
        _pushRecord(aiRec);
        _updateGameResult();
        _statusTextOverride = null;
      });
    }
  }

  void _onPlayerMove(MoveRecord rec) {
    setState(() {
      _pushRecord(rec);
      _updateGameResult();
    });

    if (_gameResult != GameResult.ongoing) return;

    setState(() {
      _statusTextOverride = "Роберт Полсон думает...";
    });

    Future.delayed(
      Duration(
        milliseconds: 700 + (DateTime.now().millisecond % 400),
      ),
      _doAiMove,
    );
  }
  void _updateGameResult() {
    _gameResult = MoveValidator.getGameResult(board, board.turn);
    if (_isGameOver) {
      _timer?.cancel();
      _gameStopwatch.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleGameOver());
    }
  }

  void _handleGameOver() {
    if (_gameResult == GameResult.checkmate) {
      final playerWon = board.turn != playerColor;

      _recordResult(playerWon ? 'win' : 'loss');

      Navigator.pushReplacementNamed(
        context,
        AppRouter.result,
        arguments: ResultArgs(
          win: playerWon,
          draw: false,
          moves: history.length,
          duration: _gameStopwatch.elapsed,
        ),
      );
    }

    else if (_gameResult == GameResult.stalemate) {
      _recordResult('draw');

      Navigator.pushReplacementNamed(
        context,
        AppRouter.result,
        arguments: ResultArgs(
          win: false,
          draw: true,
          moves: history.length,
          duration: _gameStopwatch.elapsed,
        ),
      );
    }
  }

  void _recordResult(String result) {
    final elapsed = _gameStopwatch.elapsed;
    final stats = PlayerStats();
    if (result == 'win') stats.recordWin(history.length, elapsed);
    else if (result == 'loss') stats.recordLoss(history.length, elapsed);
    else stats.recordDraw(history.length, elapsed);
  }

  void _showEndDialog(String title, String subtitle) {
    final stats = PlayerStats();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF26231F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [

                    _resultRow(
                      "Игрок",
                      "Азамат",
                    ),

                    const SizedBox(height: 8),

                    _resultRow(
                      "Бот",
                      "Роберт Полсон",
                    ),

                    const Divider(
                      color: Color(0xFF3B352F),
                      height: 24,
                    ),

                    _resultRow(
                      "Ходов",
                      history.length.toString(),
                    ),

                    const SizedBox(height: 8),

                    _resultRow(
                      "Партий сыграно",
                      stats.totalGames.toString(),
                    ),

                    const SizedBox(height: 8),

                    _resultRow(
                      "Побед",
                      stats.wins.toString(),
                    ),

                    const SizedBox(height: 8),

                    _resultRow(
                      "Поражений",
                      stats.losses.toString(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("В меню"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startNewGame();
                      },
                      child: const Text("Ещё раз"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _undoTwoPlies() {
    setState(() {
      if (_gameResult != GameResult.ongoing) {
        _gameResult = GameResult.ongoing;
        if (widget.args.timeSeconds != null) _startTimer();
      }
      for (int i = 0; i < 2 && history.isNotEmpty; i++) {
        final rec = history.removeLast();
        board.undo(rec);
        movesText.removeLast();
      }
      _gameResult = MoveValidator.getGameResult(board, board.turn);
    });
  }

  bool get _isGameOver =>
      _gameResult == GameResult.checkmate ||
          _gameResult == GameResult.stalemate;

  String get _statusText {

    if (_statusTextOverride != null) {
      return _statusTextOverride!;
    }

    switch (_gameResult) {
      case GameResult.check:
        return board.turn == PieceColor.white
            ? 'Шах белым!'
            : 'Шах чёрным!';

      case GameResult.checkmate:
        return 'Мат!';

      case GameResult.stalemate:
        return 'Пат!';

      case GameResult.ongoing:
        return board.turn == PieceColor.white
            ? 'Ход белых'
            : 'Ход чёрных';
    }
  }

  Color get _statusColor {
    switch (_gameResult) {
      case GameResult.check:      return Colors.orange;
      case GameResult.checkmate:  return Colors.red;
      case GameResult.stalemate:  return Colors.blue;
      case GameResult.ongoing:    return Colors.white60;
    }
  }

  List<_MovePair> get _groupedMoves {
    final result = <_MovePair>[];
    for (int i = 0; i < movesText.length; i += 2) {
      result.add(_MovePair(
        moveNumber: (i ~/ 2) + 1,
        white: movesText[i],
        black: (i + 1 < movesText.length) ? movesText[i + 1] : '',
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = _settings.boardTheme;
    final aiColor = playerColor == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121110),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chess AI: Robert Paulson'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: _SidePanel(
                playerColor: playerColor,
                statusText: _statusText,
                statusColor: _statusColor,
                onUndo: _undoTwoPlies,
                onFlip: () => setState(
                        () => board.isBoardFlipped = !board.isBoardFlipped),
                onNewGame: _startNewGame,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  if (_whiteTimeLeft != null || _blackTimeLeft != null)
                    _TimerBar(
                      timeLeft: aiColor == PieceColor.white
                          ? _whiteTimeLeft
                          : _blackTimeLeft,
                      label: 'Роберт Полсон',
                      active: board.turn == aiColor && !_isGameOver,
                    ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _BoardCard(
                          child: ChessBoardWidget(
                            board: board,
                            enabled: !_isGameOver && board.turn == playerColor,
                            showHints: _settings.showHints,
                            lightColor: theme.light,
                            darkColor: theme.dark,
                            onMoveMade: _onPlayerMove,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_whiteTimeLeft != null || _blackTimeLeft != null)
                    _TimerBar(
                      timeLeft: playerColor == PieceColor.white
                          ? _whiteTimeLeft
                          : _blackTimeLeft,
                      label: 'Ты',
                      active: board.turn == playerColor && !_isGameOver,

                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 240,
              child: _MovesPanel(groupedMoves: _groupedMoves),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  final PieceColor playerColor;
  final String statusText;
  final Color statusColor;
  final VoidCallback onUndo;
  final VoidCallback onFlip;
  final VoidCallback onNewGame;

  const _SidePanel({
    required this.playerColor,
    required this.statusText,
    required this.statusColor,
    required this.onUndo,
    required this.onFlip,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF26231F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B352F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Игра',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _InfoTile(
            icon: Icons.person,
            title: 'Ты',
            subtitle:
            playerColor == PieceColor.white ? 'Белые' : 'Чёрные',
          ),

          const SizedBox(height: 8),

          const _InfoTile(
            icon: Icons.smart_toy_rounded,
            title: 'Роберт Полсон',
            subtitle: '≈1500 Elo • Minimax',
          ),

          const SizedBox(height: 8),

          const _InfoTile(
            icon: Icons.smart_toy_rounded,
            title: 'Бот',
            subtitle: 'Роберт Полсон',
          ),

          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.flag_rounded,
            title: 'Статус',
            subtitle: statusText,
            subtitleColor: statusColor,
          ),

          const Spacer(),
          _ActionBtn(icon: Icons.undo_rounded, label: 'Отменить ход', onTap: onUndo),
          const SizedBox(height: 8),
          _ActionBtn(icon: Icons.flip_rounded, label: 'Повернуть', onTap: onFlip),
          const SizedBox(height: 8),
          _ActionBtn(
              icon: Icons.refresh_rounded,
              label: 'Новая игра',
              onTap: onNewGame,
              primary: true),
        ],
      ),
    );
  }
}

class _TimerBar extends StatelessWidget {
  final int? timeLeft;
  final String label;
  final bool active;

  const _TimerBar({required this.timeLeft, required this.label, required this.active});

  String _format(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isLow = timeLeft != null && timeLeft! <= 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? (isLow
            ? const Color(0xFFCC3333).withOpacity(0.15)
            : const Color(0xFF81B64C).withOpacity(0.1))
            : const Color(0xFF1E1B18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? (isLow ? const Color(0xFFCC3333) : const Color(0xFF81B64C))
              : const Color(0xFF3B352F),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          if (timeLeft != null)
            Text(
              _format(timeLeft!),
              style: TextStyle(
                color: isLow ? const Color(0xFFCC3333) : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _MovesPanel extends StatelessWidget {
  final List<_MovePair> groupedMoves;
  const _MovesPanel({required this.groupedMoves});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF26231F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B352F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('История ходов',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Expanded(
            child: groupedMoves.isEmpty
                ? const Center(
                child: Text('Сделай первый ход',
                    style: TextStyle(color: Colors.white38)))
                : ListView.builder(
              itemCount: groupedMoves.length,
              itemBuilder: (_, i) {
                final m = groupedMoves[i];
                final isLast = i == groupedMoves.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isLast
                        ? const Color(0xFF81B64C).withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text('${m.moveNumber}.',
                            style: const TextStyle(
                                color: Color(0xFFD6B37A),
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                      Expanded(
                          child: Text(m.white,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13))),
                      Expanded(
                          child: Text(m.black,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 13))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardCard extends StatelessWidget {
  final Widget child;
  const _BoardCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF2A2623), Color(0xFF1D1A18)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF4A4038), width: 1.2),
      boxShadow: const [
        BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 8)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: child,
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color subtitleColor;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor = Colors.white60,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1B18),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFD6B37A), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              Text(subtitle,
                  style: TextStyle(color: subtitleColor, fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: primary
        ? ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    )
        : OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    ),
  );
}

class _MovePair {
  final int moveNumber;
  final String white;
  final String black;
  _MovePair({required this.moveNumber, required this.white, required this.black});
}