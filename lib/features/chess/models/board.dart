import 'piece.dart';

class ChessMove {
  final int sr, sc, er, ec;
  ChessMove(this.sr, this.sc, this.er, this.ec);
}

class MoveRecord {
  final int sr, sc, er, ec;
  final ChessPiece movedBefore;
  final ChessPiece movedAfter;
  final ChessPiece? captured;
  final PieceColor turnBefore;

  // Для рокировки: сохраняем куда переместилась ладья
  final int? rookSr, rookScBefore, rookScAfter;
  final ChessPiece? rookPiece;

  MoveRecord({
    required this.sr,
    required this.sc,
    required this.er,
    required this.ec,
    required this.movedBefore,
    required this.movedAfter,
    required this.captured,
    required this.turnBefore,
    this.rookSr,
    this.rookScBefore,
    this.rookScAfter,
    this.rookPiece,
  });
}

class ChessBoard {
  List<List<ChessPiece?>> board =
  List.generate(8, (_) => List.generate(8, (_) => null));

  PieceColor turn = PieceColor.white;
  PieceColor playerColor = PieceColor.white;
  bool isBoardFlipped = false;

  ChessPiece? pieceAt(int r, int c) => board[r][c];

  void configureGame({
    required PieceColor playerColor,
    required bool flipped,
  }) {
    this.playerColor = playerColor;
    isBoardFlipped = flipped;
  }

  void initializeBoard() {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        board[r][c] = null;
      }
    }

    for (int c = 0; c < 8; c++) {
      board[1][c] = ChessPiece(
        id: 'bp$c',
        type: PieceType.pawn,
        color: PieceColor.black,
        imagePath: 'assets/images/bp.png',
      );
      board[6][c] = ChessPiece(
        id: 'wp$c',
        type: PieceType.pawn,
        color: PieceColor.white,
        imagePath: 'assets/images/wp.png',
      );
    }

    _setBackRank(0, PieceColor.black);
    _setBackRank(7, PieceColor.white);

    turn = PieceColor.white;
  }

  void _setBackRank(int row, PieceColor color) {
    final p = color == PieceColor.white ? 'w' : 'b';
    String img(String x) => 'assets/images/$p$x.png';

    board[row][0] = ChessPiece(id: '${p}r1', type: PieceType.rook,   color: color, imagePath: img('r'));
    board[row][7] = ChessPiece(id: '${p}r2', type: PieceType.rook,   color: color, imagePath: img('r'));
    board[row][1] = ChessPiece(id: '${p}n1', type: PieceType.knight, color: color, imagePath: img('n'));
    board[row][6] = ChessPiece(id: '${p}n2', type: PieceType.knight, color: color, imagePath: img('n'));
    board[row][2] = ChessPiece(id: '${p}b1', type: PieceType.bishop, color: color, imagePath: img('b'));
    board[row][5] = ChessPiece(id: '${p}b2', type: PieceType.bishop, color: color, imagePath: img('b'));
    board[row][3] = ChessPiece(id: '${p}q',  type: PieceType.queen,  color: color, imagePath: img('q'));
    board[row][4] = ChessPiece(id: '${p}k',  type: PieceType.king,   color: color, imagePath: img('k'));
  }

  // Возвращает информацию о ходе ладьи при рокировке (до хода)
  _RookCastleInfo? _rookCastleInfo(int sr, int sc, int er, int ec) {
    final piece = board[sr][sc];
    if (piece == null || piece.type != PieceType.king) return null;
    if ((ec - sc).abs() != 2) return null;

    if (ec == 6) {
      // Короткая рокировка
      return _RookCastleInfo(row: sr, scBefore: 7, scAfter: 5);
    } else if (ec == 2) {
      // Длинная рокировка
      return _RookCastleInfo(row: sr, scBefore: 0, scAfter: 3);
    }
    return null;
  }

  void makeMove(int sr, int sc, int er, int ec) {
    final piece = board[sr][sc];
    if (piece == null) return;

    // Рокировка
    if (piece.type == PieceType.king && (ec - sc).abs() == 2) {
      if (ec == 6) {
        final rook = board[sr][7];
        board[sr][5] = rook;
        board[sr][7] = null;
        rook?.hasMoved = true;
      } else if (ec == 2) {
        final rook = board[sr][0];
        board[sr][3] = rook;
        board[sr][0] = null;
        rook?.hasMoved = true;
      }
    }

    board[er][ec] = piece;
    board[sr][sc] = null;
    piece.hasMoved = true;

    // ─────────────────────────────
    // Превращение пешки
    // ─────────────────────────────

    if (piece.type == PieceType.pawn) {

      // Белая пешка
      if (piece.color == PieceColor.white && er == 0) {
        board[er][ec] = ChessPiece(
          id: '${piece.id}_q',
          type: PieceType.queen,
          color: PieceColor.white,
          imagePath: 'assets/images/wq.png',
          hasMoved: true,
        );
      }

      // Чёрная пешка
      if (piece.color == PieceColor.black && er == 7) {
        board[er][ec] = ChessPiece(
          id: '${piece.id}_q',
          type: PieceType.queen,
          color: PieceColor.black,
          imagePath: 'assets/images/bq.png',
          hasMoved: true,
        );
      }
    }

    turn = turn == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;
  }

  MoveRecord? makeMoveRecord(int sr, int sc, int er, int ec) {
    final piece = board[sr][sc];
    if (piece == null) return null;

    final captured = board[er][ec];
    final turnBefore = turn;

    // Запоминаем инфо о ладье до хода (для undo рокировки)
    final rookInfo = _rookCastleInfo(sr, sc, er, ec);
    final rookPieceBefore =
    rookInfo != null ? board[rookInfo.row][rookInfo.scBefore] : null;

    makeMove(sr, sc, er, ec);

    return MoveRecord(
      sr: sr,
      sc: sc,
      er: er,
      ec: ec,
      movedBefore: piece,
      movedAfter: board[er][ec]!,
      captured: captured,
      turnBefore: turnBefore,
      rookSr: rookInfo?.row,
      rookScBefore: rookInfo?.scBefore,
      rookScAfter: rookInfo?.scAfter,
      rookPiece: rookPieceBefore,
    );
  }

  void undo(MoveRecord rec) {
    turn = rec.turnBefore;

    // Возвращаем фигуру
    final piece = rec.movedBefore;
    piece.hasMoved = false;
    board[rec.sr][rec.sc] = piece;
    board[rec.er][rec.ec] = rec.captured;

    // Откатываем рокировку — возвращаем ладью
    if (rec.rookPiece != null &&
        rec.rookSr != null &&
        rec.rookScBefore != null &&
        rec.rookScAfter != null) {
      final rook = rec.rookPiece!;
      rook.hasMoved = false;
      board[rec.rookSr!][rec.rookScBefore!] = rook;
      board[rec.rookSr!][rec.rookScAfter!] = null;
    }
  }
}

class _RookCastleInfo {
  final int row;
  final int scBefore;
  final int scAfter;
  _RookCastleInfo({
    required this.row,
    required this.scBefore,
    required this.scAfter,
  });
}