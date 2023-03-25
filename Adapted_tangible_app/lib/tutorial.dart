import 'package:flutter/material.dart';
import 'utility/local.dart';
import 'package:video_player/video_player.dart';

///Tutorial page - This is where the user can find instructions on how to work
///the model they have been assigned
class Tutorial extends StatefulWidget {
  const Tutorial({Key? key, required this.obj}) : super(key: key);

  final String obj;

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  //Video player variables
  late VideoPlayerController _controller;
  late Future<void> _initialiseVideoPlayerFuture;

  late String _title; //Title of the page - name of the object
  late String _text1; //First text box
  late String _text2; //Second text box

  @override
  void initState() {
    super.initState();

    //TODO - Add video files to assets folder and to the pubspec.yaml file, add paths in each case
    //Initialise the variables depending on which object the user has
    switch(getEnumObject(widget.obj)){
      case Objects.cube:
        setState((){
          _title = "Cube";
          _text1 = "This model is built to replicate a die, leaning in to the idea of authentication objects being multi-use. To authenticate, touch the correct four sides to the screen in the correct order, the press the button to authenticate.";
          _text2 = "The combination set for this objects requires the sequence: 4 -> 1 -> 4 -> 2. When touching the screen with the object, ensure that the face of the object is completely within the outlined box and that you are touching any of the black dots on any of the sides.";
          _controller = VideoPlayerController.asset("assets/videos/cube_tutorial.mp4");
          _initialiseVideoPlayerFuture = _controller.initialize();
          _controller.setLooping(true);
        });
        break;
      case Objects.card:
        setState((){
          _title = "Card";
          _text1 = "This model is built to the standard size of a credit card, allowing it to be convenient to carry in a wallet or purse. To authenticate you must enact a 'turning' motion over the ring of dots, like you would a safe lock, then touch the black square and finally the on-screen button.";
          _text2 = "To perform the 'turning' motion, starting from any of the dots, slide your finger over 6 dots in a clockwise direction, then 4 dots in a counter-clockwise direction, and finally 2 dots in a clockwise direction (Watch the tutorial video for a demonstration). Ensure the the model is placed within the bounds of the box on the authentication screen and that the model does not slide out of place.";
          _controller = VideoPlayerController.asset("assets/videos/card_tutorial.mp4");
          _initialiseVideoPlayerFuture = _controller.initialize();
          _controller.setLooping(true);
        });
        break;
      case Objects.pendant:
        setState((){
          _title = "Pendant";
          _text1 = "This model is built to act as a combination lock, a more familiar representation of security. To use, simple rotate the layers until the given combination is aligned in a column, touch the model to the screen and press the button to authenticate.";
          _text2 = "The combination set for this model is 6-1-7. When touching the model to the screen, ensure that you touch both black points on the top surface of the model (one on the main body, the other being the axis). Try to touch the model to the screen with the side showing the combination facing you.";
          _controller = VideoPlayerController.asset("assets/videos/pendant_tutorial.mp4");
          _initialiseVideoPlayerFuture = _controller.initialize();
          _controller.setLooping(true);
        });
        break;
      default:
        setState((){
          _title = "Error";
          _text1 = "This should not be allowed";
          _text2 = "Hopefully the video player didn't combust though";
        });
        break;
    }
  }

  @override
  void dispose(){
    //Frees up the video controller space
    if (_title != "Error") {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //Text content
            Text(_title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 40), textAlign: TextAlign.center),
            Padding(
              padding: const EdgeInsets.all(7.5),
              child: Column(
                children: [
                  Text("\n$_text1"),
                  Text("\n$_text2"),
                ]
              )
            ),
            const SizedBox(
              height: 40,
            ),
            //Video content
            _title != "Error" ? FutureBuilder(
              future: _initialiseVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the video.
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  );
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )
            : const SizedBox(height:0),
          ]
        ),
      ),
      //Button to control the video playback
      floatingActionButton:
        _title != "Error" ? FloatingActionButton(
          onPressed: () {
            // Wrap the play or pause in a call to `setState`. This ensures the
            // correct icon is shown.
            setState(() {
              // If the video is playing, pause it.
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                // If the video is paused, play it.
                _controller.play();
              }
            });
          },
          // Display the correct icon depending on the state of the player.
          child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        )
        : null,
    );
  }
}
