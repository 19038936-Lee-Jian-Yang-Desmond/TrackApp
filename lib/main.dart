import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:login/staff_interface.dart';
import 'package:login/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'model/model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FirstPage(),
  );
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData){
          return RegisterOTP();
        } else {
          return Login();
        }
      }
    )
  );
}

class Login extends StatefulWidget {
  @override
  _login createState() => _login();
}

class _login extends State<Login> {
  DateTime timeBackPressed  = DateTime.now();

  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  @override
  void dispose(){
    controllerEmail.dispose();
    controllerPassword.dispose();

    super.dispose();
  }

  Future logIn() async {
    if (controllerEmail.text.isEmpty) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Please enter your email.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
    else if (controllerPassword.text.isEmpty) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Please enter your password.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
    else {
      try{
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: controllerEmail.text.trim(),
            password: controllerPassword.text.trim()
        );
        _toRegisterOTP(context);
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "The email and password doesn't match",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 30
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      final diff = DateTime.now().difference(timeBackPressed);
      final isExitWarning = diff >= const Duration(seconds: 1);

      if (isExitWarning) {
        timeBackPressed = DateTime.now();
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "Press twice to exit the app",
          backgroundColor: Colors.black,
          textColor: Colors.white);
        return false;
      }
      return true;
    },
    child: Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Center(child: Column(children: <Widget>[
            Image.asset('assets/images/WH.jpg'),
            TextFormField(
              controller: controllerEmail,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: controllerPassword,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: _obscureText,
            ),
            FlatButton(
                onPressed: _toggle,
                child: Text(_obscureText ? "Show" : "Hide", style: const TextStyle(fontSize: 20))
            ),
            Container(
              margin: const EdgeInsets.all(25),
              child: RaisedButton(
                child: const Text("Login", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                color: Colors.redAccent,
                onPressed: logIn
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(25),
              child: RaisedButton(
                child: const Text("Sign up", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                color: Colors.redAccent,
                onPressed: () {
                  _toRegister(context);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(25),
              child: RaisedButton(
                child: const Text("Forget Password?", style: TextStyle(fontSize: 24.0, color: Colors.redAccent),),
                color: Colors.white,
                onPressed: () {
                  _toForgetPW(context);
                },
              ),
            ),
          ]))
        ]
      )
    )
  );
}

class Register extends StatefulWidget {
  @override
  _register createState() => _register();
}

class _register extends State<Register> {
  String radioButtonItem = 'Male';
  int id = 1;

  String dropdownitem = "Chinese";
  var items = ["Chinese", "Eurasian", "Indian", "Malay", "Others"];

  DateTime selectedDate = DateTime(2000,1,1);
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final formKey = GlobalKey<FormState>();

  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  _date() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  int goal = 0, duration = 0, tempgoal = 0;
  double amount = 0;

  bool redeem = false;
  bool breakfast = false;
  bool lunch = false;
  bool teatime = false;
  bool dinner = false;
  bool supper = false;

  Future createUser(String username, UserClass user) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: controllerEmail.text.trim(),
          password: controllerPassword.text.trim()
      );
      final docUser = FirebaseFirestore.instance.collection('TrackApp').doc(username);
      final json = user.toJson();
      await docUser.set(json);

      FirebaseFirestore.instance.collection("TrackApp/${user.email}/Goal").doc("Exercise").set(
          {
            "Conf" : 0,
            "Goal" : 0,
            "Type" : "Exercise"
          },
          SetOptions(merge : true)
      );
      FirebaseFirestore.instance.collection("TrackApp/${user.email}/Goal").doc("Diet").set(
          {
            "Conf" : 0,
            "Goal" : 3,
            "Type" : "Diet"
          },
          SetOptions(merge : true)
      );
      FirebaseFirestore.instance.collection("TrackApp/${user.email}/Goal").doc("Finance").set(
          {
            "Conf" : 0,
            "Goal" : 0,
            "Type" : "Finance"
          },
          SetOptions(merge : true)
      );
      FirebaseFirestore.instance.collection("TrackApp/${user.email}/Goal").doc("Social").set(
          {
            "Conf" : 0,
            "Goal" : 0,
            "Type" : "Social"
          },
          SetOptions(merge : true)
      );

      FirebaseFirestore.instance.collection('TrackApp/${user.email}/Goal').doc('Exercise').get().then((value){
        goal = value.data()!["Goal"];
        FirebaseFirestore.instance.collection("TrackApp/${user.email}/Exercise").doc("Exercise_${_date()}").set(
            {
              "Date" : _date(),
              "Duration" : duration,
              "Goal" : goal,
              "Redeem" : redeem
            },
            SetOptions(merge : true));
      });
      FirebaseFirestore.instance.collection('TrackApp/${user.email}/Goal').doc('Diet').get().then((value){
        goal = value.data()!["Goal"];
        FirebaseFirestore.instance.collection("TrackApp/${user.email}/Diet").doc("Diet_${_date()}").set(
            {
              "Date" : _date(),
              "Breakfast" : breakfast,
              "Lunch" : lunch,
              "Teatime" : teatime,
              "Dinner" : dinner,
              "Supper" : supper,
              "Goal" : goal,
              "Redeem" : redeem
            },
            SetOptions(merge : true));
      });
      FirebaseFirestore.instance.collection('TrackApp/${user.email}/Goal').doc('Finance').get().then((value){
        tempgoal = (value.data()!["Goal"]);
        FirebaseFirestore.instance.collection("TrackApp/${user.email}/Finance").doc("Finance_${_date()}").set(
            {
              "Date" : _date(),
              "Amt" : amount,
              "Goal" : tempgoal.toDouble(),
              "Redeem" : redeem
            },
            SetOptions(merge : true));
      });
      FirebaseFirestore.instance.collection('TrackApp/${user.email}/Goal').doc('Social').get().then((value){
        goal = value.data()!["Goal"];
        FirebaseFirestore.instance.collection("TrackApp/${user.email}/Social").doc("Social_${_date()}").set(
            {
              "Date" : _date(),
              "Duration" : duration,
              "Goal" : goal,
              "Redeem" : redeem
            },
            SetOptions(merge : true));
      });

      _toRegisterOTP(context);
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "The email address is in use by another account",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toLogin(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Register", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toLogin(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Center(child: Form(
            key: formKey,
            child: Column(children: <Widget>[
              TextFormField(
                controller: controllerName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controllerEmail,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) => email != null && !EmailValidator.validate(email)
                    ? "Please enter a valid email"
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () => _selectDate(context),
                    color: Colors.redAccent,
                    child: const Text('Date of Birth', style: TextStyle(fontSize: 28, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text('Gender: ', style: TextStyle(fontSize: 28.0)),
                  Radio(
                    value: 1,
                    groupValue: id,
                    onChanged: (val) {
                      setState(() {
                        radioButtonItem = 'Male';
                        id = 1;
                      });
                    },
                  ),
                  const Text('Male', style: TextStyle(fontSize: 28.0)),
                  Radio(
                    value: 2,
                    groupValue: id,
                    onChanged: (val) {
                      setState(() {
                        radioButtonItem = 'Female';
                        id = 2;
                      });
                    },
                  ),
                  const Text('Female', style: TextStyle(fontSize: 28.0),),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text('Race: ', style: TextStyle(fontSize: 28.0)),
                  const SizedBox(width: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton(
                      value: dropdownitem,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items:items.map((String items) {
                        return DropdownMenuItem(
                            value: items,
                            child: Text(items, style: const TextStyle(fontSize: 28))
                        );
                      }
                      ).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownitem = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controllerPassword,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder()
                ),
                obscureText: _obscureText,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length < 6
                    ? "Please enter minimum 6 characters"
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                    border: OutlineInputBorder()
                ),
                obscureText: _obscureText,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value != controllerPassword.text
                    ? "Please enter the correct password"
                    : null,
              ),
              FlatButton(
                  onPressed: _toggle,
                  child: Text(_obscureText ? "Show" : "Hide", style: const TextStyle(fontSize: 20))
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: RaisedButton(
                  child: const Text("Sign up", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                  color: Colors.redAccent,
                  onPressed: () {
                    final user = UserClass(
                      dob: selectedDate,
                      name: controllerName.text,
                      email: controllerEmail.text.toLowerCase(),
                      gender: radioButtonItem,
                      coin: 0,
                      race: dropdownitem,
                    );
                    createUser(controllerEmail.text.toLowerCase(), user);
                  },
                ),
              ),
            ])
          ))
        ]
      ),
    )
  );
}

class RegisterOTP extends StatefulWidget {
  @override
  _registerOTP createState() => _registerOTP();
}

class _registerOTP extends State<RegisterOTP> {
  bool verified = false;
  bool resend = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    verified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!verified) {
      sendVerificationEmail();

      timer = Timer.periodic(
          const Duration(seconds: 3),
              (_) => checkEmailVerified()
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      verified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (verified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => resend = false);
      await Future.delayed(const Duration(seconds: 15));
      setState(() => resend = true);
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  @override
  Widget build(BuildContext context) => verified
    ? CheckUser()
    : Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.redAccent,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          _toLogin(context);
        },
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Center(child: Column(children: <Widget>[
          const SizedBox(height: 30),
          const Text("A verification email", style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
          const Text("has been sent to", style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
          const Text("your registered email", style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.all(25),
            child: RaisedButton(
              child: const Text("Resend Email", style: TextStyle(fontSize: 28.0, color: Colors.white)),
              color: Colors.redAccent,
              onPressed: resend ? sendVerificationEmail: null,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(25),
            child: RaisedButton(
              child: const Text("Cancel", style: TextStyle(fontSize: 28.0, color: Colors.redAccent)),
              color: Colors.white,
              onPressed: () {
                FirebaseAuth.instance.signOut();
                _toLogin(context);
              }
            ),
          ),
        ]))
      ]
    )
  );
}

class ForgetPW extends StatefulWidget {
  @override
  _forgetPW createState() => _forgetPW();
}

class _forgetPW extends State<ForgetPW> {
  final controllerEmail = TextEditingController();

  @override
  void dispose(){
    controllerEmail.dispose();

    super.dispose();
  }

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: controllerEmail.text.trim()
      );
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Password reset email sent",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
      _toLogin(context);
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toLogin(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toLogin(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Center(child: Column(children: <Widget>[
            TextFormField(
              controller: controllerEmail,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                hintText: 'Enter your email here',
                border: OutlineInputBorder(),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) => email != null && !EmailValidator.validate(email)
                  ? "Please enter a valid email"
                  : null,
            ),
            Container(
              margin: const EdgeInsets.all(25),
              child: RaisedButton(
                child: const Text("Reset Password", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                color: Colors.redAccent,
                onPressed: () {
                  resetPassword();
                },
              ),
            ),
          ]))
        ]
      )
    )
  );
}

