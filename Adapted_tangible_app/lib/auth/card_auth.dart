import 'pointer_pair.dart';

///Contains the authentication logic for the card object
bool cardAuth(List<PointerPair?> points) {
  final List<int> combination = [6,4,2];

  int inaccuracy = 50;
  List<PointerPair?> temp = [null, null];
  int dots = 0;
  List<int> dotList = [];
  bool lastNull = true;

  for (PointerPair? pt in points) {
    //Ignore null points
    if (pt == null){
      lastNull = true;
      continue;
    }

    //If the last point was not null, either problem or end of input
    if (!lastNull){
      break;
    }

    //Run through non-null points and translate into combination
    if (temp[0] == null && temp[1] == null){
      //This is the first point
      dots++;
      temp[0] = pt;
    }
    else{
      //Not first point
      if (temp[1] != null){
        //If point from two steps ago is same as current point, the direction has switched
        if (temp[1]!.x < pt.x + inaccuracy && temp[1]!.x > pt.x - inaccuracy  &&  temp[1]!.y < pt.y + inaccuracy && temp[1]!.y > pt.y - inaccuracy){
          dotList.add(dots);
          dots = 1;
        }
        else{
          dots++;
        }
      }
      else{
        dots++;
      }

      temp[1] = temp[0];
      temp[0] = pt;
    }
    lastNull = false;
  }
  dotList.add(dots-1); //Assuming the square bit on the base is still used

  print(dotList);

  if (dotList.length == combination.length) {
    return dotList[0] == combination[0] && dotList[1] == combination[1] && dotList[2] == combination[2];
  }
  return false;
}