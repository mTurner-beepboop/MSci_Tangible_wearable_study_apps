///Class containing pointer information - co-ord and pointer id for unique
///reference as well as size (see note)
class PointerPair {
  final double x;
  final double y;
  final double size; //Size appears to be too inconsistent to use as a measure for authentication
  final int id;

  PointerPair(this.x, this.y, this.size, this.id);
}