class CheckUser extends StatefulWidget {
  @override
  _checkUser createState() => _checkUser();
}

class _checkUser extends State<CheckUser> {
  final user = FirebaseAuth.instance.currentUser!;

  bool isAdmin = false;

  check() {
    FirebaseFirestore.instance.collection('TrackApp').doc(user.email).get().then((doc) => {
      setState(() {
        isAdmin = doc.data()!["Is_whc_user"];
      })
    });
    return isAdmin;
  }

  @override
  void initState() {
    setState(() {
      isAdmin = check();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => isAdmin
      ? MainforAdmin()
      : Main();
}

class Main extends StatefulWidget {
  @override
  _main createState() => _main();
}

class _main extends State<Main> {
  DateTime timeBackPressed  = DateTime.now();

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  var daylist = [
    DateTime.now().subtract(const Duration(days:1)),
    DateTime.now().subtract(const Duration(days:2)),
    DateTime.now().subtract(const Duration(days:3)),
    DateTime.now().subtract(const Duration(days:4)),
    DateTime.now().subtract(const Duration(days:5)),
    DateTime.now().subtract(const Duration(days:6)),
    DateTime.now().subtract(const Duration(days:7))
  ];

  _date(DateTime now) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  final user = FirebaseAuth.instance.currentUser!;

  var nci_e = [], fb_e = [], num_e = [];
  int duration_e = 0, goal_e = 0;

  status_exercise() {
    for (var i in daylist) {
      FirebaseFirestore.instance.collection('TrackApp/${user.email}/Exercise').where("Date", isEqualTo: _date(i)).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          for (var result in querySnapshot.docs) {
            setState(() {
              duration_e = result.data()["Duration"];
              goal_e = result.data()["Goal"];
            });
          }
          setState(() {
            num_e.add(duration_e);
          });
          if (duration_e == 0) {
            setState(() {
              nci_e.add(duration_e);
            });
          }
          if (duration_e < goal_e) {
            setState(() {
              fb_e.add(duration_e);
            });
          }
        }
        else {
          setState(() {
            num_e.add(duration_e);
            nci_e.add(duration_e);
          });
        }
        setState(() {
          duration_e = 0;
          goal_e = 0;
        });
      });
    }
  }

  var nci_d = [], fb_d = [], num_d = [];
  bool changed = false;
  bool breakfast = false;
  bool lunch = false;
  bool teatime = false;
  bool dinner = false;
  bool supper = false;
  int count = 0, goal_d = 0;

  countbool() {
    if (breakfast == true) {
      setState(() {
        count += 1;
      });
    }
    if (lunch == true) {
      setState(() {
        count += 1;
      });
    }
    if (teatime == true) {
      setState(() {
        count += 1;
      });
    }
    if (dinner == true) {
      setState(() {
        count += 1;
      });
    }
    if (supper == true) {
      setState(() {
        count += 1;
      });
    }
  }

