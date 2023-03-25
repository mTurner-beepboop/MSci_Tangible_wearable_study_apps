import 'package:flutter/material.dart';
import 'utility/local.dart';

///Utility function to unsubscribe from the notification topic in firebase and set withdrawn status
Future<void> unsubscribe() async {
  await setWithdrawn();
}

///Withdraw page - This is where the user can opt out of the study in app. Currently,
///on pressing the button the user is asked to confirm, upon confirmation, the
///unsubscribe function is called (see above), and they are directed to notify
///those running the study. A file is checked to see if the user previously
///withdrew on whether to display the withdraw button.
class Withdraw extends StatefulWidget {
  const Withdraw({Key? key}) : super(key: key);

  @override
  State<Withdraw> createState() => _WithdrawState();
}

class _WithdrawState extends State<Withdraw> {
  bool isActive = true; //Whether or not the user is still a participant
  var text = "Press the button below to withdraw from the study. Further instructions will be provided upon withdrawal. \n\n Be Aware: This cannot be undone, and may result in being unable to provide compensation.";

  @override
  void initState() {
    super.initState();
    //Check if the user has already withdrawn
    getWithdrawn().then((value) {
      setState((){
        isActive = value;
      });
      if (!isActive){
        setState((){
          text = "You have withdrawn from the study. Please contact ... to confirm this and discuss any compensation.";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, textAlign: TextAlign.center),
            const SizedBox(
              height: 30,
            ),
            //Withdraw button if active, information text box if not
            isActive
            ? ElevatedButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("Withdraw"),
                  content: const Text("Be aware, this cannot be undone. Are you sure you want to withdraw from the study?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        unsubscribe().then((result) {
                          setState(() {
                            isActive = false;
                            text = "You have withdrawn from the study. Please contact the team at tangibleauthteam@gmail.com to confirm this and discuss any compensation.";
                          });
                          Navigator.pop(context, 'Yes');
                        });
                      },
                      child: const Text("Yes"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'No');
                      },
                      child: const Text("No")),
                  ])),
              child: const Text("Withdraw"),
            )
            : const Text("You have withdrawn and will no longer receive notifications", textAlign: TextAlign.center,),
          ]
        )
      ),
    );
  }
}
