import 'package:flutter/material.dart';

import 'home.dart';
import 'utility/local.dart';

///Questions page - This is where the user is directed to upon completion of an
///authentication attempt. Currently contains question templates for both free text input
///and multiple choice questions
class Questions extends StatefulWidget {
  const Questions({Key? key, required this.skip, required this.success, required this.time, required this.live}) : super(key: key);

  final num time; //Stores the time the authentication took place (so it can be linked to the authentication attempt)
  final bool skip; //Stores whether the authentication was skipped
  final bool live; //Stores whether the study is live on this device (so it only sends valid data)
  final bool success; //Stores whether the authentication was a success

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Questionnaire"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: QuestionsForm(time: widget.time, skip: widget.skip, success: widget.success, live: widget.live),
      ),
    );
  }
}

class QuestionsForm extends StatefulWidget {
  const QuestionsForm({Key? key, required this.time, required this.skip, required this.success, required this.live}) : super(key: key);

  final num time;
  final bool skip;
  final bool live;
  final bool success;

  @override
  State<QuestionsForm> createState() => _QuestionsFormState();
}

class _QuestionsFormState extends State<QuestionsForm> {
  //[Answer1, Answer1 - other specific, Answer2, Answer2 - explain, Answer2 - other specific, Answer3, Answer3 - why, Answer4 (optional)]
  List<dynamic> answers = [null, null, null, null, null, null, null, null]; //The final state of all the answers
  List<bool> phase = [true, false, false, false]; //Phase of answers to questions
  String? error; //A string object used to display the error text if an answer is empty