  status_diet() {
    for (var i in daylist) {
      FirebaseFirestore.instance.collection('TrackApp/${user.email}/Diet').where("Date", isEqualTo: _date(i)).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          for (var result in querySnapshot.docs) {
            breakfast = result.data()["Breakfast"];
            lunch = result.data()["Lunch"];
            teatime = result.data()["Teatime"];
            dinner = result.data()["Dinner"];
            supper = result.data()["Supper"];
            goal_d = result.data()["Goal"];
          }
          countbool();
          setState(() {
            num_d.add(count);
          });
          if (count == 0) {
            setState(() {
              nci_d.add(count);
            });
          }
          if (count < goal_d) {
            setState(() {
              fb_d.add(count);
            });
          }
        }
        else {
          setState(() {
            num_d.add(count);
            nci_d.add(count);
          });
        }
        count = 0;
        goal_d = 0;
      });
    }
  }

  var nci_f = [], fb_f = [], num_f = [];
  double amt = 0, goal_f = 0;
  int add_f = 0;
  bool redeem_f = true;

  status_finance() {
    for (var i in daylist) {
      FirebaseFirestore.instance.collection('TrackApp/${user.email}/Finance').where("Date", isEqualTo: _date(i)).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          for (var result in querySnapshot.docs) {
            amt = result.data()["Amt"].toDouble();
            goal_f = result.data()["Goal"].toDouble();
            redeem_f = result.data()["Redeem"];
          }
          setState(() {
            num_f.add(amt);
          });
          if (amt > goal_f) {
            setState(() {
              fb_f.add(amt);
            });
          }
          else {
            if (goal_f != 0) {
              if (redeem_f == false) {
                setState(() {
                  add_f++;
                  addcoin(add_f);
                });
                final docUser = FirebaseFirestore.instance
                    .collection("TrackApp/${user.email}/Finance")
                    .doc("Finance_${_date(i)}");
                docUser.update({'Redeem': true});
              }
            }
          }
        } else {
          setState(() {
            num_f.add(amt);
            nci_f.add(amt);
          });
        }
        amt = 0;
        goal_f = 0;
        redeem_f = true;
      });
    }
  }

  var nci_s = [], fb_s = [], num_s = [];
  int duration_s = 0, goal_s = 0;

  status_social() {
    for (var i in daylist) {
      FirebaseFirestore.instance.collection('TrackApp/${user.email}/Social').where("Date", isEqualTo: _date(i)).get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          for (var result in querySnapshot.docs) {
            duration_s = result.data()["Duration"];
            goal_s = result.data()["Goal"];
          }
          setState(() {
            num_s.add(duration_s);
          });
          if (duration_s == 0) {
            setState(() {
              nci_s.add(duration_s);
            });
          }
          if (duration_s < goal_s) {
            setState(() {
              fb_s.add(duration_s);
            });
          }
        }
        else {
          setState(() {
            num_s.add(duration_s);
            nci_s.add(duration_s);
          });
        }
        duration_s = 0;
        goal_s = 0;
      });
    }
  }

  int coins = 0;

  addcoin(int add) {
    // if (add >= 0) {
      FirebaseFirestore.instance.collection('TrackApp').where('Email', isEqualTo: user.email).get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          setState(() {
            coins = result.data()["Coins"];
          });
        }
        final addcoin = FirebaseFirestore.instance
            .collection("TrackApp")
            .doc(user.email);
        setState(() {
          coins = coins + add;
        });
        addcoin.update({'Coins': coins});
      });
    // }
  }

  msg(var num, var nci, var fb) {
    if (num.isNotEmpty) {
      if (nci.length == num.length) {
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "Loser or winner, it’s your choice! We are betting that you’re a winner!",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 30
        );
      }
      else if (fb.length == num.length) {
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "Reward comes to those who persists! Don’t give up!",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 30
        );
      }
    }
  }

  createEx() {
    FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Exercise').doc("Exercise_${_date(DateTime.now())}").get().then((doc) => {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Goal').doc('Exercise').get().then((value){
          int g = value.data()!["Goal"];
          FirebaseFirestore.instance.collection("TrackApp/${user.email}/Exercise").doc("Exercise_${_date(DateTime.now())}").set(
              {
                "Date" : _date(DateTime.now()),
                "Duration" : 0,
                "Goal" : g,
                "Redeem" : false
              },
              SetOptions(merge : true));
        })
      }
    });
  }

  createDiet() {
    FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Diet').doc("Diet_${_date(DateTime.now())}").get().then((doc) => {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Goal').doc('Diet').get().then((value){
          int g = value.data()!["Goal"];
          FirebaseFirestore.instance.collection("TrackApp/${user.email}/Diet").doc("Diet_${_date(DateTime.now())}").set(
              {
                "Date" : _date(DateTime.now()),
                "Breakfast" : false,
                "Lunch" : false,
                "Teatime" : false,
                "Dinner" : false,
                "Supper" : false,
                "Goal" : g,
                "Redeem" : false
              },
              SetOptions(merge : true));
        })
      }
    });
  }

  createFin() {
    FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Finance').doc("Finance_${_date(DateTime.now())}").get().then((doc) => {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Goal').doc('Finance').get().then((value){
          double g = (value.data()!["Goal"]).toDouble();
          FirebaseFirestore.instance.collection("TrackApp/${user.email}/Finance").doc("Finance_${_date(DateTime.now())}").set(
              {
                "Date" : _date(DateTime.now()),
                "Amt" : 0.0,
                "Goal" : g,
                "Redeem" : false
              },
              SetOptions(merge : true));
        })
      }
    });
  }

  createSo() {
    FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Social').doc("Social_${_date(DateTime.now())}").get().then((doc) => {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Goal').doc('Social').get().then((value){
          int g = value.data()!["Goal"];
          FirebaseFirestore.instance.collection("TrackApp/${user.email}/Social").doc("Social_${_date(DateTime.now())}").set(
              {
                "Date" : _date(DateTime.now()),
                "Duration" : 0,
                "Goal" : g,
                "Redeem" : false
              },
              SetOptions(merge : true));
        })
      }
    });
  }

  @override
  void initState() {
    createEx();
    createDiet();
    createFin();
    createSo();
    super.initState();
    status_exercise();
    status_diet();
    status_finance();
    status_social();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      final diff = DateTime.now().difference(timeBackPressed);
      final isExitWarning = diff >= const Duration(seconds: 1);

      if (isExitWarning) {
        timeBackPressed = DateTime.now();
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "Press twice to exit the app",
          backgroundColor: Colors.black,
          textColor: Colors.white);
        return false;
      }
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text("Good ${greeting()} !", style: const TextStyle(fontSize: 30.0, color: Colors.white)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverGrid.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(0),
                  child: RaisedButton(
                    child: const Text("HEALTH", style: TextStyle(fontSize: 24.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      setState(() {
                        msg(num_e, nci_e, fb_e);
                        createEx();
                        _toHealth(context);
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(0),
                  child: RaisedButton(
                    child: const Text("DIET", style: TextStyle(fontSize: 24.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      setState(() {
                        msg(num_d, nci_d, fb_d);
                        createDiet();
                        _toDiet(context);
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(0),
                  child: RaisedButton(
                    child: const Text("FINANCE", style: TextStyle(fontSize: 24.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      setState(() {
                        msg(num_f, nci_f, fb_f);
                        createFin();
                        _toFinance(context);
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(0),
                  child: RaisedButton(
                    child: const Text("SOCIAL", style: TextStyle(fontSize: 24.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      setState(() {
                        msg(num_s, nci_s, fb_s);
                        createSo();
                        _toSocial(context);
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(0),
                  child: RaisedButton(
                    child: const Text("GOAL", style: TextStyle(fontSize: 24.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      _toGoal(context);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(0),
                  child: RaisedButton(
                    child: const Text("REWARD", style: TextStyle(fontSize: 24.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      _toReward(context);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(0),
                  child: RaisedButton(
                    child: const Text("APPOINTMENT", style: TextStyle(fontSize: 22.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      _toAppointment(context);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(0),
                  child: RaisedButton(
                    child: const Text("LOG OUT", style: TextStyle(fontSize: 24.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      _toLogin(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    )
  );
}

class Health extends StatefulWidget {
  @override
  _health createState() => _health();
}

class _health extends State<Health> {
  _date() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  int duration = 0, goal = 0;
  bool redeem = false;

  final user = FirebaseAuth.instance.currentUser!;

  read() {
    Stream<List<ExerciseClass>> readExercise() => FirebaseFirestore.instance
        .collection('TrackApp/${user.email!}/Exercise')
        .where('Date', isEqualTo: _date())
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ExerciseClass.fromJson(doc.data())).toList());
    return readExercise();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMain(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Health", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toMain(context);
          },
        ),
      ),
      body: StreamBuilder<List<ExerciseClass>>(
        stream: read(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final users = snapshot.data!.toList();
            duration = users.first.duration;
            if (duration > users.first.goal) {
              goal = duration;
            } else {
              goal = users.first.goal;
            }
            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(child: Column(children: <Widget>[
                  const SizedBox(height: 30),
                  LinearPercentIndicator(
                    alignment: MainAxisAlignment.center,
                    width: 300.0,
                    lineHeight: 50.0,
                    percent: duration/goal,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                  ),
                  const SizedBox(height: 30),
                  Text("Currently: ${(users.first.duration ~/ 60).toString().padLeft(2, "0")} hrs ${(users.first.duration % 60).toString().padLeft(2, "0")} min",
                      style: const TextStyle(fontSize: 28.0)),
                  const SizedBox(height: 30),
                  Text("Target: ${(users.first.goal ~/ 60).toString().padLeft(2, "0")} hrs ${(users.first.goal % 60).toString().padLeft(2, "0")} min",
                      style: const TextStyle(fontSize: 28.0)),
                  Container(
                    margin: const EdgeInsets.all(25),
                    child: RaisedButton(
                      child: const Text("Add", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed: () {
                        _toHealthUpdate(context);
                      },
                    ),
                  ),
                ]))
              ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    )
  );
}

class HealthUpdate extends StatefulWidget {
  @override
  _healthupdate createState() => _healthupdate();
}

class _healthupdate extends State<HealthUpdate> {
  _date(DateTime now) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  final user = FirebaseAuth.instance.currentUser!;

  final controllerHour = TextEditingController();
  final controllerMin = TextEditingController();

  Stream<List<GoalClass>> readGoal() => FirebaseFirestore.instance
      .collection('TrackApp/${user.email!}/Goal')
      .where('Type', isEqualTo: "Exercise")
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => GoalClass.fromJson(doc.data())).toList());

  int ogduration = 0, duration = 0, coins = 0;
  bool redeem = false;

  update(int goal) {
    final docUser = FirebaseFirestore.instance
        .collection("TrackApp/${user.email}/Exercise")
        .doc("Exercise_${_date(DateTime.now())}");
    try {
      FirebaseFirestore.instance.collection("TrackApp/${user.email}/Exercise").where('Date', isEqualTo: _date(DateTime.now())).get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          setState(() {
            ogduration = result.data()["Duration"];
            redeem = result.data()["Redeem"];
          });
          if ((duration+ogduration) > 480) {
            Fluttertoast.showToast(
              toastLength: Toast.LENGTH_LONG,
              msg: "Duration can't exceed 8 hr.",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 30
            );
          }
          else {
            docUser.update({'Duration': duration+ogduration});
            docUser.update({'Goal': goal});
            if (duration >= goal) {
              if (goal != 0) {
                if (redeem == false) {
                  FirebaseFirestore.instance.collection('TrackApp').where('Email', isEqualTo: user.email).get().then((querySnapshot) {
                    for (var result in querySnapshot.docs) {
                      setState(() {
                        coins = result.data()["Coins"];
                      });
                    }
                    final addcoin = FirebaseFirestore.instance
                        .collection("TrackApp")
                        .doc(user.email);
                    setState(() {
                      coins++;
                    });
                    addcoin.update({'Coins': coins});
                  });
                  docUser.update({'Redeem': true});
                }
                Fluttertoast.showToast(
                  toastLength: Toast.LENGTH_LONG,
                  msg: "Congrats! You’re an achiever!",
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 30
                );
              } else {
                Fluttertoast.showToast(
                  toastLength: Toast.LENGTH_LONG,
                  msg: random(),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 30
                );
              }
            } else {
              Fluttertoast.showToast(
                toastLength: Toast.LENGTH_LONG,
                msg: random(),
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 30
              );
            }
            _toHealth(context);
          }
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  random() {
    final num = Random().nextInt(2);
    if (num == 0) {
      return "Thank you for being the best version of yourself! Keep Going!";
    } else {
      return "Healthy life = happy life. Let's go!";
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toHealth(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Health", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toHealth(context);
          },
        ),
      ),
      body: StreamBuilder<List<GoalClass>>(
        stream: readGoal(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final goals = snapshot.data!.toList();
            return ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                Center(child: Column(children: <Widget>[
                  const SizedBox(height: 30),
                  Text("Add exercise duration", style: const TextStyle(fontSize: 28.0)),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controllerHour,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      hintText: 'Hours',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controllerMin,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      hintText: 'Minutes',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.all(25),
                    child: RaisedButton(
                      child: const Text("Done", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed: () {
                        if (controllerHour.text != "" || controllerMin.text != "") {
                          if (controllerHour.text == "") {
                            duration = int.parse(controllerMin.text);
                          }
                          else if (controllerMin.text == "") {
                            duration = int.parse(controllerHour.text)*60;
                          }
                          else {
                            duration = (int.parse(controllerHour.text)*60)+int.parse(controllerMin.text);
                          }
                          if (duration < 0) {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: "Duration can't be less than 0 min.",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 30
                            );
                          }
                          else if (duration > 480) {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: "Duration can't exceed 8 hr.",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 30
                            );
                          }
                          else {
                            showDialog(context: context, builder:
                                (context)=> AlertDialog(
                              content:Column(
                                mainAxisSize: MainAxisSize.min,
                                children:const <Widget> [
                                  Text("Confirm update?", style: TextStyle(fontSize: 24.0)),
                                ],
                              ),
                              actions: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: RaisedButton(
                                    child: const Text("Yes", style: TextStyle(fontSize: 28.0, color: Colors.white)),
                                    color: Colors.redAccent,
                                    onPressed: () {
                                      update(goals.first.goal);
                                    },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: RaisedButton(
                                    child: const Text("No", style: TextStyle(fontSize: 28.0, color: Colors.redAccent)),
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            )
                            );
                          }
                        }
                      },
                    ),
                  )
                ]))
              ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    )
  );
}

class Diet extends StatefulWidget {
  @override
  _diet createState() => _diet();
}

class _diet extends State<Diet> {
  _date() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  int goal = 0, value = 0;

  bool breakfast = false;
  bool lunch = false;
  bool teatime = false;
  bool dinner = false;
  bool supper = false;
  bool redeem = false;

  final user = FirebaseAuth.instance.currentUser!;

  read() {
    Stream<List<DietClass>> readDiet() => FirebaseFirestore.instance
        .collection('TrackApp/${user.email!}/Diet')
        .where('Date', isEqualTo: _date())
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DietClass.fromJson(doc.data())).toList());
    return readDiet();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMain(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Diet", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toMain(context);
          },
        ),
      ),
      body: StreamBuilder<List<DietClass>>(
        stream: read(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final users = snapshot.data!.toList();
            List<bool> trueNum = [
              users.first.breakfast,
              users.first.lunch,
              users.first.teatime,
              users.first.dinner,
              users.first.supper,
            ];
            value = trueNum.where((item) => item == true).length;
            if (value > users.first.goal) {
              goal = value;
            } else {
              goal = users.first.goal;
            }
            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(child: Column(children: <Widget>[
                  const SizedBox(height: 30),
                  LinearPercentIndicator(
                    alignment: MainAxisAlignment.center,
                    width: 300.0,
                    lineHeight: 50.0,
                    percent: value/goal,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                  ),
                  const SizedBox(height: 30),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: users.first.breakfast,
                    title: const Text('Breakfast', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {},
                  ),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: users.first.lunch,
                    title: const Text('Lunch', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {},
                  ),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: users.first.teatime,
                    title: const Text('Tea Time', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {},
                  ),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: users.first.dinner,
                    title: const Text('Dinner', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {},
                  ),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: users.first.supper,
                    title: const Text('Supper', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {},
                  ),
                  Container(
                    margin: const EdgeInsets.all(25),
                    child: RaisedButton(
                      child: const Text("Update", style: TextStyle(fontSize: 24.0, color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed: () {
                        _toDietUpdate(context);
                      },
                    ),
                  ),
                ]))
              ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    )
  );
}

class DietUpdate extends StatefulWidget {
  @override
  _dietupdate createState() => _dietupdate();
}

class _dietupdate extends State<DietUpdate> {
  _date(DateTime now) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  final user = FirebaseAuth.instance.currentUser!;

  bool changed = false;
  bool breakfast = false;
  bool lunch = false;
  bool teatime = false;
  bool dinner = false;
  bool supper = false;

  Stream<List<GoalClass>> readGoal() => FirebaseFirestore.instance
      .collection('TrackApp/${user.email!}/Goal')
      .where('Type', isEqualTo: "Diet")
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => GoalClass.fromJson(doc.data())).toList());

  int coins = 0;
  bool redeem = false;

  update(int goal) {
    final docUser = FirebaseFirestore.instance
        .collection("TrackApp/${user.email}/Diet")
        .doc("Diet_${_date(DateTime.now())}");
    try {
      FirebaseFirestore.instance.collection("TrackApp/${user.email}/Diet").where('Date', isEqualTo: _date(DateTime.now())).get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          setState(() {
            redeem = result.data()["Redeem"];
          });
          docUser.update({'Goal': goal});
          docUser.update({'Breakfast': breakfast});
          docUser.update({'Lunch': lunch});
          docUser.update({'Teatime': teatime});
          docUser.update({'Dinner': dinner});
          docUser.update({'Supper': supper});
          if (count >= goal) {
            if (goal != 0) {
              if (redeem == false) {
                FirebaseFirestore.instance.collection('TrackApp').where('Email', isEqualTo: user.email).get().then((querySnapshot) {
                  for (var result in querySnapshot.docs) {
                    setState(() {
                      coins = result.data()["Coins"];
                    });
                  }
                  final addcoin = FirebaseFirestore.instance
                      .collection("TrackApp")
                      .doc(user.email);
                  setState(() {
                    coins++;
                  });
                  addcoin.update({'Coins': coins});
                });
                docUser.update({'Redeem': true});
              }
              Fluttertoast.showToast(
                toastLength: Toast.LENGTH_LONG,
                msg: "Congrats! You’re an achiever!",
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 30
              );
            } else {
              Fluttertoast.showToast(
                toastLength: Toast.LENGTH_LONG,
                msg: random(),
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 30
              );
            }
          } else {
            Fluttertoast.showToast(
              toastLength: Toast.LENGTH_LONG,
              msg: random(),
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 30
            );
          }
        }
      });
      _toDiet(context);
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  int count = 0;

  countbool() {
    if (breakfast == true) {
      setState(() {
        count += 1;
      });
    }
    if (lunch == true) {
      setState(() {
        count += 1;
      });
    }
    if (teatime == true) {
      setState(() {
        count += 1;
      });
    }
    if (dinner == true) {
      setState(() {
        count += 1;
      });
    }
    if (supper == true) {
      setState(() {
        count += 1;
      });
    }
  }

  random() {
    final num = Random().nextInt(2);
    if (num == 0) {
      return "Healthy food = healthy life. Keep going!";
    } else {
      return "Eats more green. Let's go!";
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toDiet(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Diet", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toDiet(context);
          },
        ),
      ),
      body: StreamBuilder<List<GoalClass>>(
        stream: readGoal(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final goals = snapshot.data!.toList();
            if (changed == false) {
              FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Diet').doc("Diet_${_date(DateTime.now())}").get().then((value){
                setState(() {
                  breakfast = value.data()!["Breakfast"];
                  lunch = value.data()!["Lunch"];
                  teatime = value.data()!["Teatime"];
                  dinner = value.data()!["Dinner"];
                  supper = value.data()!["Supper"];
                });
              });
            };
            changed = true;
            return ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                Center(child: Column(children: <Widget>[
                  const SizedBox(height: 30),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: breakfast,
                    title: const Text('Breakfast', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {
                      setState(() {
                        breakfast = newValue!;
                      });
                    },
                  ),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: lunch,
                    title: const Text('Lunch', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {
                      setState(() {
                        lunch = newValue!;
                      });
                    },
                  ),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: teatime,
                    title: const Text('Tea Time', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {
                      setState(() {
                        teatime = newValue!;
                      });
                    },
                  ),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: dinner,
                    title: const Text('Dinner', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {
                      setState(() {
                        dinner = newValue!;
                      });
                    },
                  ),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 20,
                  ),
                  CheckboxListTile(
                    activeColor: Colors.redAccent,
                    value: supper,
                    title: const Text('Supper', style: TextStyle(fontSize: 30.0)),
                    onChanged: (bool? newValue) {
                      setState(() {
                        supper = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.all(25),
                    child: RaisedButton(
                      child: const Text("Done", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed: () {
                        countbool();
                        showDialog(context: context, builder:
                            (context)=> AlertDialog(
                          content:Column(
                            mainAxisSize: MainAxisSize.min,
                            children:const <Widget> [
                              Text("Confirm update?", style: TextStyle(fontSize: 24.0)),
                            ],
                          ),
                          actions: [
                            Container(
                              margin: EdgeInsets.all(10),
                              child: RaisedButton(
                                child: const Text("Yes", style: TextStyle(fontSize: 28.0, color: Colors.white)),
                                color: Colors.redAccent,
                                onPressed: () {
                                  update(goals.first.goal);
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: RaisedButton(
                                child: const Text("No", style: TextStyle(fontSize: 28.0, color: Colors.redAccent)),
                                color: Colors.white,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        )
                        );
                      },
                    ),
                  )
                ]))
              ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    )
  );
}

class Finance extends StatefulWidget {
  @override
  _finance createState() => _finance();
}

class _finance extends State<Finance> {
  _date() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  double amount = 0, goal = 0, bal = 0;
  bool redeem = false;

  final user = FirebaseAuth.instance.currentUser!;

  read() {
    Stream<List<FinanceClass>> readFinance() => FirebaseFirestore.instance
        .collection('TrackApp/${user.email!}/Finance')
        .where('Date', isEqualTo: _date())
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FinanceClass.fromJson(doc.data())).toList());
    return readFinance();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMain(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Finance", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toMain(context);
          },
        ),
      ),
      body: StreamBuilder<List<FinanceClass>>(
        stream: read(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final users = snapshot.data!.toList();
            amount = users.first.amt;
            if (amount > users.first.goal) {
              goal = amount;
              bal = 0;
            } else {
              goal = users.first.goal;
              bal = goal - amount;
            }
            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(child: Column(children: <Widget>[
                  const SizedBox(height: 30),
                  LinearPercentIndicator(
                    alignment: MainAxisAlignment.center,
                    width: 300.0,
                    lineHeight: 50.0,
                    percent: amount/goal,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                  ),
                  const SizedBox(height: 30),
                  Text("Currently: SGD ${(users.first.amt).toDouble().toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 28.0)),
                  const SizedBox(height: 30),
                  Text("Target: SGD ${((users.first.goal).toDouble()).toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 28.0)),
                  const SizedBox(height: 30),
                  Text("Balance: SGD ${(bal).toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 28.0)),
                  Container(
                    margin: const EdgeInsets.all(25),
                    child: RaisedButton(
                      child: const Text("Add", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed: () {
                        _toFinanceUpdate(context);
                      },
                    ),
                  ),
                ]))
              ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    )
  );
}

class FinanceUpdate extends StatefulWidget {
  @override
  _financeupdate createState() => _financeupdate();
}

class _financeupdate extends State<FinanceUpdate> {
  _date(DateTime now) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  final user = FirebaseAuth.instance.currentUser!;

  final controllerAmount = TextEditingController();

  Stream<List<FinGoalClass>> readGoal() => FirebaseFirestore.instance
      .collection('TrackApp/${user.email!}/Goal')
      .where('Type', isEqualTo: "Finance")
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => FinGoalClass.fromJson(doc.data())).toList());

  double ogamt = 0;

  update(double goal) {
    final docUser = FirebaseFirestore.instance
        .collection("TrackApp/${user.email}/Finance")
        .doc("Finance_${_date(DateTime.now())}");
    try {
      FirebaseFirestore.instance.collection("TrackApp/${user.email}/Finance").where('Date', isEqualTo: _date(DateTime.now())).get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          setState(() {
            ogamt = result.data()["Amt"].toDouble();
          });
          docUser.update({'Amt': ((double.parse(controllerAmount.text))+ogamt)});
          docUser.update({'Goal': goal});
          Fluttertoast.showToast(
            toastLength: Toast.LENGTH_LONG,
            msg: random(),
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 30
          );
          _toFinance(context);
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  random() {
    final num = Random().nextInt(2);
    if (num == 0) {
      return "Thank you for being the best version of yourself! Keep Going!";
    } else {
      return "Many a little makes a mickle.";
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toFinance(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Finance", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toFinance(context);
          },
        ),
      ),
      body: StreamBuilder<List<FinGoalClass>>(
        stream: readGoal(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final goals = snapshot.data!.toList();
            return ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                Center(child: Column(children: <Widget>[
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controllerAmount,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      hintText: 'Add expense',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.all(25),
                    child: RaisedButton(
                      child: const Text("Done", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed: () {
                        String stramt = "";
                        String decimals = "";
                        if (controllerAmount.text != "") {
                          stramt = controllerAmount.text+".";
                          List<String> numstr = stramt.split(".");
                          if (numstr.isNotEmpty) {
                            if (numstr[1].isNotEmpty) {
                              decimals = numstr[1];
                            }
                          }
                          if (double.parse(controllerAmount.text) < 0) {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: "Expenses can't be less than SGD 0.",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 30
                            );
                          }
                          else if (decimals.length > 2) {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: "Expenses can't exceed 2 decimal place.",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 30
                            );
                          }
                          else if (controllerAmount.text == "-0") {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: "-0 is not a valid number.",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 30
                            );
                          }
                          else{
                            showDialog(context: context, builder:
                                (context)=> AlertDialog(
                              content:Column(
                                mainAxisSize: MainAxisSize.min,
                                children:const <Widget> [
                                  Text("Confirm update?", style: TextStyle(fontSize: 24.0)),
                                ],
                              ),
                              actions: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: RaisedButton(
                                    child: const Text("Yes", style: TextStyle(fontSize: 28.0, color: Colors.white)),
                                    color: Colors.redAccent,
                                    onPressed: () {
                                      update(goals.first.goal);
                                    },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: RaisedButton(
                                    child: const Text("No", style: TextStyle(fontSize: 28.0, color: Colors.redAccent)),
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            )
                            );
                          }
                        }
                      },
                    ),
                  )
                ]))
              ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    )
  );
}

class Social extends StatefulWidget {
  @override
  _social createState() => _social();
}

class _social extends State<Social> {
  _date() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  int duration = 0, goal = 0;
  bool redeem = false;

  final user = FirebaseAuth.instance.currentUser!;

  read() {
    Stream<List<SocialClass>> readSocial() => FirebaseFirestore.instance
        .collection('TrackApp/${user.email!}/Social')
        .where('Date', isEqualTo: _date())
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SocialClass.fromJson(doc.data())).toList());
    return readSocial();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMain(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Social", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toMain(context);
          },
        ),
      ),
      body: StreamBuilder<List<SocialClass>>(
        stream: read(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final users = snapshot.data!.toList();
            duration = users.first.duration;
            if (duration > users.first.goal) {
              goal = duration;
            } else {
              goal = users.first.goal;
            }
            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(child: Column(children: <Widget>[
                  const SizedBox(height: 30),
                  LinearPercentIndicator(
                    alignment: MainAxisAlignment.center,
                    width: 300.0,
                    lineHeight: 50.0,
                    percent: duration/goal,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.blue,
                  ),
                  const SizedBox(height: 30),
                  Text("Currently: ${(users.first.duration ~/ 60).toString().padLeft(2, "0")} hrs ${(users.first.duration % 60).toString().padLeft(2, "0")} min",
                      style: const TextStyle(fontSize: 28.0)),
                  const SizedBox(height: 30),
                  Text("Target: ${(users.first.goal ~/ 60).toString().padLeft(2, "0")} hrs ${(users.first.goal % 60).toString().padLeft(2, "0")} min",
                      style: const TextStyle(fontSize: 28.0)),
                  Container(
                    margin: const EdgeInsets.all(25),
                    child: RaisedButton(
                      child: const Text("Add", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed: () {
                        _toSocialUpdate(context);
                      },
                    ),
                  ),
                ]))
              ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    )
  );
}

class SocialUpdate extends StatefulWidget {
  @override
  _socialupdate createState() => _socialupdate();
}

class _socialupdate extends State<SocialUpdate> {
  _date(DateTime now) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  final user = FirebaseAuth.instance.currentUser!;

  final controllerHour = TextEditingController();
  final controllerMin = TextEditingController();

  Stream<List<GoalClass>> readGoal() => FirebaseFirestore.instance
      .collection('TrackApp/${user.email!}/Goal')
      .where('Type', isEqualTo: "Social")
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => GoalClass.fromJson(doc.data())).toList());

  int ogduration = 0, duration = 0, coins = 0;
  bool redeem = false;

  update(int goal) {
    final docUser = FirebaseFirestore.instance
        .collection("TrackApp/${user.email}/Social")
        .doc("Social_${_date(DateTime.now())}");
    try {
      FirebaseFirestore.instance.collection("TrackApp/${user.email}/Social").where('Date', isEqualTo: _date(DateTime.now())).get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          setState(() {
            ogduration = result.data()["Duration"];
            redeem = result.data()["Redeem"];
          });
          if ((duration+ogduration) > 960) {
            Fluttertoast.showToast(
              toastLength: Toast.LENGTH_LONG,
              msg: "Duration can't exceed 16 hr.",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 30
            );
          }
          else {
            docUser.update({'Duration': duration+ogduration});
            docUser.update({'Goal': goal});
            if (duration >= goal) {
              if (goal != 0) {
                if (redeem == false) {
                  FirebaseFirestore.instance.collection('TrackApp').where('Email', isEqualTo: user.email).get().then((querySnapshot) {
                    for (var result in querySnapshot.docs) {
                      setState(() {
                        coins = result.data()["Coins"];
                      });
                    }
                    final addcoin = FirebaseFirestore.instance
                        .collection("TrackApp")
                        .doc(user.email);
                    setState(() {
                      coins++;
                    });
                    addcoin.update({'Coins': coins});
                  });
                  docUser.update({'Redeem': true});
                }
                Fluttertoast.showToast(
                  toastLength: Toast.LENGTH_LONG,
                  msg: "Congrats! You’re an achiever!",
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 30
                );
              } else {
                Fluttertoast.showToast(
                  toastLength: Toast.LENGTH_LONG,
                  msg: random(),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 30
                );
              }
            } else {
              Fluttertoast.showToast(
                toastLength: Toast.LENGTH_LONG,
                msg: random(),
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 30
              );
            }
            _toSocial(context);
          }
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  random() {
    final num = Random().nextInt(2);
    if (num == 0) {
      return "Thank you for being the best version of yourself! Keep Going!";
    } else {
      return "Healthy mind = happy life. Let's go!";
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toSocial(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Social", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toSocial(context);
          },
        ),
      ),
      body: StreamBuilder<List<GoalClass>>(
        stream: readGoal(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final goals = snapshot.data!.toList();
            return ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                Center(child: Column(children: <Widget>[
                  const SizedBox(height: 30),
                  Text("Add social interaction duration", style: const TextStyle(fontSize: 26.0)),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controllerHour,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      hintText: 'Hours',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controllerMin,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      hintText: 'Minutes',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.all(25),
                    child: RaisedButton(
                      child: const Text("Done", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed: () {
                        if (controllerHour.text != "" || controllerMin.text != "") {
                          if (controllerHour.text == "") {
                            duration = int.parse(controllerMin.text);
                          }
                          else if (controllerMin.text == "") {
                            duration = int.parse(controllerHour.text)*60;
                          }
                          else {
                            duration = (int.parse(controllerHour.text)*60)+int.parse(controllerMin.text);
                          }
                          if (duration < 0) {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: "Duration can't be less than 0 min.",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 30
                            );
                          }
                          else if (duration > 960) {
                            Fluttertoast.showToast(
                              toastLength: Toast.LENGTH_LONG,
                              msg: "Duration can't exceed 16 hr.",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 30
                            );
                          }
                          else {
                            showDialog(context: context, builder:
                                (context)=> AlertDialog(
                              content:Column(
                                mainAxisSize: MainAxisSize.min,
                                children:const <Widget> [
                                  Text("Confirm update?", style: TextStyle(fontSize: 24.0)),
                                ],
                              ),
                              actions: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: RaisedButton(
                                    child: const Text("Yes", style: TextStyle(fontSize: 28.0, color: Colors.white)),
                                    color: Colors.redAccent,
                                    onPressed: () {
                                      update(goals.first.goal);
                                    },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: RaisedButton(
                                    child: const Text("No", style: TextStyle(fontSize: 28.0, color: Colors.redAccent)),
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            )
                            );
                          }
                        }
                      },
                    ),
                  )
                ]))
              ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    )
  );
}

class Goal extends StatefulWidget {
  @override
  _goal createState() => _goal();
}

class _goal extends State<Goal> with SingleTickerProviderStateMixin {
  String dropdownnum = "3";
  var nums = ["3", "4", "5"];
  bool changed = false;

  int exercise_conf = 1, diet_conf = 1, finance_conf = 1, social_conf = 1;
  int exercise_duration = 0, social_duration = 0;
  double finance_amount = 0;

  late TabController _tabController;
  final controllerExercise = TextEditingController();
  final controllerDiet = TextEditingController();
  final controllerFinance = TextEditingController();
  final controllerSocial = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _date(DateTime now) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  final user = FirebaseAuth.instance.currentUser!;

  readExercise() {
    FirebaseFirestore.instance.collection('TrackApp/${user.email}/Goal').doc("Exercise").get().then((doc) => {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection("TrackApp/${user.email}/Goal").doc("Exercise").set(
          {
            "Conf" : 1,
            "Goal" : 0,
            "Type" : "Exercise"
          },
          SetOptions(merge : true))
      }
    });
    Stream<List<GoalClass>> readGoal() => FirebaseFirestore.instance
        .collection('TrackApp/${user.email!}/Goal')
        .where('Type', isEqualTo: "Exercise")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GoalClass.fromJson(doc.data())).toList());
    return readGoal();
  }

  readDiet() {
    FirebaseFirestore.instance.collection('TrackApp/${user.email}/Goal').doc("Diet").get().then((doc) => {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection("TrackApp/${user.email}/Goal").doc("Diet").set(
          {
            "Conf" : 1,
            "Goal" : 3,
            "Type" : "Diet"
          },
          SetOptions(merge : true))
      }
    });
    Stream<List<GoalClass>> readGoal() => FirebaseFirestore.instance
        .collection('TrackApp/${user.email!}/Goal')
        .where('Type', isEqualTo: "Diet")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GoalClass.fromJson(doc.data())).toList());
    return readGoal();
  }

  readFinance() {
    FirebaseFirestore.instance.collection('TrackApp/${user.email}/Goal').doc("Finance").get().then((doc) => {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection("TrackApp/${user.email}/Goal").doc("Finance").set(
          {
            "Conf" : 1,
            "Goal" : 0,
            "Type" : "Finance"
          },
          SetOptions(merge : true))
      }
    });
    Stream<List<FinGoalClass>> readGoal() => FirebaseFirestore.instance
        .collection('TrackApp/${user.email!}/Goal')
        .where('Type', isEqualTo: "Finance")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FinGoalClass.fromJson(doc.data())).toList());
    return readGoal();
  }

  readSocial() {
    FirebaseFirestore.instance.collection('TrackApp/${user.email}/Goal').doc("Social").get().then((doc) => {
      if (!doc.exists) {
        FirebaseFirestore.instance.collection("TrackApp/${user.email}/Goal").doc("Social").set(
          {
            "Conf" : 1,
            "Goal" : 0,
            "Type" : "Social"
          },
          SetOptions(merge : true))
      }
    });
    Stream<List<GoalClass>> readGoal() => FirebaseFirestore.instance
        .collection('TrackApp/${user.email!}/Goal')
        .where('Type', isEqualTo: "Social")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GoalClass.fromJson(doc.data())).toList());
    return readGoal();
  }

  updateExGoal() {
    final docUser = FirebaseFirestore.instance
        .collection("TrackApp/${user.email}/Goal")
        .doc("Exercise");
    try {
      docUser.update({'Conf': exercise_conf});
      docUser.update({'Goal': int.parse(controllerExercise.text)});
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Update successfully",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
      askSupport(exercise_conf);
      controllerExercise.text = "";
      exercise_conf = 1;
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  updateDietGoal() {
    final docUser = FirebaseFirestore.instance
        .collection("TrackApp/${user.email}/Goal")
        .doc("Diet");
    try {
      docUser.update({'Conf': diet_conf});
      docUser.update({'Goal': int.parse(dropdownnum)});
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Update successfully",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
      askSupport(diet_conf);
      changed = false;
      diet_conf = 1;
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  updateFinGoal() {
    final docUser = FirebaseFirestore.instance
        .collection("TrackApp/${user.email}/Goal")
        .doc("Finance");
    try {
      docUser.update({'Conf': finance_conf});
      docUser.update({'Goal': double.parse(controllerFinance.text)});
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Update successfully",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
      askSupport(finance_conf);
      controllerFinance.text = "";
      finance_conf = 1;
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  updateSoGoal() {
    final docUser = FirebaseFirestore.instance
        .collection("TrackApp/${user.email}/Goal")
        .doc("Social");
    try {
      docUser.update({'Conf': social_conf});
      docUser.update({'Goal': int.parse(controllerSocial.text)});
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Update successfully",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
      askSupport(social_conf);
      controllerSocial.text = "";
      social_conf = 1;
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  askSupport(int conf) {
    if (conf <= 2) {
      showDialog(context: context, builder:
          (context)=> AlertDialog(
        content:Column(
          mainAxisSize: MainAxisSize.min,
          children:const <Widget> [
            Text("It looks like you are", style: TextStyle(fontSize: 24.0)),
            Text("very not confident...", style: TextStyle(fontSize: 24.0)),
            SizedBox(height: 15),
            Text("Do you wish to ask", style: TextStyle(fontSize: 24.0)),
            Text("for advice?", style: TextStyle(fontSize: 24.0)),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(10),
            child: RaisedButton(
              child: const Text("Yes", style: TextStyle(fontSize: 28.0, color: Colors.white)),
              color: Colors.redAccent,
              onPressed: () {
                _toAppointmentUpdate(context);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: RaisedButton(
              child: const Text("No", style: TextStyle(fontSize: 28.0, color: Colors.redAccent)),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
      )
      );
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMain(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Goal", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toMain(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Health", icon: Icon(Icons.run_circle)),
            Tab(text: "Diet", icon: Icon(Icons.fastfood)),
            Tab(text: "Finance", icon: Icon(Icons.attach_money)),
            Tab(text: "Social", icon: Icon(Icons.social_distance))
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: StreamBuilder<List<GoalClass>>(
            stream: readExercise(),
            builder: (context, snapshot)  {
              if (snapshot.hasError) {
                return Text('Something went wrong! ${snapshot.error}');
              } else if (snapshot.hasData) {
                final users = snapshot.data!.toList();
                FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Exercise').doc("Exercise_${_date(DateTime.now().subtract(const Duration(days:1)))}").get().then((doc) => {
                  if (doc.exists) {
                    FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Exercise').doc("Exercise_${_date(DateTime.now().subtract(const Duration(days:1)))}").get().then((value){
                      setState(() {
                        exercise_duration = value.data()!["Duration"];
                      });
                    })
                  }
                });
                return ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(child: Column(children: <Widget>[
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: "Yesterday's total duration: ",
                          hintText: (exercise_duration).toString(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: "Current goal: ",
                          hintText: (users.first.goal).toString(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controllerExercise,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration(
                          hintText: "New goal",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 30),
                      const Text("Confidence level", style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 1,
                                groupValue: exercise_conf,
                                onChanged: (val) {
                                  setState(() {
                                    exercise_conf = 1;
                                  });
                                },
                              ),
                              const Text("1", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 2,
                                groupValue: exercise_conf,
                                onChanged: (val) {
                                  setState(() {
                                    exercise_conf = 2;
                                  });
                                },
                              ),
                              const Text("2", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 3,
                                groupValue: exercise_conf,
                                onChanged: (val) {
                                  setState(() {
                                    exercise_conf = 3;
                                  });
                                },
                              ),
                              const Text("3", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 4,
                                groupValue: exercise_conf,
                                onChanged: (val) {
                                  setState(() {
                                    exercise_conf = 4;
                                  });
                                },
                              ),
                              const Text("4", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 5,
                                groupValue: exercise_conf,
                                onChanged: (val) {
                                  setState(() {
                                    exercise_conf = 5;
                                  });
                                },
                              ),
                              const Text("5", style: TextStyle(fontSize: 18.0)),
                            ]
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(25),
                        child: RaisedButton(
                          child: const Text("Update", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                          color: Colors.redAccent,
                          onPressed: () {
                            if (controllerExercise.text != "") {
                              if (int.parse(controllerExercise.text) < 30) {
                                Fluttertoast.showToast(
                                  toastLength: Toast.LENGTH_LONG,
                                  msg: "Goal can't be less than 30 min.",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 30
                                );
                              }
                              else if (int.parse(controllerExercise.text) > 480) {
                                Fluttertoast.showToast(
                                  toastLength: Toast.LENGTH_LONG,
                                  msg: "Goal can't exceed 8 hr.",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 30
                                );
                              }
                              else {
                                updateExGoal();
                              }
                            }
                          },
                        ),
                      ),
                    ])),
                  ]
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }
          )),
          Center(child: StreamBuilder<List<GoalClass>>(
            stream: readDiet(),
            builder: (context, snapshot)  {
              if (snapshot.hasError) {
                return Text('Something went wrong! ${snapshot.error}');
              } else if (snapshot.hasData) {
                final users = snapshot.data!.toList();
                if (changed == false) {
                  dropdownnum = (users.first.goal).toString();
                }
                return ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(child: Column(children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton(
                            value: dropdownnum,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconEnabledColor: Colors.redAccent,
                            items:nums.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items, style: const TextStyle(fontSize: 40.0))
                              );
                            }
                            ).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownnum = newValue!;
                                changed = true;
                              });
                            },
                          ),
                          const Text("meals per day", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                        ]
                      ),
                      const SizedBox(height: 30),
                      const Divider(
                        height: 20,
                        thickness: 5,
                        indent: 20,
                        endIndent: 20,
                      ),
                      const SizedBox(height: 30),
                      const Text("Confidence level", style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 1,
                                groupValue: diet_conf,
                                onChanged: (val) {
                                  setState(() {
                                    diet_conf = 1;
                                  });
                                },
                              ),
                              const Text("1", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 2,
                                groupValue: diet_conf,
                                onChanged: (val) {
                                  setState(() {
                                    diet_conf = 2;
                                  });
                                },
                              ),
                              const Text("2", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 3,
                                groupValue: diet_conf,
                                onChanged: (val) {
                                  setState(() {
                                    diet_conf = 3;
                                  });
                                },
                              ),
                              const Text("3", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 4,
                                groupValue: diet_conf,
                                onChanged: (val) {
                                  setState(() {
                                    diet_conf = 4;
                                  });
                                },
                              ),
                              const Text("4", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 5,
                                groupValue: diet_conf,
                                onChanged: (val) {
                                  setState(() {
                                    diet_conf = 5;
                                  });
                                },
                              ),
                              const Text("5", style: TextStyle(fontSize: 18.0)),
                            ]
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(25),
                        child: RaisedButton(
                          child: const Text("Update", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                          color: Colors.redAccent,
                          onPressed: () {
                            if (dropdownnum != "") {
                              updateDietGoal();
                            }
                          },
                        ),
                      ),
                    ])),
                  ]
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }
          )),
          Center(child: StreamBuilder<List<FinGoalClass>>(
            stream: readFinance(),
            builder: (context, snapshot)  {
              if (snapshot.hasError) {
                return Text('Something went wrong! ${snapshot.error}');
              } else if (snapshot.hasData) {
                final users = snapshot.data!.toList();
                FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Finance').doc("Finance_${_date(DateTime.now().subtract(const Duration(days:1)))}").get().then((doc) => {
                  if (doc.exists) {
                    FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Finance').doc("Finance_${_date(DateTime.now().subtract(const Duration(days:1)))}").get().then((value){
                      setState(() {
                        finance_amount = (value.data()!["Amt"]);
                      });
                    })
                  }
                });
                return ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(child: Column(children: <Widget>[
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: "Yesterday's total expenses: ",
                          hintText: (finance_amount).toString(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: "Current budget: ",
                          hintText: (users.first.goal).toDouble().toString(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controllerFinance,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration(
                          hintText: "New budget",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 30),
                      const Text("Confidence level", style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 1,
                                groupValue: finance_conf,
                                onChanged: (val) {
                                  setState(() {
                                    finance_conf = 1;
                                  });
                                },
                              ),
                              const Text("1", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 2,
                                groupValue: finance_conf,
                                onChanged: (val) {
                                  setState(() {
                                    finance_conf = 2;
                                  });
                                },
                              ),
                              const Text("2", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 3,
                                groupValue: finance_conf,
                                onChanged: (val) {
                                  setState(() {
                                    finance_conf = 3;
                                  });
                                },
                              ),
                              const Text("3", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 4,
                                groupValue: finance_conf,
                                onChanged: (val) {
                                  setState(() {
                                    finance_conf = 4;
                                  });
                                },
                              ),
                              const Text("4", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 5,
                                groupValue: finance_conf,
                                onChanged: (val) {
                                  setState(() {
                                    finance_conf = 5;
                                  });
                                },
                              ),
                              const Text("5", style: TextStyle(fontSize: 18.0)),
                            ]
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(25),
                        child: RaisedButton(
                          child: const Text("Update", style: TextStyle(fontSize: 28.0, color: Colors.white)),
                          color: Colors.redAccent,
                          onPressed: () {
                            String stramt = "";
                            String decimals = "";
                            if (controllerFinance.text != "") {
                              stramt = controllerFinance.text+".";
                              List<String> numstr = stramt.split(".");
                              if (numstr.isNotEmpty) {
                                if (numstr[1].isNotEmpty) {
                                  decimals = numstr[1];
                                }
                              }
                              if (double.parse(controllerFinance.text) < 1) {
                                Fluttertoast.showToast(
                                  toastLength: Toast.LENGTH_LONG,
                                  msg: "Budget can't be less than SGD 1.",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 30
                                );
                              }
                              else if (decimals.length > 2) {
                                Fluttertoast.showToast(
                                  toastLength: Toast.LENGTH_LONG,
                                  msg: "Budget can't exceed 2 decimal place.",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 30
                                );
                              }
                              else{
                                updateFinGoal();
                              }
                            }
                          },
                        ),
                      ),
                    ])),
                  ]
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }
          )),
          Center(child: StreamBuilder<List<GoalClass>>(
            stream: readSocial(),
            builder: (context, snapshot)  {
              if (snapshot.hasError) {
                return Text('Something went wrong! ${snapshot.error}');
              } else if (snapshot.hasData) {
                final users = snapshot.data!.toList();
                FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Social').doc("Social_${_date(DateTime.now().subtract(const Duration(days:1)))}").get().then((doc) => {
                  if (doc.exists) {
                    FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Social').doc("Social_${_date(DateTime.now().subtract(const Duration(days:1)))}").get().then((value){
                      setState(() {
                        social_duration = value.data()!["Duration"];
                      });
                    })
                  }
                });
                return ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(child: Column(children: <Widget>[
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: "Yesterday's total duration: ",
                          hintText: (social_duration).toString(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: "Current goal: ",
                          hintText: (users.first.goal).toString(),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controllerSocial,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration(
                          hintText: "New goal",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 30),
                      const Text("Confidence level", style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 1,
                                groupValue: social_conf,
                                onChanged: (val) {
                                  setState(() {
                                    social_conf = 1;
                                  });
                                },
                              ),
                              const Text("1", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 2,
                                groupValue: social_conf,
                                onChanged: (val) {
                                  setState(() {
                                    social_conf = 2;
                                  });
                                },
                              ),
                              const Text("2", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 3,
                                groupValue: social_conf,
                                onChanged: (val) {
                                  setState(() {
                                    social_conf = 3;
                                  });
                                },
                              ),
                              const Text("3", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 4,
                                groupValue: social_conf,
                                onChanged: (val) {
                                  setState(() {
                                    social_conf = 4;
                                  });
                                },
                              ),
                              const Text("4", style: TextStyle(fontSize: 18.0)),
                            ]
                          ),
                          Column(
                            children: <Widget>[
                              Radio(
                                value: 5,
                                groupValue: social_conf,
                                onChanged: (val) {
                                  setState(() {
                                    social_conf = 5;
                                  });
                                },
                              ),
                              const Text("5", style: TextStyle(fontSize: 18.0)),
                            ]
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(25),
                        child: RaisedButton(
                          child: const Text("Update", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                          color: Colors.redAccent,
                          onPressed: () {
                            if (controllerSocial.text != "") {
                              if (int.parse(controllerSocial.text) < 30) {
                                Fluttertoast.showToast(
                                  toastLength: Toast.LENGTH_LONG,
                                  msg: "Goal can't be less than 30 min.",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 30
                                );
                              }
                              else if (int.parse(controllerSocial.text) > 960) {
                                Fluttertoast.showToast(
                                  toastLength: Toast.LENGTH_LONG,
                                  msg: "Goal can't exceed 16 hr.",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 30
                                );
                              }
                              else {
                                updateSoGoal();
                              }
                            }
                          },
                        ),
                      ),
                    ])),
                  ]
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }
          ))
        ]
      )
    )
  );
}

class Reward extends StatefulWidget{
  @override
  _reward createState()=> _reward();
}

class _reward extends State<Reward> {
  final user = FirebaseAuth.instance.currentUser!;

  int coins = 0, total = 0, bal = 0, spend = 0;

  Stream<List<UserClass>> read() => FirebaseFirestore.instance
      .collection('TrackApp')
      .where('Email', isEqualTo: user.email!)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => UserClass.fromJson(doc.data())).toList());

  List<RewardClass> rewardList = [];
  bool duplicate = false;
  var fieldlist = [];

  readList() {
    FirebaseFirestore.instance.collection('TrackApp').where('Type', isEqualTo: 'Reward_List').get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        for (var field in result.data().keys) {
          setState(() {
            fieldlist.add(field);
          });
        }
      }
      for (var field in fieldlist) {
        FirebaseFirestore.instance.collection('TrackApp').where('Type', isEqualTo: 'Reward_List').get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            for (var i in result.data()[field]) {
              var rc = RewardClass(price: int.parse(field), name: i, quantity: 0);

              for (RewardClass r in rewardList) {
                if (r.name == rc.name) {
                  duplicate = true;
                }
              }

              if (duplicate == false) {
                setState(() {
                  rewardList.add(rc);
                });
              }
            }
          }
        });
      }
    });
    rewardList.sort((a, b) {
      var aprice = a.price;
      var bprice = b.price;
      return aprice.compareTo(bprice);
    });
    return rewardList.toSet().toList();
  }

  redeem(int coins, int total) {
    coins = coins - total;
    final docUser = FirebaseFirestore.instance
        .collection("TrackApp")
        .doc(user.email);
    try {
      docUser.update({'Coins': coins});
      for (var data in readList()) {
        if (data.quantity > 0) {
          FirebaseFirestore.instance.collection("TrackApp/${user.email}/Reward").doc("Reward_${DateTime.now()}").set(
            {
              "Date" : DateTime.now(),
              "Name" : data.name,
              "Quantity" : data.quantity
            },
            SetOptions(merge : true));
        }
        data.quantity = 0;
      }
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Redeemed successfully",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
      total = 0;
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  spending(int spend) {
    return spend;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMain(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Reward", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toMain(context);
          },
        ),
      ),
      body: StreamBuilder<List<UserClass>>(
        stream: read(),
        builder: (context, snapshot)  {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final users = snapshot.data!.toList();
            coins = users.first.coin;
            return ListView(
              padding: const EdgeInsets.all(0),
              children: [
                Center(child: Column(children: <Widget>[
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.center,
                    child: Text("Coins: "+coins.toString(), style: const TextStyle(fontSize: 30.0)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Table(
                      border: TableBorder.all(color: Colors.black),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        for (var data in readList())
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(data.name.toString(), style: const TextStyle(fontSize: 24.0), textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("${data.price.toString()} coins", style: const TextStyle(fontSize: 20.0), textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    iconSize: 20,
                                    color: Colors.black,
                                    onPressed: () {
                                      setState(() {
                                        if (data.quantity != 0) {
                                          data.quantity -= 1;
                                          spend = 0;
                                          for (var data in readList()) {
                                            if (data.quantity > 0) {
                                              var count = (data.price * data.quantity) as int;
                                              spend += count;
                                            }
                                          }
                                        }
                                      });
                                    },
                                  ),
                                  Text(data.quantity.toString(), style: const TextStyle(fontSize: 20.0), textAlign: TextAlign.center),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    iconSize: 20,
                                    color: Colors.black,
                                    onPressed: () {
                                      setState(() {
                                        if (data.quantity <= 9) {
                                          data.quantity += 1;
                                          spend = 0;
                                          for (var data in readList()) {
                                            if (data.quantity > 0) {
                                              var count = (data.price * data.quantity) as int;
                                              spend += count;
                                            }
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ],
                              )
                            ),
                          ]),
                      ],
                    )
                  ),
                  const SizedBox(height: 20),
                  Text("You are spending: $spend", style: const TextStyle(fontSize: 24.0)),
                  Container(
                    margin: const EdgeInsets.all(25),
                    child: RaisedButton(
                      child: const Text("Redeem", style: TextStyle(fontSize: 30.0, color: Colors.white),),
                      color: Colors.redAccent,
                      onPressed: () {
                        for (var data in readList()) {
                          if (data.quantity > 0) {
                            var count = (data.price * data.quantity) as int;
                            total += count;
                          }
                        }
                        if (coins == 0) {
                          Fluttertoast.showToast(
                            toastLength: Toast.LENGTH_LONG,
                            msg: "Insufficient coins",
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 30
                          );
                          total = 0;
                        }
                        else if (total == 0) {
                          Fluttertoast.showToast(
                            toastLength: Toast.LENGTH_LONG,
                            msg: "No reward selected",
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 30
                          );
                          total = 0;
                        }
                        else if (coins < total) {
                          Fluttertoast.showToast(
                            toastLength: Toast.LENGTH_LONG,
                            msg: "Insufficient coins",
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 30
                          );
                          total = 0;
                        }
                        else {
                          bal = coins - total;
                          showDialog(context: context, builder:
                              (context)=> AlertDialog(
                            content:Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget> [
                                const Text("Your balance will be", style: TextStyle(fontSize: 24.0)),
                                Text(bal.toString(), style: const TextStyle(fontSize: 24.0)),
                                const Text("Confirm update?", style: TextStyle(fontSize: 24.0)),
                              ],
                            ),
                            actions: [
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: RaisedButton(
                                  child: const Text("Yes", style: TextStyle(fontSize: 28.0, color: Colors.white)),
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    redeem(coins, total);
                                    _toReward(context);
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: RaisedButton(
                                  child: const Text("No", style: TextStyle(fontSize: 28.0, color: Colors.redAccent)),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    total = 0;
                                  },
                                ),
                              ),
                            ],
                          )
                          );
                        }
                      },
                    ),
                  ),
                ]))
              ]
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      )
    )
  );
}

