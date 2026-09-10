import '../models/board.dart';
import '../models/piece.dart';

class MoveValidator {
  static bool isValidMove(
      ChessBoard board,
      int sr,
      int sc,
      int er,
      int ec,
      ) {
    if (!_inBounds(sr, sc) || !_inBounds(er, ec)) return false;
    if (sr == er && sc == ec) return false;

    final piece = board.board[sr][sc];
    if (piece == null) return false;

    final target = board.board[er][ec];
    if (target != null && target.color == piece.color) return false;

    final dr = er - sr;
    final dc = ec - sc;

    bool basicOk;

    switch (piece.type) {
      case PieceType.pawn:
        basicOk = _pawn(board, piece, sr, sc, er, ec, dr, dc, target);
        break;

      case PieceType.rook:
        basicOk = (dr == 0 || dc == 0) && _clearPath(board, sr, sc, er, ec);
        break;

      case PieceType.knight:
        basicOk = (dr.abs() == 2 && dc.abs() == 1) ||
            (dr.abs() == 1 && dc.abs() == 2);
        break;

      case PieceType.bishop:
        basicOk = dr.abs() == dc.abs() && _clearPath(board, sr, sc, er, ec);
        break;

      case PieceType.queen:
        basicOk = (dr == 0 || dc == 0 || dr.abs() == dc.abs()) &&
            _clearPath(board, sr, sc, er, ec);
        break;

      case PieceType.king:
        if (dr == 0 && dc.abs() == 2) {
          basicOk = _castlingValid(board, piece, sr, sc, ec);
        } else {
          basicOk = dr.abs() <= 1 && dc.abs() <= 1;
        }
        break;
    }

    if (!basicOk) return false;

    // После хода наш король не должен быть под шахом
    return !_moveLeavesKingInCheck(board, sr, sc, er, ec, piece.color);
  }

  // ─── Рокировка ──────────────────────────────────────────────────────────────

  static bool _castlingValid(
      ChessBoard board,
      ChessPiece king,
      int sr,
      int sc,
      int ec,
      ) {
    if (king.hasMoved) return false;
    if (isKingInCheck(board, king.color)) return false;

    final rookCol = ec == 6 ? 7 : 0;
    final rook = board.board[sr][rookCol];
    if (rook == null ||
        rook.type != PieceType.rook ||
        rook.color != king.color ||
        rook.hasMoved) return false;

    // Путь между королём и ладьёй должен быть чист
    final minC = sc < rookCol ? sc + 1 : rookCol + 1;
    final maxC = sc < rookCol ? rookCol - 1 : sc - 1;
    for (int c = minC; c <= maxC; c++) {
      if (board.board[sr][c] != null) return false;
    }

    // Король не проходит через атакованную клетку
    final step = ec > sc ? 1 : -1;
    for (int c = sc; c != ec + step; c += step) {
      if (_squareAttacked(board, sr, c, king.color)) return false;
    }

    return true;
  }

  // ─── Шах ────────────────────────────────────────────────────────────────────

  static bool isKingInCheck(ChessBoard board, PieceColor color) {
    int? kr, kc;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board.board[r][c];
        if (p != null && p.color == color && p.type == PieceType.king) {
          kr = r;
          kc = c;
        }
      }
    }
    if (kr == null || kc == null) return false;
    return _squareAttacked(board, kr, kc, color);
  }

  static bool _squareAttacked(
      ChessBoard board, int tr, int tc, PieceColor color) {
    final enemy =
    color == PieceColor.white ? PieceColor.black : PieceColor.white;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board.board[r][c];
        if (p == null || p.color != enemy) continue;
        if (_attacksSquare(board, p, r, c, tr, tc)) return true;
      }
    }
    return false;
  }

  static bool _attacksSquare(
      ChessBoard board, ChessPiece p, int sr, int sc, int tr, int tc) {
    final dr = tr - sr;
    final dc = tc - sc;

    switch (p.type) {
      case PieceType.pawn:
        final dir = p.color == PieceColor.white ? -1 : 1;
        return dr == dir && dc.abs() == 1;

      case PieceType.knight:
        return (dr.abs() == 2 && dc.abs() == 1) ||
            (dr.abs() == 1 && dc.abs() == 2);

      case PieceType.bishop:
        if (dr.abs() != dc.abs()) return false;
        return _clearPath(board, sr, sc, tr, tc);

      case PieceType.rook:
        if (dr != 0 && dc != 0) return false;
        return _clearPath(board, sr, sc, tr, tc);

      case PieceType.queen:
        if (!(dr == 0 || dc == 0 || dr.abs() == dc.abs())) return false;
        return _clearPath(board, sr, sc, tr, tc);

      case PieceType.king:
        return dr.abs() <= 1 && dc.abs() <= 1;
    }
  }

  static bool _moveLeavesKingInCheck(
      ChessBoard board, int sr, int sc, int er, int ec, PieceColor color) {
    final savedSr = board.board[sr][sc];
    final savedEr = board.board[er][ec];

    board.board[er][ec] = savedSr;
    board.board[sr][sc] = null;

    final inCheck = isKingInCheck(board, color);

    board.board[sr][sc] = savedSr;
    board.board[er][ec] = savedEr;

    return inCheck;
  }

  // ─── Мат / пат ──────────────────────────────────────────────────────────────

  static bool hasLegalMoves(ChessBoard board, PieceColor color) {
    for (int sr = 0; sr < 8; sr++) {
      for (int sc = 0; sc < 8; sc++) {
        final p = board.board[sr][sc];
        if (p == null || p.color != color) continue;

        for (int er = 0; er < 8; er++) {
          for (int ec = 0; ec < 8; ec++) {
            if (isValidMove(board, sr, sc, er, ec)) return true;
          }
        }
      }
    }
    return false;
  }

  static GameResult getGameResult(ChessBoard board, PieceColor color) {
    final inCheck = isKingInCheck(board, color);
    final hasMoves = hasLegalMoves(board, color);

    if (!hasMoves && inCheck) return GameResult.checkmate;
    if (!hasMoves && !inCheck) return GameResult.stalemate;
    if (inCheck) return GameResult.check;
    return GameResult.ongoing;
  }

  // ─── Вспомогательные ────────────────────────────────────────────────────────

  static bool _pawn(
      ChessBoard board,
      ChessPiece piece,
      int sr,
      int sc,
      int er,
      int ec,
      int dr,
      int dc,
      ChessPiece? target,
      ) {
    final dir = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    // Ход вперёд на 1
    if (dc == 0 && dr == dir && target == null) return true;

    // Ход вперёд на 2 с начальной позиции
    if (dc == 0 && sr == startRow && dr == 2 * dir && target == null) {
      return board.board[sr + dir][sc] == null;
    }

    // Взятие по диагонали
    if (dr == dir && dc.abs() == 1 && target != null) return true;

    return false;
  }

  static bool _clearPath(ChessBoard board, int sr, int sc, int er, int ec) {
    final stepR = (er - sr).sign;
    final stepC = (ec - sc).sign;

    int r = sr + stepR;
    int c = sc + stepC;

    while (r != er || c != ec) {
      if (board.board[r][c] != null) return false;
      r += stepR;
      c += stepC;
    }
    return true;
  }

  static bool _inBounds(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;
}

enum GameResult { ongoing, check, checkmate, stalemate }