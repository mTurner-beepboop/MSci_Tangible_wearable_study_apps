import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../home.dart';
import '../questions.dart';
import 'card_auth.dart';
import 'pendant_auth.dart';
import 'cube_auth.dart';
import 'pointer_pair.dart';
import 'package:t2fa_usability_app/utility/local.dart';

///Authentication page - This is where the user will authenticate the object
///Contains: authentication logic (each function derived from the files of the
///same name), a simple help popup on the appbar, and a method of timing the
///attempt
class Auth extends StatefulWidget {
  const Auth({Key? key, required this.title, required this.object, required this.live})
      : super(key: key);

  final Objects?
      object; //This should never be null, but required in this implementation
  final String title;
  final bool live;

  @override
  State<Auth> createState() => _AuthState();
}

///Contains almost all of the authentication logic
class _AuthState extends State<Auth> {
  List<PointerPair> points =
      []; //Represents a list of currently active touch points
  List<PointerPair?> allPoints =
      []; //Represents a list of the pressed points for authentication

  String _instructions = "";
  //String _textContent = "No attempt yet"; //Debugging
  var _attemptNum = 1; //1 indexed attempt number for readability in data
  var _initialTime = 0; //Time currently starts from the moment the first touch happens, and ends when the authentication button is clicked successfully

  List<double> _boxSizes = []; //Represents the physical size of the listener box, set in init()
  List<Color> _cubeBoxColor = [Colors.transparent, Colors.transparent, Colors.transparent, Colors.transparent]; //Used for colouring the 'step-check' boxes for the cube authentication

  final num _maxAttempts = 3; //Easy way to change max number of attempts allowed

  num _participantNum = -1; //Initially negative for error, set in init()

  ///Add a new pointer pair to the list of active pointers
  void _addPoint(PointerPair? p) {
    if (p != null){
      points.add(p);
    }
    allPoints.add(p);
  }

  ///Removes the specified point from the list - by pointer ID
  void _removePoints(int pointerId) {
    points.removeWhere((item) => item.id == pointerId);
  }