class Appointment extends StatefulWidget{
  @override
  _appointment createState()=> _appointment();
}

class _appointment extends State<Appointment> {
  final user = FirebaseAuth.instance.currentUser!;

  _date() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  List<EventClass> apptlist = [];
  bool duplicate = false;

  readAppt() {
    FirebaseFirestore.instance.collection('TrackApp/${user.email}/Appointment').where("FromDate", isGreaterThanOrEqualTo: _date()).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        var ac = EventClass(
          from: (result.data()["FromDate"] as Timestamp).toDate(),
          to: (result.data()["ToDate"] as Timestamp).toDate(),
          subject: result.data()["Subject"],
          notes: result.data()["Notes"],
          status: result.data()["Status"],
          staff: result.data()["Staff"]
        );

        for (EventClass a in apptlist) {
          if (a.from == ac.from) {
            if (a.subject == ac.subject) {
              setState(() {
                duplicate = true;
              });
            }
          }
        }

        if (duplicate == false) {
          setState(() {
            apptlist.add(ac);
          });
        }

        setState(() {
          duplicate = false;
        });
      }
    });
    apptlist.sort((a, b) {
      var adate = a.from;
      var bdate = b.from;
      return adate.compareTo(bdate);
    });
    return apptlist.toSet().toList();
  }

  _color(int status) {
    if (status == 0) {
      return Colors.black;
    }
    else if (status == 1) {
      return Colors.blueAccent;
    }
    else if (status == 2) {
      return Colors.red;
    }
    else if (status == 3) {
      return Colors.green;
    }
    else {
      return Colors.yellow;
    }
  }

  status(int status) {
    if (status == 0) {
      return "Pending";
    }
    else if (status == 1) {
      return "Approved";
    }
    else if (status == 2) {
      return "Declined";
    }
    else if (status == 3) {
      return "Success";
    }
    else {
      return "Failed";
    }
  }

  _delete(EventClass event) {
    if (event.status == 1) {
      showDialog(context: context, builder:
          (context)=> AlertDialog(
        content:Column(
          mainAxisSize: MainAxisSize.min,
          children:<Widget> [
            const Text("Ops! Sorry.", style: TextStyle(fontSize: 24.0)),
            const SizedBox(height: 15),
            const Text("Approved appointments", style: TextStyle(fontSize: 24.0)),
            const Text("can not be deleted.", style: TextStyle(fontSize: 24.0)),
            const SizedBox(height: 15),
            const Text("If you wish to cancel it,", style: TextStyle(fontSize: 24.0)),
            const Text("please contact WHC.", style: TextStyle(fontSize: 24.0)),
            Container(
              margin: const EdgeInsets.all(10),
              child: RaisedButton(
                child: const Text("Back", style: TextStyle(fontSize: 28.0, color: Colors.white)),
                color: Colors.redAccent,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      )
      );
    } else {
      showDialog(context: context, builder:
          (context)=> AlertDialog(
        content:Column(
          mainAxisSize: MainAxisSize.min,
          children:const <Widget> [
            Text("Are you sure you", style: TextStyle(fontSize: 24.0)),
            Text("wish to delete it?", style: TextStyle(fontSize: 24.0)),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(10),
            child: RaisedButton(
              child: const Text("Yes", style: TextStyle(fontSize: 28.0, color: Colors.white)),
              color: Colors.redAccent,
              onPressed: () {
                FirebaseFirestore.instance.collection("TrackApp/${user.email}/Appointment").doc("Appointment_${event.from}_${event.subject}").delete();
                FirebaseFirestore.instance.collection("TrackApp/${user.email}/Appointment").doc("Appointment_${event.from}_${event.subject}").get().then((doc) => {
                  if (!doc.exists) {
                    Fluttertoast.showToast(
                      toastLength: Toast.LENGTH_LONG,
                      msg: "Deleted successfully",
                      fontSize: 30
                    )
                  } else {
                    Fluttertoast.showToast(
                      toastLength: Toast.LENGTH_LONG,
                      msg: "Failed to delete",
                      fontSize: 30
                    )
                  }
                });
                _toAppointment(context);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: RaisedButton(
              child: const Text("No", style: TextStyle(fontSize: 28.0, color: Colors.redAccent)),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      )
      );
    }
  }

  isyellow(Color color) {
    bool isyellow = false;
    if (color == Colors.yellow) {
      isyellow = true;
    }
    return isyellow;
  }

  @override
  void initState() {
    readAppt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMain(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Appointment", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toMain(context);
          },
        ),
      ),
      body: SafeArea(child: ListView(
        children: [
          Center(child: Column(children: <Widget>[
            for (var data in readAppt())
              ListTile(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("${data.from.day.toString()}/${data.from.month.toString()} (${DateFormat('EEEE').format(data.from)})",
                          style: TextStyle(fontSize: 24.0, color: isyellow(_color(data.status)) ? Colors.black : Colors.white)),
                      const VerticalDivider(
                          thickness: 5,
                          color: Colors.black
                      ),
                      Text("${data.from.hour.toString().padLeft(2, "0")}:${data.from.minute.toString().padLeft(2, "0")} - "
                          "${data.to.hour.toString().padLeft(2, "0")}:${data.to.minute.toString().padLeft(2, "0")}",
                          style: TextStyle(fontSize: 24.0, color: isyellow(_color(data.status)) ? Colors.black : Colors.white)),
                    ]
                ),
                tileColor: _color(data.status),
                contentPadding: const EdgeInsets.all(10.0),
                onTap: () => showDialog(context: context, builder:
                    (context)=> AlertDialog(
                  content:Column(
                    children:<Widget> [
                      const SizedBox(height: 15),
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: 'Subject',
                          hintText: data.subject,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: 'From',
                          hintText: "${data.from.year.toString()}-${data.from.month.toString().padLeft(2, "0")}-${data.from.day.toString().padLeft(2, "0")}, ${data.from.hour.toString().padLeft(2, "0")}:${data.from.minute.toString().padLeft(2, "0")}",
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: 'To',
                          hintText: "${data.to.year.toString()}-${data.to.month.toString().padLeft(2, "0")}-${data.to.day.toString().padLeft(2, "0")}, ${data.to.hour.toString().padLeft(2, "0")}:${data.to.minute.toString().padLeft(2, "0")}",
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: 'Notes',
                          hintText: data.notes,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: 'Status',
                          hintText: status(data.status),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: RaisedButton(
                          child: const Text("Delete", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                          color: Colors.redAccent,
                          onPressed: () {
                            setState(() {
                              _delete(data);
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: RaisedButton(
                          child: const Text("Back", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                          color: Colors.redAccent,
                          onPressed: () {
                            Navigator.pop(context);
                            _appointment;
                          },
                        ),
                      ),
                    ],
                  ),
                )
                ),
              )
          ]))
        ]
      )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.redAccent,
        onPressed: () {
          _toAppointmentUpdate(context);
        },
      ),
    )
  );
}

class AppointmentUpdate extends StatefulWidget{
  final EventClass? event;

  const AppointmentUpdate({
    Key? key,
    this.event
  }) : super(key: key);

  @override
  _appointmentupdate createState()=> _appointmentupdate();
}

class _appointmentupdate extends State<AppointmentUpdate> {
  late DateTime fromDate;
  late DateTime toDate;

  final controllerNotes = TextEditingController();

  String dropdownitem = "Enquires on Health";
  var items = ["Enquires on Health", "Enquires on Diet", "Enquires on Finance", "Enquires on Social", "Enquires on others"];

  _date() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  @override
  void initState() {
    super.initState();

    if (widget.event == null) {
      var date = _date().add(const Duration(days: 1));
      fromDate = date.add(const Duration(minutes: 1));
      toDate = fromDate.add(const Duration(hours: 1));
    } else {
      final event = widget.event!;

      controllerNotes.text = event.subject;
      fromDate = event.from;
      toDate = event.to;
    }
  }

  @override
  void dispose() {
    controllerNotes.dispose();
    super.dispose();
  }

  Widget buildNote() => TextFormField(
    controller: controllerNotes,
    style: const TextStyle(fontSize: 24),
    decoration: const InputDecoration(
      border: UnderlineInputBorder(),
      hintText: "Additional notes"
    ),
  );

  Widget buildDateTimePickers() => Column(
    children: [
      buildFrom(),
      buildTo()
    ],
  );

  Widget buildFrom() => buildHeader(
    header: "FROM",
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: buildDropdownField(
            text: Utils.toDate(fromDate),
            onClicked: () => pickFromDateTime(pickDate: true)
          )
        ),
        Expanded(
          child: buildDropdownField(
            text: Utils.toTime(fromDate),
            onClicked: () => pickFromDateTime(pickDate: false)
          )
        )
      ]
    )
  );

  Widget buildTo() => buildHeader(
    header: "TO",
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: buildDropdownField(
            text: Utils.toDate(toDate),
            onClicked: () => pickToDateTime(pickDate: true)
          )
        ),
        Expanded(
          child: buildDropdownField(
            text: Utils.toTime(toDate),
            onClicked: () => pickToDateTime(pickDate: false)
          )
        )
      ]
    )
  );

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if (date == null) return;

    if (date.isAfter(toDate)) {
      toDate = DateTime(date.year, date.month, date.day, toDate.hour, toDate.minute);
    }

    setState(() => fromDate = date);
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(toDate, pickDate: pickDate, firstDate: pickDate ? fromDate : null);
    if (date == null) return;

    if (date.isAfter(toDate)) {
      toDate = DateTime(date.year, date.month, date.day, toDate.hour, toDate.minute);
    }

    setState(() => toDate = date);
  }

  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
      required bool pickDate,
      DateTime? firstDate
    }) async {
    if (pickDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(DateTime.now().year, DateTime.now().month),
        lastDate: DateTime(2101)
      );

      if (date == null) return null;

      final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);

      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate)
      );

      if (timeOfDay == null) return null;

      final date = DateTime(initialDate.year, initialDate.month, initialDate.day);

      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);

      return date.add(time);
    }
  }

  Widget buildDropdownField({
    required String text,
    required VoidCallback onClicked
  }) => ListTile(
    title: Text(text),
    trailing: const Icon(Icons.arrow_drop_down),
    onTap: onClicked,
  );

  Widget buildHeader({
    required String header,
    required Widget child
  }) => Column (
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(header, style: const TextStyle(fontWeight: FontWeight.bold)),
      child
    ],
  );

  Future saveForm() async {
    final event = EventClass(
      from: fromDate,
      to: toDate,
      notes: controllerNotes.text,
      subject: dropdownitem,
      staff: "To Be Confirm",
      status: 0
    );

    _create(event);
  }

  final user = FirebaseAuth.instance.currentUser!;

  _create(EventClass event) {
    try {
      if (event.from.isBefore(DateTime.now().add(const Duration(days:1)))) {
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "Start time must be at least 24 hrs from now.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 30
        );
      }
      else if (event.to.isAtSameMomentAs(event.from)) {
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "Please select a range.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 30
        );
      }
      else if (event.to.isBefore(event.from)) {
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "Please select valid range.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 30
        );
      }
      else if (event.to.difference(event.from) < const Duration(hours:1)) {
        Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "The range must be at least 1 hr.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 30
        );
      }
      else {
        FirebaseFirestore.instance.collection('TrackApp/${user.email!}/Appointment').doc("Appointment_${event.to}_${event.subject}").get().then((doc) => {
          if (!doc.exists) {
            FirebaseFirestore.instance.collection("TrackApp/${user.email}/Appointment").doc("Appointment_${event.from}_${event.subject}").set(
                {
                  "ToDate" : event.to,
                  "FromDate" : event.from,
                  "Notes" : event.notes,
                  "Subject" : event.subject,
                  "Staff" : "To Be Confirm",
                  "Status" : 0
                },
                SetOptions(merge : true)),

            Fluttertoast.showToast(
              toastLength: Toast.LENGTH_LONG,
              msg: "Request successfully",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 30
            )
          }
        });
        _toAppointment(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toAppointment(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Appointment", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        centerTitle: true,
        leading: const CloseButton()
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text("Please select a subject", style: TextStyle(fontSize: 20)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DropdownButton(
                value: dropdownitem,
                icon: const Icon(Icons.keyboard_arrow_down),
                items:items.map((String items) {
                  return DropdownMenuItem(
                      value: items,
                      child: Text(items, style: const TextStyle(fontSize: 28))
                  );
                }
                ).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownitem = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text("Please indicate your", style: TextStyle(fontSize: 20)),
            const Text("available period", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            buildDateTimePickers(),
            const SizedBox(height: 30),
            buildNote(),
            Container(
              margin: const EdgeInsets.all(25),
              child: RaisedButton(
                child: const Text("Confirm", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                color: Colors.redAccent,
                onPressed: () {
                  saveForm();
                },
              ),
            ),
          ]
        )
      ),
    )
  );
}

void _toMain(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Main()), (Route<dynamic> route) => false);
}
void _toRegister(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Register()), (Route<dynamic> route) => false);
}
void _toRegisterOTP(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => RegisterOTP()), (Route<dynamic> route) => false);
}
void _toLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
}
void _toForgetPW(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ForgetPW()), (Route<dynamic> route) => false);
}
void _toHealth(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Health()), (Route<dynamic> route) => false);
}
void _toHealthUpdate(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HealthUpdate()), (Route<dynamic> route) => false);
}
void _toDiet(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Diet()), (Route<dynamic> route) => false);
}
void _toDietUpdate(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => DietUpdate()), (Route<dynamic> route) => false);
}
void _toFinance(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Finance()), (Route<dynamic> route) => false);
}
void _toFinanceUpdate(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => FinanceUpdate()), (Route<dynamic> route) => false);
}
void _toSocial(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Social()), (Route<dynamic> route) => false);
}
void _toSocialUpdate(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SocialUpdate()), (Route<dynamic> route) => false);
}
void _toGoal(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Goal()), (Route<dynamic> route) => false);
}
void _toReward(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Reward()), (Route<dynamic> route) => false);
}
void _toAppointment(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Appointment()), (Route<dynamic> route) => false);
}
void _toAppointmentUpdate(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AppointmentUpdate()), (Route<dynamic> route) => false);
}