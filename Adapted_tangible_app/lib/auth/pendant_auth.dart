import 'pointer_pair.dart';

///Contains the authentication logic for the pendant object
bool pendantAuth(List<PointerPair?> points) {
  if (points.length == 4){ //3 Points logged, plus one null
    return true;
  }
  return false;
}