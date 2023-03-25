import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:crypto/crypto.dart';

///Home page - This is the first default screen the loads
///Contains: Menu for access to Withdraw, and Help pages, (Questionnaire also
///for debugging purposes) and the link to the authentication page. Also deals
///with some data collection for first start (eg model, participant number)
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  final String title = "Home page";

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String boxText = ""; //String var for textbox
  late bool nfc;

  @override
  void initState(){
    super.initState();

    NfcManager.instance.isAvailable().then((b){
      if (b){
        setState((){
          boxText = "NFC is available on this device";
          nfc = true;
        });
      }
      else {
        setState((){
          boxText = "NFC is not available on this device";
          nfc = false;
        });
      }
    });
  }

  ///Changes the account on the chip
  Future<void> _setAccount() async {
    String uname = "";
    String pword = "";
    //Gather username and password
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: const Text("Set Account"),
              children:
                [Row(
                  children: [
                    const SizedBox(
                      width:20,
                    ),
                    const Text("Username: "),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child:SizedBox(
                        width: 130,
                        child:TextField(
                          onChanged: (value) {
                            setState((){
                            uname = value;
                            });
                          }
                        ),
                      )
                    ),
                  ]
                ),
                Row(
                  children: [
                    const SizedBox(
                      width:20,
                    ),
                    const Text ("Password: "),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child:SizedBox(
                        width: 130,
                        child:TextField(
                          obscureText: true,
                          onChanged: (value) {
                            setState((){
                              pword = value;
                            });
                          },
                        )
                      ),
                    )
                  ]
                ),
                ElevatedButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")),
              ]
          );
        }
    );

    //Create hash of username and save to nfc
    String hash = sha256.convert(utf8.encode("$uname:-$pword")).toString();
    if (kDebugMode) {
      print(hash);
    }

    //Create dummy alert message to have user scan nfc
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SimpleDialog(
          title: Text("Scan NFC now"),
          children:[
            Center(
              child:Padding(padding: EdgeInsets.all(40), child:Text("You may now scan the nfc chip with your phone's nfc reader in order to save your login details."))
            ),
          ],
        );
      }
    );

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        bool success = false;
        final ndefTag = Ndef.from(tag);

        if (ndefTag != null){
          final record = NdefRecord.createText(hash);
          final message = NdefMessage([record]);
          try {
            //Any existing content will be overwritten
            await ndefTag.write(message);
            if (kDebugMode) {
              print('Account written to tag');
            }
            success = true;
          } catch (e) {
            if (kDebugMode) {
              print("Writing failed, press 'Write to tag' again");
            }
          }
          //Remove the dialog box once it's been scanned
          if (success) {
            setState(() {
              Navigator.pop(context);
            });
            NfcManager.instance.stopSession();
          }
        }
      },
    );
  }

  ///Deals with authentication logic
  Future<void> _auth() async {
    String uname = "";
    String pword = "";
    //Gather username and password
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: const Text("Login"),
              children:
              [Row(
                  children: [
                    const SizedBox(
                      width:20,
                    ),
                    const Text("Username: "),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child:SizedBox(
                          width: 130,
                          child:TextField(
                              onChanged: (value) {
                                setState((){
                                  uname = value;
                                });
                              }
                          ),
                        )
                    ),
                  ]
              ),
                Row(
                    children: [
                      const SizedBox(
                        width:20,
                      ),
                      const Text ("Password: "),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child:SizedBox(
                            width: 130,
                            child:TextField(
                              obscureText: true,
                              onChanged: (value) {
                                setState((){
                                  pword = value;
                                });
                              },
                            )
                        ),
                      )
                    ]
                ),
                ElevatedButton(onPressed: () {Navigator.pop(context);}, child: const Text("OK")),
              ]
          );
        }
    );

    //Create hash of username and save to nfc
    String hash = sha256.convert(utf8.encode("$uname:-$pword")).toString();
    if (kDebugMode) {
      print(hash);
    }

    //Create dummy alert message to have user scan nfc
    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const SimpleDialog(
            title: Text("Scan NFC now"),
            children:[
              Center(
                  child:Padding(padding: EdgeInsets.all(40), child:Text("You may now scan the nfc chip with your phone's nfc reader in order to read your previously saved login details."))
              ),
            ],
          );
        }
    );

    bool successfulLogin = false;

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        bool success = false;
        final ndefTag = Ndef.from(tag);

        if (ndefTag != null){
          if (ndefTag.cachedMessage != null){
            var ndefMessage = ndefTag.cachedMessage!;
            final record = ndefMessage.records.first;
            final payloadBytes = record.payload.skip(1).toList();
            final payloadTextFull = utf8.decode(payloadBytes);
            String payload = payloadTextFull.substring(2);
            if (kDebugMode) {
              print(payload);
            }
            if (payload == hash){
              setState((){
                successfulLogin = true;
              });
            }
            success = true;

            //Remove the dialog box once it's been scanned
            if (success) {
              setState(() {
                Navigator.pop(context);
              });
              NfcManager.instance.stopSession();
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      children: [
                        Padding(padding: const EdgeInsets.all(40),
                            child: successfulLogin ?
                            const Text("You successfully logged in!") :
                            const Text("Incorrect username or password")),
                        ElevatedButton(
                            child: const Text("OK"),
                            onPressed: () {Navigator.pop(context);}
                        )
                      ],
                    );
                  }
              );
            }
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView( //Ensures no overflow error
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                //Text box 1
                Padding(
                    padding: const EdgeInsets.fromLTRB(20,10,20,20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(width:2.0, color: Colors.indigo),
                        color: Colors.indigoAccent,
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(boxText, style: const TextStyle(color: Colors.white))
                      ),
                    )
                ),
                //Text box 2
                Padding(
                  padding: const EdgeInsets.fromLTRB(20,20,20,10),
                  child:Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(width:2.0, color: Colors.indigo),
                        color: Colors.indigoAccent,
                      ),
                      child:
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Thank you for participating in the tangible wearable preliminary study! Press the button below to create an account.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                      )
                  ),
                ),
                //Button to direct to auth page
                ElevatedButton(
                    onPressed: _setAccount,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.indigoAccent),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.indigo, width:2.0)
                            )
                        )
                    ),
                    child: const Padding(
                        padding: EdgeInsets.fromLTRB(5,10,5,10),
                        child: Text("Create Account"),
                    )
                ),
                const SizedBox(
                  height: 20,
                ),
                //Text box 2
                Padding(
                  padding: const EdgeInsets.fromLTRB(20,20,20,10),
                  child:Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(width:2.0, color: Colors.indigo),
                        color: Colors.indigoAccent,
                      ),
                      child:
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("If you have set an account, press the button below to authenticate.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                      )
                  ),
                ),
                //Button to direct to auth page
                ElevatedButton(
                    onPressed: _auth,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.indigoAccent),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.indigo, width:2.0)
                            )
                        )
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(5,10,5,10),
                      child: Text("Authenticate"),
                    )
                )
              ],
            )
        )
    );
  }
}
