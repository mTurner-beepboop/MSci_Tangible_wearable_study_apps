import 'pointer_pair.dart';

///Contains the authentication logic for the cube object
///Expects a list of PointerPair eg [pt,pt,pt,pt,null,pt,null, etc]
///Counts number of points between null values to derive combination
bool cubeAuth(List<PointerPair?> points) {
  List<num> combination = [4,1,4,2];
  int index = 0;
  int pointNum = 0;
  for (PointerPair? point in points){
    if (point != null){
      pointNum += 1;
    }
    else{
      //Make sure only four sides of the model were touched to the screen with no extra touches
      if (index > 3){
        return false;
      }
      combination[index] -= pointNum;
      index++;
      pointNum = 0;
    }
  }
  return (combination[0] == 0 && combination[1] == 0 && combination[2] == 0 && combination[3] == 0);
}