  ///Moves the app to the home page (previously to questions)
  void _redirectToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const Home(firstStart: false),
      ),
    );
  }

  ///Here we can add the authentication logic, this whole class will need to be different for each of the objects, but regardless here is where the final check should happen
  ///For now we just have a return of the location of all the points in a snack bar
  ///This is probably where we can handle the file writing
  void _authenticateAttempt() {
    //In theory, check authentication success
    //Retrieve the correct function for the current object
    bool Function(List<PointerPair?>) authFunc;
    switch (widget.object) {
      case Objects.card:
        authFunc = cardAuth;
        break;
      case Objects.pendant:
        authFunc = pendantAuth;
        break;
      case Objects.cube:
        authFunc = cubeAuth;
        //Set all the cube progress squares to transparent again
        _resetColorBox();
        break;
      default: //In this case no object was chosen hence the authentication cannot be carried out - this shouldn't happen ever
        return;
    }

    //If final state, log current time and calculate time taken to authenticate
    num _timeTaken = 0;

    //Check authentication success
    bool suc = authFunc(allPoints);
    if (suc) {
      _timeTaken = _endTimer();

      //Tell the user it was successful
      var snackBar = SnackBar(content: Text("Success in $_attemptNum attempt(s)!"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      _redirectToHome();
      return;
    }

    //Check authentication attempt number (if 3 then end)
    if (_attemptNum == _maxAttempts) {
      _timeTaken = _endTimer();

      var snackBar = const SnackBar(content: Text("This attempt was a failure"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      _redirectToHome();
      return;
    }

    //Alter required variables after attempt
    //First iterate attemptNum if last attempt failed and not final allowed attempt
    if (!suc && _attemptNum != _maxAttempts) {
      setState((){
        _attemptNum += 1;
      });
    }

    /* //Debugging information
    String txt = "Last attempt included:";
    for (PointerPair? point in allPoints) {
      if (point != null) {
        txt += " id: ${point.id} (${point.x}, ${point.y}) ${point.size}";
      }
    }
    _changeText(txt + ". Time taken: $_timeTaken");
    */

    //Remove all points from the authentication
    while (allPoints.isNotEmpty) {
      allPoints.removeAt(0);
    }
  }

  ///Called when user wants to skip this authentication for any reason
  void _skipAuth() {
    var _timeTaken = _endTimer();

    var snackBar = const SnackBar(content: Text("This attempt was skipped."));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    _redirectToHome();
  }

  /*
  ///Controls the text in the debug text box
  void _changeText(msg) {
    setState(() {
      _textContent = msg;
    });
  }
  */

  ///Log current time for tracking authentication attempt time
  void _startTimer() {
    setState(() {
      _initialTime = DateTime.now().millisecondsSinceEpoch;
    });
  }

  ///Color the feedback box for the cube object
  void _colorBox(){
    for (int i = 0; i < 4; i++){
      if (_cubeBoxColor[i] == Colors.transparent){
        setState((){
          _cubeBoxColor[i] = Colors.green;
        });
        return;
      }
    }
    return; //This return shouldn't be called unless extra touches are made to the listener.
  }

  ///Reset the feedback box for the cube object
  void _resetColorBox(){
    setState((){
      _cubeBoxColor = [Colors.transparent, Colors.transparent, Colors.transparent, Colors.transparent];
    });
  }


  ///Calculate final time
  num _endTimer() {
    int timeElapsed = DateTime.now().millisecondsSinceEpoch - _initialTime;
    return timeElapsed;
  }

  ///Override initialisation to ensure time taken to authenticate is collected from moment the page opens
  @override
  void initState() {
    super.initState();
    _startTimer();
    //Set the size of the boxes for listening depending on which object the user has, as well as the instructions to be displayed in the help pop-up
    setState(() {
      switch (widget.object){
        case (Objects.cube):
          _boxSizes = [200,200];
          _instructions = "Touch the correct 4 sides to the screen then press authenticate, after lifting the object, one of the 4 boxes will turn green to help you keep track of your progress";
          break;
        case (Objects.card):
          _boxSizes = [550, 375];
          _instructions = "Perform the sliding action over the dots while the object is on the screen, touch the square portion, then press authenticate";
          break;
        case (Objects.pendant):
          _boxSizes = [200, 200];
          _instructions = "Ensure the object is in the correct combination, firmly touch it to the screen and press authenticate";
          break;
        default: //Error case
          _boxSizes=[0,0];
      }
    });
    //Retrieve the participant number from the file
    getParticipantNum().then((pNum) => setState((){
        _participantNum = pNum;
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
        actions: [
          //Help button on app bar
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Help: ${getStringObject(widget.object)}"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_instructions),
                      const SizedBox(height: 15),
                      TextButton(
                          onPressed: () {Navigator.pop(context);},
                          child: const Text("Close")
                      ),
                    ]
                  )
                );
              }
            ),
          )
        ]
      ),
      body: SingleChildScrollView( //Ensures no overflow error
        child: Center(
          ///This is where all the actual UI stuff goes
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //Extra feedback for cube auth (the 'step check' boxes)
              widget.object == Objects.cube
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child:Container(
                        height:20,
                        width:20,
                        decoration: BoxDecoration(
                          color: _cubeBoxColor[0],
                          border: Border.all(width: 1.0, color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        height:20,
                        width:20,
                        decoration: BoxDecoration(
                          color: _cubeBoxColor[1],
                          border: Border.all(width: 1.0, color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        height:20,
                        width:20,
                        decoration: BoxDecoration(
                          color: _cubeBoxColor[2],
                          border: Border.all(width: 1.0, color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        height:20,
                        width:20,
                        decoration: BoxDecoration(
                          color: _cubeBoxColor[3],
                          border: Border.all(width: 1.0, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                )
              )
              : SizedBox(height: widget.object == Objects.card ? 0 : 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children:[
                  //This is where the listener for the object interaction is
                  Listener(
                    onPointerDown: (event) {
                      ///This should be consistent for each object
                      //Event contains all the PointerEvent details
                      var x = event.position.dx;
                      var y = event.position.dy;
                      var size = event.radiusMinor;
                      var id = event.pointer; //Unique identifier for the point
                      _addPoint(PointerPair(x, y, size, id));
                      print(points.length); //Debugging
                    },
                    onPointerUp: (event) {
                      ///This will in particular be unique for each object
                      ///So probably needs an if or case statement to check that

                      //Get the event pointer id
                      var pointerId = event.pointer;

                      //Remove point from the list
                      _removePoints(pointerId);

                      //Check if no active points, if so inset a null value into allPoints
                      if (points.isEmpty) {
                        _addPoint(null);
                        if (widget.object == Objects.cube){
                          _colorBox();
                        }
                      }

                      /*
                      //Build a string to display debugging info
                      String text = "Active Points at: ";
                      for (PointerPair point in points) {
                        text += "(${point.x}, ${point.y}) with id: ${point.id} ";
                      }

                      text +=
                      ". Deactivated Point at: (${event.position.dx} ,${event.position.dy}), with ID: $pointerId";

                      //Create a snack bar to display the information in
                      var snackBar = SnackBar(content: Text(text));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      */
                    },
                    child: Container(
                      ///This is the actual area which collects the touch point information
                      width: _boxSizes[1],
                      height: _boxSizes[0],
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(width: 2.0, color: Colors.black),
                      ),
                    ),
                  ),
                  //Text(_textContent),
                  SizedBox(
                    height: widget.object == Objects.card ? 0 : 40
                  ),
                ]
              ),
              Row(
                //This widget holds the auth and skip buttons (assuming it's not card object)
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /* //This is a debugging button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo.shade100),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      )
                    ),
                    child: const Text("Return home"),
                  ),
                  */
                  widget.object == Objects.card ?
                  const SizedBox(height:0) :
                  TextButton(
                    onPressed: () {
                      _skipAuth();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.indigo.shade100),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      )
                    ),
                    child: const Text("Skip this Authentication")
                  ),
                  widget.object == Objects.card ?
                  const SizedBox(height:0) :
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.indigoAccent),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.indigo, width:2.0)
                            )
                        )
                    ),
                    ///The authentication attempt button
                    onPressed: () {
                      _authenticateAttempt();
                    },
                    child: const Text("Press to authenticate"),
                  ),
                ]
              )
            ],
          ),
        ),
      ),
      //This is where the skip and auth buttons are in the case of the card object, as on smaller screens there was no room for the buttons
      floatingActionButton: widget.object == Objects.card ? Wrap(
        direction: Axis.horizontal,
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton(
              heroTag: "skipBtn",
              onPressed: () => _skipAuth(),
              child: const Icon(Icons.arrow_back),
            )
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: FloatingActionButton(
              heroTag: "authBtn",
              onPressed: () => _authenticateAttempt(),
              child: const Icon(Icons.lock_open),
            )
          )
        ]
      ) :
      null,
    );
  }
}