  void _handleSubmit(ans){

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// ------------------ Success -----------------
            widget.success ?
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    //Question 1
                    phase[0] ?
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child:
                      Column(
                        children: [
                          const Text("Where are you currently?"),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[0] = "Home";
                                phase[0] = false;
                                phase[1] = true;
                              });
                            },
                            child: const Text("At Home"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[0] = "Work";
                                phase[0] = false;
                                phase[1] = true;
                              });
                            },
                            child: const Text("At Work"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[0] = "Transit";
                                phase[0] = false;
                                phase[1] = true;
                              });
                            },
                            child: const Text(
                                "In Transit (eg. bus or train)"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[0] = "Public";
                                phase[0] = false;
                                phase[1] = true;
                              });
                            },
                            child: const Text(
                                "In Public Place (eg. restaurant or park)"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[0] = "Private";
                                phase[0] = false;
                                phase[1] = true;
                              });
                            },
                            child: const Text(
                                "In Private Place (eg. home of a friend)"),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Other (Please specify)", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  onSubmitted: (value) {
                                    setState(() {
                                      answers[0] = "Other";
                                      answers[1] = value;
                                      phase[0] = false;
                                      phase[1] = true;
                                    });
                                  },
                                )
                              )
                            ]
                          )
                        ]
                      )
                    )
                    : const SizedBox(height:0),
                    //Question 2
                    phase[1] ?
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text("Did you have any problems with the authentication?"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState((){
                                    answers[2] = "No";
                                    phase[1] = false;
                                    phase[2] = true;
                                  });
                                },
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState((){
                                    answers[2] = "Yes";
                                  });
                                },
                                child: const Text("Yes"),
                              )
                            ]
                          ),
                          answers[2] != "Yes" ? const SizedBox(height:0) :
                          Column(
                            children:[
                              const Text("What kind of issue did you experience?"),
                              TextButton(
                                onPressed: () {
                                  setState((){
                                    answers[3] = "Search for item";
                                    phase[1] = false;
                                    phase[2] = true;
                                  });
                                },
                                child: const Text("I had to look for the item"),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState((){
                                    answers[3] = "Multiple attempts";
                                    phase[1] = false;
                                    phase[2] = true;
                                  });
                                },
                                child: const Text("I needed multiple attempts"),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState((){
                                    answers[3] = "Poor timing";
                                    phase[1] = false;
                                    phase[2] = true;
                                  });
                                },
                                child: const Text("The timing of the authentication was inconvenient"),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Other (Please specify)", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                                  SizedBox(
                                      width: 200,
                                      child: TextField(
                                        onSubmitted: (value) {
                                          setState(() {
                                            answers[3] = "Other";
                                            answers[4] = value;
                                            phase[1] = false;
                                            phase[2] = true;
                                          });
                                        },
                                      )
                                  )
                                ]
                              )
                            ]
                          ),
                        ],
                      ),
                    )
                    : const SizedBox(height:0),
                    //Question 3
                    phase[2] ?
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          //Question 3a
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child:
                            Column(
                                children: [
                                  const Text("Would you like to perform this kind of authentication in a similar setting in your daily life?"),
                                  TextButton(
                                    onPressed: (){
                                      setState((){
                                        answers[5] = "No";
                                      });
                                    },
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed:(){
                                      setState((){
                                        answers[5] = "Yes";
                                      });
                                    },
                                    child: const Text("Yes"),
                                  ),
                                ]
                            ),
                          ),
                          //Question 3b
                          answers[5] == null ? const SizedBox(height:0) :
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child:
                            Column(
                                children: [
                                  const Text("Why do you feel this way?"),
                                  SizedBox(
                                      width: 300,
                                      child: TextField(
                                        onSubmitted: (value) {
                                          setState((){
                                            answers[6] = value;
                                            phase[2] = false;
                                            phase[3] = true;
                                          });
                                        },
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ]
                      )
                    )
                    : const SizedBox(height:0),
                    //Question 4
                    phase[3] ?
                    Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            const Text("Do you have any further feedback?"),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                onChanged: (value) {
                                  setState((){
                                    answers[7] = value;
                                  });
                                },
                              ),
                            ),
                          ]
                        )
                      ],
                    ),
                  )
                    : const SizedBox(height:0),
                  ]
                )
              )
            :
            /// ------------------- Skip -----------------------
            widget.skip ?
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  //Question 1
                  phase[0] ?
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child:
                    Column(
                      children: [
                        const Text("Where are you currently?"),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[0] = "Home";
                              phase[0] = false;
                              phase[1] = true;
                            });
                          },
                          child: const Text("At Home"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[0] = "Work";
                              phase[0] = false;
                              phase[1] = true;
                            });
                          },
                          child: const Text("At Work"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[0] = "Transit";
                              phase[0] = false;
                              phase[1] = true;
                            });
                          },
                          child: const Text("In Transit (eg. bus or train)"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[0] = "Public";
                              phase[0] = false;
                              phase[1] = true;
                            });
                          },
                          child: const Text("In Public Place (eg. restaurant or park)"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[0] = "Private";
                              phase[0] = false;
                              phase[1] = true;
                            });
                          },
                          child: const Text("In Private Place (eg. home of a friend)"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Other (Please specify)", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                onSubmitted: (value) {
                                  setState(() {
                                    answers[0] = "Other";
                                    answers[1] = value;
                                    phase[0] = false;
                                    phase[1] = true;
                                  });
                                },
                              )
                            )
                          ]
                        )
                      ]
                    )
                  )
                  : const SizedBox(height:0),
                  //Question 2
                  phase[1] ?
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Text("What kind of problem did you experience?"),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[2] = "Not Available";
                              phase[1] = false;
                              phase[2] = true;
                            });
                          },
                          child: const Text("The item was not with me"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[2] = "Multiple attempts";
                              phase[1] = false;
                              phase[2] = true;
                            });
                          },
                          child: const Text("I needed multiple attempts"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[2] = "Inconvenient";
                              phase[1] = false;
                              phase[2] = true;
                            });
                          },
                          child: const Text("The timing of the authentication was not convenient"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[2] = "Not recognised";
                              phase[1] = false;
                              phase[2] = true;
                            });
                          },
                          child: const Text("The item was not recognised"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              answers[2] = "Accident";
                              phase[1] = false;
                              phase[2] = true;
                            });
                          },
                          child: const Text("I've accidentally skipped"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Other (Please specify)", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                            SizedBox(
                                width: 200,
                                child: TextField(
                                  onSubmitted: (value) {
                                    setState(() {
                                      answers[2] = "Other";
                                      answers[3] = value;
                                      phase[1] = false;
                                      phase[2] = true;
                                    });
                                  },
                                )
                            )
                          ]
                        )
                      ]
                    )
                  )
                  : const SizedBox(height:0),
                  //Question 3
                  phase[2] ?
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        //Question 3a
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child:
                          Column(
                              children: [
                                const Text("Would you like to perform this kind of authentication in a similar setting in your daily life?"),
                                TextButton(
                                  onPressed: (){
                                    setState((){
                                      answers[5] = "No";
                                    });
                                  },
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed:(){
                                    setState((){
                                      answers[5] = "Yes";
                                    });
                                  },
                                  child: const Text("Yes"),
                                ),
                              ]
                          ),
                        ),
                        //Question 3b
                        answers[5] == null ? const SizedBox(height:0) :
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child:
                          Column(
                              children: [
                                const Text("Why do you feel this way?"),
                                SizedBox(
                                    width: 300,
                                    child: TextField(
                                      onSubmitted: (value) {
                                        setState((){
                                          answers[6] = value;
                                          phase[2] = false;
                                          phase[3] = true;
                                        });
                                      },
                                    )
                                ),
                              ]
                          ),
                        ),
                      ]
                    )
                  )
                  : const SizedBox(height:0),
                  //Question 4
                  phase[3] ?
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Column(
                            children: [
                              const Text("Do you have any further feedback?"),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  onChanged: (value) {
                                    setState((){
                                      answers[7] = value;
                                    });
                                  },
                                ),
                              ),
                            ]
                        )
                      ],
                    ),
                  )
                  : const SizedBox(height:0),
                ]
              ),
            ) :
            /// ------------------- Failure --------------------
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  //Question 1
                  phase[0] ?
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child:
                      Column(
                          children: [
                            const Text("Where are you currently?"),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  answers[0] = "Home";
                                  phase[0] = false;
                                  phase[1] = true;
                                });
                              },
                              child: const Text("At Home"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  answers[0] = "Work";
                                  phase[0] = false;
                                  phase[1] = true;
                                });
                              },
                              child: const Text("At Work"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  answers[0] = "Transit";
                                  phase[0] = false;
                                  phase[1] = true;
                                });
                              },
                              child: const Text("In Transit (eg. bus or train)"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  answers[0] = "Public";
                                  phase[0] = false;
                                  phase[1] = true;
                                });
                              },
                              child: const Text("In Public Place (eg. restaurant or park)"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  answers[0] = "Private";
                                  phase[0] = false;
                                  phase[1] = true;
                                });
                              },
                              child: const Text("In Private Place (eg. home of a friend)"),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Other (Please specify)", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                                  SizedBox(
                                      width: 200,
                                      child: TextField(
                                        onSubmitted: (value) {
                                          setState(() {
                                            answers[0] = "Other";
                                            answers[1] = value;
                                            phase[0] = false;
                                            phase[1] = true;
                                          });
                                        },
                                      )
                                  )
                                ]
                            )
                          ]
                      )
                  )
                  : const SizedBox(height:0),
                  //Question 2
                  phase[1] ?
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text("What kind of problem did you experience?"),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[2] = "Not Available";
                                phase[1] = false;
                                phase[2] = true;
                              });
                            },
                            child: const Text("The item was not with me"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[2] = "Multiple attempts";
                                phase[1] = false;
                                phase[2] = true;
                              });
                            },
                            child: const Text("I needed multiple attempts"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[2] = "Inconvenient";
                                phase[1] = false;
                                phase[2] = true;
                              });
                            },
                            child: const Text("The timing of the authentication was not convenient"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                answers[2] = "Not recognised";
                                phase[1] = false;
                                phase[2] = true;
                              });
                            },
                            child: const Text("The item was not recognised"),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Other (Please specify)", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
                                SizedBox(
                                    width: 200,
                                    child: TextField(
                                      onSubmitted: (value) {
                                        setState(() {
                                          answers[2] = "Other";
                                          answers[3] = value;
                                          phase[1] = false;
                                          phase[2] = true;
                                        });
                                      },
                                    )
                                )
                              ]
                          )
                        ]
                      )
                  )
                  : const SizedBox(height:0),
                  //Question 3
                  phase[2] ?
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                          children: [
                            //Question 3a
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child:
                              Column(
                                  children: [
                                    const Text("Would you like to perform this kind of authentication in a similar setting in your daily life?"),
                                    TextButton(
                                      onPressed: (){
                                        setState((){
                                          answers[5] = "No";
                                        });
                                      },
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed:(){
                                        setState((){
                                          answers[5] = "Yes";
                                        });
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ]
                              ),
                            ),
                            //Question 3b
                            answers[5] == null ? const SizedBox(height:0) :
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child:
                              Column(
                                  children: [
                                    const Text("Why do you feel this way?"),
                                    SizedBox(
                                        width: 300,
                                        child: TextField(
                                          onSubmitted: (value) {
                                            setState((){
                                              answers[6] = value;
                                              phase[2] = false;
                                              phase[3] = true;
                                            });
                                          },
                                        )
                                    ),
                                  ]
                              ),
                            ),
                          ]
                      )
                  )
                  : const SizedBox(height:0),
                  //Question 4
                  phase[3] ?
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Column(
                            children: [
                              const Text("Do you have any further feedback?"),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  onChanged: (value) {
                                    setState((){
                                      answers[7] = value;
                                    });
                                  },
                                ),
                              ),
                            ]
                        )
                      ],
                    ),
                  )
                  : const SizedBox(height:0),
                ]
              )
            )
            ,
            /// ------------------- Submit ---------------------
            !phase[3] ? const SizedBox(height:0) :
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
              onPressed: () {
                _handleSubmit(answers);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const Home(firstStart: false)
                  ),
                );
              },
              child: const Text("Submit"),
            )
          ]
      ),
    );
  }


