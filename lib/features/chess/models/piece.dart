enum PieceType { pawn, rook, knight, bishop, queen, king }
enum PieceColor { white, black }

class ChessPiece {
  final String id;
  final PieceType type;
  final PieceColor color;
  final String imagePath;

  bool hasMoved;

  ChessPiece({
    required this.id,
    required this.type,
    required this.color,
    required this.imagePath,
    this.hasMoved = false,
  });
}