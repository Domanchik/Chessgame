import 'dart:math';
import '../models/board.dart';
import '../models/piece.dart';
import 'move_validator.dart';

class ChessAI {
  static final _rng = Random();
  static const int _searchDepth = 4;

  static MoveRecord? makeMoveAndReturn(ChessBoard board) {
    final aiColor = _aiColor(board);
    if (board.turn != aiColor) return null;

    final moves = _allLegalMoves(board, aiColor);
    if (moves.isEmpty) return null;

    int bestScore = -999999;
    ChessMove? bestMove;

    // Alpha-beta pruning
    for (final move in moves) {
      final rec = board.makeMoveRecord(
        move.sr,
        move.sc,
        move.er,
        move.ec,
      );
      if (rec == null) continue;

      final score = _minimax(
        board,
        _searchDepth - 1,
        false,
        aiColor,
        -999999,
        999999,
      );

      board.undo(rec);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    if (bestMove == null) {
      final fallback = moves[_rng.nextInt(moves.length)];
      return board.makeMoveRecord(
        fallback.sr,
        fallback.sc,
        fallback.er,
        fallback.ec,
      );
    }

    return board.makeMoveRecord(
      bestMove.sr,
      bestMove.sc,
      bestMove.er,
      bestMove.ec,
    );
  }

  static int _minimax(
      ChessBoard board,
      int depth,
      bool isMaximizing,
      PieceColor aiColor,
      int alpha,
      int beta,
      ) {
    if (depth == 0) {
      return _evaluate(board, aiColor);
    }

    final currentColor = board.turn;
    final moves = _allLegalMoves(board, currentColor);

    moves.sort((a, b) {
      final ta = board.board[a.er][a.ec];
      final tb = board.board[b.er][b.ec];

      int va = ta == null ? 0 : _pieceValue(ta.type);
      int vb = tb == null ? 0 : _pieceValue(tb.type);

      return vb.compareTo(va);
    });

    if (moves.isEmpty) {
      if (currentColor == aiColor) {
        return -100000;
      } else {
        return 100000;
      }
    }

    if (isMaximizing) {
      int maxEval = -999999;

      for (final move in moves) {
        final rec = board.makeMoveRecord(
          move.sr,
          move.sc,
          move.er,
          move.ec,
        );
        if (rec == null) continue;

        final eval = _minimax(board, depth - 1, false, aiColor, alpha, beta);
        board.undo(rec);

        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);

        // Beta cut-off
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 999999;

      for (final move in moves) {
        final rec = board.makeMoveRecord(
          move.sr,
          move.sc,
          move.er,
          move.ec,
        );
        if (rec == null) continue;

        final eval = _minimax(board, depth - 1, true, aiColor, alpha, beta);
        board.undo(rec);

        minEval = min(minEval, eval);
        beta = min(beta, eval);

        // Alpha cut-off
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  /// Оценка позиции — учитывает фигуры И их позицию на доске
  static int _evaluate(ChessBoard board, PieceColor aiColor) {
    int score = 0;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.board[r][c];
        if (piece == null) continue;

        final value = _pieceValue(piece.type);
        final positionBonus = _positionBonus(piece, r, c);

        int centerBonus = 0;

        if (c == 3 || c == 4) {
          centerBonus += 20;
        }

        if ((r >= 2 && r <= 5) &&
            (c >= 2 && c <= 5)) {
          centerBonus += 30;
        }

        final totalValue =
            value +
                positionBonus +
                centerBonus;

        if (piece.color == aiColor) {
          score += totalValue;
        } else {
          score -= totalValue;
        }
      }
    }

    // Штраф за открытого короля
    score += _kingOpenness(board, aiColor) * 10;

    final enemy =
    aiColor == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    if (MoveValidator.getGameResult(board, enemy) ==
        GameResult.checkmate) {
      return 100000;
    }

    if (MoveValidator.getGameResult(board, aiColor) ==
        GameResult.checkmate) {
      return -100000;
    }

    if (MoveValidator.isKingInCheck(board, enemy)) {
      score += 500;
    }

    if (MoveValidator.isKingInCheck(board, aiColor)) {
      score -= 5000;
    }

    if (MoveValidator.isKingInCheck(board, enemy)) {
      score += 500;
    }

    if (MoveValidator.isKingInCheck(board, aiColor)) {
      score -= 100000;
    }

    return score;
  }

  /// Базовая стоимость фигуры
  static int _pieceValue(PieceType type) {
    switch (type) {
      case PieceType.pawn:    return 100;
      case PieceType.knight:  return 320;
      case PieceType.bishop:  return 330;
      case PieceType.rook:    return 500;
      case PieceType.queen:   return 1200;
      case PieceType.king:    return 10000;
    }
  }

  /// Бонус за хорошую позицию фигуры
  static int _positionBonus(ChessPiece piece, int r, int c) {

    switch (piece.type) {
      case PieceType.pawn:
      // Пешка ценнее чем дальше продвинулась
        if (piece.color == PieceColor.white) {
          return (6 - r) * 5;
        } else {
          return (r - 1) * 5;
        }

      case PieceType.knight:
      // Конь лучше в центре
        final distFromCenter =
        ((r - 3.5).abs() + (c - 3.5).abs()).ceil();
        return 20 - distFromCenter * 2;

      case PieceType.bishop:
      // Епископ лучше на открытых линиях
        return 10;

      case PieceType.rook:
      // Ладья лучше на 7-й или 2-й линии
        if (piece.color == PieceColor.white && r == 1) return 20;
        if (piece.color == PieceColor.black && r == 6) return 20;
        return 0;

      case PieceType.queen:
        return 0; // Королева хороша везде

      case PieceType.king:
      // Король в начале игры нужно защищать
        if (piece.hasMoved) return 0;
        return 5; // Небольшой бонус за неподвижного короля
    }
  }

  /// Штраф за открытого короля
  static int _kingOpenness(ChessBoard board, PieceColor color) {
    int penalty = 0;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.board[r][c];
        if (piece != null &&
            piece.color == color &&
            piece.type == PieceType.pawn) {
          // Пешки на стартовой позиции защищают короля
          if (color == PieceColor.white && r == 6 ||
              color == PieceColor.black && r == 1) {
            penalty -= 5; // Минус штраф = плюс оценка
          }
        }
      }
    }

    return penalty;
  }

  static PieceColor _aiColor(ChessBoard board) {
    return board.playerColor == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;
  }

  static List<ChessMove> _allLegalMoves(
      ChessBoard board,
      PieceColor color,
      ) {
    final result = <ChessMove>[];

    for (int sr = 0; sr < 8; sr++) {
      for (int sc = 0; sc < 8; sc++) {
        final piece = board.board[sr][sc];
        if (piece == null || piece.color != color) continue;

        for (int er = 0; er < 8; er++) {
          for (int ec = 0; ec < 8; ec++) {

            if (!MoveValidator.isValidMove(
              board,
              sr,
              sc,
              er,
              ec,
            )) {
              continue;
            }

            final rec = board.makeMoveRecord(
              sr,
              sc,
              er,
              ec,
            );

            if (rec == null) continue;

            final kingSafe =
            !MoveValidator.isKingInCheck(
              board,
              color,
            );

            board.undo(rec);

            if (kingSafe) {
              result.add(
                ChessMove(
                  sr,
                  sc,
                  er,
                  ec,
                ),
              );
            }
          }
        }
      }
    }

    return result;
  }
}

class ChessMove {
  final int sr, sc, er, ec;
  ChessMove(this.sr, this.sc, this.er, this.ec);
}