/**
            ///Text Input Template
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Text("Free Text Question", textAlign: TextAlign.center),
                  TextFormField(
                      decoration: const InputDecoration(errorStyle: TextStyle(color: Colors.red)),
                      onSaved: (value) => answers[0] = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty){
                          return "Please enter some text";
                        }
                        return null;
                      }
                  ),
                ],
              ),
            ),
            ///MCQ Template
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Text("Multiple Choice Question", textAlign: TextAlign.center),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: _iToggle1[0] ? const Icon(Icons.looks_one) : const Icon(Icons.looks_one_outlined),
                          onPressed: () {
                            setState((){
                              _iToggle1 = [true, false, false, false, false];
                              answers[1] = 0;
                            });
                          }
                      ),
                      IconButton(
                          icon: _iToggle1[1] ? const Icon(Icons.looks_two) : const Icon(Icons.looks_two_outlined),
                          onPressed: () {
                            setState((){
                              _iToggle1 = [false, true, false, false, false];
                              answers[1] = 1;
                            });
                          }
                      ),
                      IconButton(
                          icon: _iToggle1[2] ? const Icon(Icons.looks_3) : const Icon(Icons.looks_3_outlined),
                          onPressed: () {
                            setState((){
                              _iToggle1 = [false, false, true, false, false];
                              answers[1] = 2;
                            });
                          }
                      ),
                      IconButton(
                          icon: _iToggle1[3] ? const Icon(Icons.looks_4) : const Icon(Icons.looks_4_outlined),
                          onPressed: () {
                            setState((){
                              _iToggle1 = [false, false, false, true, false];
                              answers[1] = 3;
                            });
                          }
                      ),
                      IconButton(
                          icon: _iToggle1[4] ? const Icon(Icons.looks_5) : const Icon(Icons.looks_5_outlined),
                          onPressed: () {
                            setState((){
                              _iToggle1 = [false, false, false, false, true];
                              answers[1] = 4;
                            });
                          }
                      ),
                    ],
                  ),
                  error != null ? Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)) : const SizedBox(height:0),
                ],
              ),
            ),
            ///Submit Button
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
              onPressed: () {
                if (_formKey.currentState!.validate() && answers[1] != null){
                  _formKey.currentState!.save();
                  _handleSubmit(answers);
                  setState((){
                    error = null;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const Home(firstStart: false)
                    ),
                  );
                }
                else {
                  if (answers[1] == null){
                    setState((){
                      error = "Please make a selection";
                    });
                  } else {
                    setState((){
                      error = null;
                    });
                  }
                }
              },
              child: const Text("Submit"),
            )
          ],
        )
      )
    );
    **/
}
