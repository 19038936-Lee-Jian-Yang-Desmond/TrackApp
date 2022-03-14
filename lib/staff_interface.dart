import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:login/widget/bar%20chart.dart';
import 'main.dart';
import 'model/model.dart';

class MainforAdmin extends StatelessWidget {
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

  final user = FirebaseAuth.instance.currentUser!;

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
                    child: const Text("DEMOGRAPHIC", style: TextStyle(fontSize: 22.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      _toDemographic(context);
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(0),
                  child: RaisedButton(
                    child: const Text("GOALS", style: TextStyle(fontSize: 22.0, color: Colors.white)),
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                    onPressed: () {
                      _toGoalsChecking(context);
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
                      _toAppointmentApproval(context);
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

class Demographic extends StatefulWidget {
  @override
  _demographic createState() => _demographic();
}

class _demographic extends State<Demographic> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    readAge(age);
    readRace(race);
    readGender(gender);
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  isyellow(Color color) {
    bool isyellow = false;
    if (color == Colors.yellow) {
      isyellow = true;
    }
    return isyellow;
  }

  List<PieClass> age = [];
  double below39 = 0, frm40to49 = 0, frm50to59 = 0, frm60to69 = 0, above70 = 0;

  List<PieClass> race = [];
  double chinese = 0, eurasian = 0, indian = 0, malay = 0, others = 0;

  List<PieClass> gender = [];
  double male = 0, female = 0;

  readAge(List<PieClass> age) {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        int current = DateTime.now().year;
        int born = (result.data()["Dob"].toDate()).year;
        int age = current - born;
        if (age < 40) {
          setState(() {
            below39 += 1;
          });
        }
        else if (age < 50) {
          setState(() {
            frm40to49 += 1;
          });
        }
        else if (age < 60) {
          setState(() {
            frm50to59 += 1;
          });
        }
        else if (age < 70) {
          setState(() {
            frm60to69 += 1;
          });
        }
        else {
          setState(() {
            above70 += 1;
          });
        }
      }
      age.add(PieClass(name: "~39", number: below39, color: Colors.red));
      age.add(PieClass(name: "40-49", number: frm40to49, color: Colors.blue));
      age.add(PieClass(name: "50-59", number: frm50to59, color: Colors.green));
      age.add(PieClass(name: "60-69", number: frm60to69, color: Colors.yellow));
      age.add(PieClass(name: "70~", number: above70, color: Colors.orange));
    });
    return age;
  }

  readRace(List<PieClass> race) {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        if (result.data()["Race"] == "Chinese") {
          setState(() {
            chinese += 1;
          });
        }
        if (result.data()["Race"] == "Eurasian") {
          setState(() {
            eurasian += 1;
          });
        }
        if (result.data()["Race"] == "Indian") {
          setState(() {
            indian += 1;
          });
        }
        if (result.data()["Race"] == "Malay") {
          setState(() {
            malay += 1;
          });
        }
        if (result.data()["Race"] == "Others") {
          setState(() {
            others += 1;
          });
        }
      }
      race.add(PieClass(name: "Chinese", number: chinese, color: Colors.red));
      race.add(PieClass(name: "Eurasian", number: eurasian, color: Colors.blue));
      race.add(PieClass(name: "Indian", number: indian, color: Colors.green));
      race.add(PieClass(name: "Malay", number: malay, color: Colors.yellow));
      race.add(PieClass(name: "Others", number: others, color: Colors.orange));
    });
    return race;
  }

  readGender(List<PieClass> gender) {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        if (result.data()["Gender"] == "Male") {
          setState(() {
            male += 1;
          });
        }
        if (result.data()["Gender"] == "Female") {
          setState(() {
            female += 1;
          });
        }
      }
      gender.add(PieClass(name: "Male", number: male, color: Colors.blueAccent));
      gender.add(PieClass(name: "Female", number: female, color: Colors.pinkAccent));
    });
    return gender;
  }

  List<PieChartSectionData> getSection_age(List<PieClass> data, int touchedindex) => data.asMap().map<int, PieChartSectionData>((index, data){
    final isTouched = index == touchedindex;
    final double fontsize = isTouched ? 25 : 16;
    final double radius = isTouched ? 60 : 50;

    final value = PieChartSectionData(
      color: data.color,
      value: data.number,
      title: '${data.number}',
      titleStyle: TextStyle(fontSize: fontsize, color: isyellow(data.color) ? Colors.black : Colors.white),
      radius: radius
    );
    return MapEntry(index, value);
  }).values.toList();

  List<PieChartSectionData> getSection_race(List<PieClass> data, int touchedindex) => data.asMap().map<int, PieChartSectionData>((index, data){
    final isTouched = index == touchedindex;
    final double fontsize = isTouched ? 25 : 16;
    final double radius = isTouched ? 60 : 50;

    final value = PieChartSectionData(
      color: data.color,
      value: data.number,
      title: '${data.number}',
      titleStyle: TextStyle(fontSize: fontsize, color: isyellow(data.color) ? Colors.black : Colors.white),
      radius: radius
    );
    return MapEntry(index, value);
  }).values.toList();

  List<PieChartSectionData> getSection_gender(List<PieClass> data, int touchedindex) => data.asMap().map<int, PieChartSectionData>((index, data){
    final isTouched = index == touchedindex;
    final double fontsize = isTouched ? 25 : 16;
    final double radius = isTouched ? 60 : 50;

    final value = PieChartSectionData(
      color: data.color,
      value: data.number,
      title: '${data.number}',
      titleStyle: TextStyle(fontSize: fontsize, color: isyellow(data.color) ? Colors.black : Colors.white),
      radius: radius
    );
    return MapEntry(index, value);
  }).values.toList();

  IndicatorWidget_age(List<PieClass> data) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: data.map((_data) => Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: buildIndicator(color: _data.color, text: _data.name, isSquare: true)
    )).toList()
  );

  IndicatorWidget_race(List<PieClass> data) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: data.map((_data) => Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: buildIndicator(color: _data.color, text: _data.name, isSquare: true)
    )).toList()
  );

  IndicatorWidget_gender(List<PieClass> data) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: data.map((_data) => Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: buildIndicator(color: _data.color, text: _data.name, isSquare: true)
    )).toList()
  );

  Widget buildIndicator({
    Color color = Colors.black,
    String text = "",
    bool isSquare = false,
    double size = 16,
    Color textColor = Colors.black
  }) => Row(
    children: <Widget>[
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: isSquare? BoxShape.rectangle : BoxShape.circle,
          color: color
        ),
      ),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 24.0))
    ]
  );

  int touchedindex = -1;

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMainforAdmin(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Users' Demographic", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _toMainforAdmin(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Age"),
            Tab(text: "Ethnicity"),
            Tab(text: "Gender")
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Column(children: <Widget>[
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedindex = -1;
                        return;
                      }
                      touchedindex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: getSection_age(age, touchedindex)
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IndicatorWidget_age(age)
                )
              ],
            ),
          ])),
          Center(child: Column(children: <Widget>[
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedindex = -1;
                        return;
                      }
                      touchedindex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: getSection_race(race, touchedindex)
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IndicatorWidget_race(race)
                )
              ],
            ),
          ])),
          Center(child: Column(children: <Widget>[
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedindex = -1;
                        return;
                      }
                      touchedindex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: getSection_gender(gender, touchedindex)
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IndicatorWidget_gender(gender)
                )
              ],
            ),
          ]))
        ]
      )
    )
  );
}

class GoalsChecking extends StatefulWidget {
  @override
  goalsChecking createState() => goalsChecking();
}

class goalsChecking extends State<GoalsChecking> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final double barWidth = 50;

  var emaillist = [], checked = [];
  bool duplicate = false;

  double exercise = 0, diet = 0, finance = 0, social = 0;
  static List<BarClass> goalset = [];
  static int interval = 1;

  readGoals() {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        setState(() {
          emaillist.add(result.data()["Email"]);
        });
      }
      goalset.add(BarClass(name: "Exercise", number: exercise, color: Colors.red, id: 0));
      goalset.add(BarClass(name: "Diet", number: diet, color: Colors.blue, id: 1));
      goalset.add(BarClass(name: "Finance", number: finance, color: Colors.green, id: 2));
      goalset.add(BarClass(name: "Social", number: social, color: Colors.yellow, id: 3));
      for (String i in emaillist) {
        FirebaseFirestore.instance.collection('TrackApp/$i/Goal').where('Type', isEqualTo: "Exercise").get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            if (result.data()["Conf"] != 0) {
              setState(() {
                exercise += 1;
              });
            }
          }
          for (var x in goalset) {
            if (x.name == "Exercise") {
              int index = goalset.indexOf(x);
              goalset[index].number = exercise;
            }
          }
        });
        FirebaseFirestore.instance.collection('TrackApp/$i/Goal').where('Type', isEqualTo: "Diet").get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            if (result.data()["Conf"] != 0) {
              setState(() {
                diet += 1;
              });
            }
          }
          for (var x in goalset) {
            if (x.name == "Diet") {
              int index = goalset.indexOf(x);
              goalset[index].number = diet;
            }
          }
        });
        FirebaseFirestore.instance.collection('TrackApp/$i/Goal').where('Type', isEqualTo: "Finance").get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            if (result.data()["Conf"] != 0) {
              setState(() {
                finance += 1;
              });
            }
          }
          for (var x in goalset) {
            if (x.name == "Finance") {
              int index = goalset.indexOf(x);
              goalset[index].number = finance;
            }
          }
        });
        FirebaseFirestore.instance.collection('TrackApp/$i/Goal').where('Type', isEqualTo: "Social").get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            if (result.data()["Conf"] != 0) {
              setState(() {
                social += 1;
              });
            }
          }
          for (var x in goalset) {
            if (x.name == "Social") {
              int index = goalset.indexOf(x);
              goalset[index].number = social;
            }
          }
        });
      }
      return goalset.toSet().toList();
    });
  }

  @override
  void initState() {
    readGoals();
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      goalset.clear();
      _toMainforAdmin(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Users' Goals", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            goalset.clear();
            _toMainforAdmin(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Goals Set Breakdown"),
            Tab(text: "Goals Achieved Percentage")
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              const Text("Breakdown of Goals Set by Users", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    maxY: emaillist.length.toDouble(),
                    minY: 0,
                    groupsSpace: 50,
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      topTitles: GoalsBarTitles.getTopBottomTitles(),
                      bottomTitles: GoalsBarTitles.getTopBottomTitles(),
                      leftTitles: GoalsBarTitles.getSideTitles(),
                      rightTitles: GoalsBarTitles.getSideTitles()
                    ),
                    gridData: FlGridData(
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.transparent,
                          strokeWidth: 0
                        );
                      },
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.red,
                          strokeWidth: 2
                        );
                      }
                    ),
                    barGroups: goalset.map((data) => BarChartGroupData(
                      x: data.id,
                      barRods: [
                        BarChartRodData(
                          toY: data.number,
                          width: barWidth,
                          colors: [data.color],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6)
                          )
                        )
                      ]
                    )).toList()
                  )
                )
              ),
            ]
          )),
          GoalsPie()
        ]
      )
    )
  );
}

class GoalsPie extends StatefulWidget {
  @override
  _goalsPie createState() => _goalsPie();
}

class _goalsPie extends State<GoalsPie> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    checkExercise(exercise);
    checkDiet(diet);
    checkFinance(finance);
    checkSocial(social);
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PieClass> exercise = [], diet = [], finance = [], social = [];
  double achieved_e = 0, failed_e = 0, achieved_d = 0, failed_d = 0, achieved_f = 0, failed_f = 0, achieved_s = 0, failed_s = 0;
  var emaillist_e = [], emaillist_d = [], emaillist_f = [], emaillist_s = [];

  _date(DateTime now) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  checkExercise(List<PieClass> pc) {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        setState(() {
          emaillist_e.add(result.data()["Email"]);
        });
      }
      exercise.add(PieClass(name: "Achieved", number: achieved_e, color: Colors.blueAccent));
      exercise.add(PieClass(name: "Failed", number: failed_e, color: Colors.red));
      for (String i in emaillist_e) {
        FirebaseFirestore.instance.collection('TrackApp/$i/Exercise').where('Date', isEqualTo: _date(DateTime.now().subtract(const Duration(days:1)))).get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            if (result.data()["Redeem"] == true) {
              setState(() {
                achieved_e += 1;
              });
            }
            else {
              setState(() {
                failed_e += 1;
              });
            }
          }
          if (querySnapshot.docs.isEmpty) {
            setState(() {
              failed_e += 1;
            });
          }
          for (var x in exercise) {
            if (x.name == "Achieved") {
              int index = exercise.indexOf(x);
              exercise[index].number = achieved_e;
            }
            else if (x.name == "Failed") {
              int index = exercise.indexOf(x);
              exercise[index].number = failed_e;
            }
          }
        });
      }
      return exercise.toSet().toList();
    });
  }

  checkDiet(List<PieClass> pc) {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        setState(() {
          emaillist_d.add(result.data()["Email"]);
        });
      }
      diet.add(PieClass(name: "Achieved", number: achieved_d, color: Colors.blueAccent));
      diet.add(PieClass(name: "Failed", number: failed_d, color: Colors.red));
      for (String i in emaillist_d) {
        FirebaseFirestore.instance.collection('TrackApp/$i/Diet').where('Date', isEqualTo: _date(DateTime.now().subtract(const Duration(days:1)))).get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            if (result.data()["Redeem"] == true) {
              setState(() {
                achieved_d += 1;
              });
            }
            else {
              setState(() {
                failed_d += 1;
              });
            }
          }
          if (querySnapshot.docs.isEmpty) {
            setState(() {
              failed_d += 1;
            });
          }
          for (var x in diet) {
            if (x.name == "Achieved") {
              int index = diet.indexOf(x);
              diet[index].number = achieved_d;
            }
            else if (x.name == "Failed") {
              int index = diet.indexOf(x);
              diet[index].number = failed_d;
            }
          }
        });
      }
      return diet.toSet().toList();
    });
  }

  checkFinance(List<PieClass> pc) {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        setState(() {
          emaillist_f.add(result.data()["Email"]);
        });
      }
      finance.add(PieClass(name: "Achieved", number: achieved_f, color: Colors.blueAccent));
      finance.add(PieClass(name: "Failed", number: failed_f, color: Colors.red));
      for (String i in emaillist_f) {
        FirebaseFirestore.instance.collection('TrackApp/$i/Finance').where('Date', isEqualTo: _date(DateTime.now().subtract(const Duration(days:1)))).get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            if (result.data()["Redeem"] == true) {
              setState(() {
                achieved_f += 1;
              });
            }
            else {
              setState(() {
                failed_f += 1;
              });
            }
          }
          if (querySnapshot.docs.isEmpty) {
            setState(() {
              failed_f += 1;
            });
          }
          for (var x in finance) {
            if (x.name == "Achieved") {
              int index = finance.indexOf(x);
              finance[index].number = achieved_f;
            }
            else if (x.name == "Failed") {
              int index = finance.indexOf(x);
              finance[index].number = failed_f;
            }
          }
        });
      }
      return finance.toSet().toList();
    });
  }

  checkSocial(List<PieClass> pc) {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        setState(() {
          emaillist_s.add(result.data()["Email"]);
        });
      }
      social.add(PieClass(name: "Achieved", number: achieved_s, color: Colors.blueAccent));
      social.add(PieClass(name: "Failed", number: failed_s, color: Colors.red));
      for (String i in emaillist_s) {
        FirebaseFirestore.instance.collection('TrackApp/$i/Social').where('Date', isEqualTo: _date(DateTime.now().subtract(const Duration(days:1)))).get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            if (result.data()["Redeem"] == true) {
              setState(() {
                achieved_s += 1;
              });
            }
            else {
              setState(() {
                failed_s += 1;
              });
            }
          }
          if (querySnapshot.docs.isEmpty) {
            setState(() {
              failed_s += 1;
            });
          }
          for (var x in social) {
            if (x.name == "Achieved") {
              int index = social.indexOf(x);
              social[index].number = achieved_s;
            }
            else if (x.name == "Failed") {
              int index = social.indexOf(x);
              social[index].number = failed_s;
            }
          }
        });
      }
      return social.toSet().toList();
    });
  }

  List<PieChartSectionData> getSection_e(List<PieClass> data, int touchedindex) => data.asMap().map<int, PieChartSectionData>((index, data){
    final isTouched = index == touchedindex;
    final double fontsize = isTouched ? 25 : 16;
    final double radius = isTouched ? 60 : 50;

    final value = PieChartSectionData(
      color: data.color,
      value: data.number,
      title: '${data.number}',
      titleStyle: TextStyle(fontSize: fontsize, color: Colors.white),
      radius: radius
    );
    return MapEntry(index, value);
  }).values.toList();

  List<PieChartSectionData> getSection_d(List<PieClass> data, int touchedindex) => data.asMap().map<int, PieChartSectionData>((index, data){
    final isTouched = index == touchedindex;
    final double fontsize = isTouched ? 25 : 16;
    final double radius = isTouched ? 60 : 50;

    final value = PieChartSectionData(
      color: data.color,
      value: data.number,
      title: '${data.number}',
      titleStyle: TextStyle(fontSize: fontsize, color: Colors.white),
      radius: radius
    );
    return MapEntry(index, value);
  }).values.toList();

  List<PieChartSectionData> getSection_f(List<PieClass> data, int touchedindex) => data.asMap().map<int, PieChartSectionData>((index, data){
    final isTouched = index == touchedindex;
    final double fontsize = isTouched ? 25 : 16;
    final double radius = isTouched ? 60 : 50;

    final value = PieChartSectionData(
      color: data.color,
      value: data.number,
      title: '${data.number}',
      titleStyle: TextStyle(fontSize: fontsize, color: Colors.white),
      radius: radius
    );
    return MapEntry(index, value);
  }).values.toList();

  List<PieChartSectionData> getSection_s(List<PieClass> data, int touchedindex) => data.asMap().map<int, PieChartSectionData>((index, data){
    final isTouched = index == touchedindex;
    final double fontsize = isTouched ? 25 : 16;
    final double radius = isTouched ? 60 : 50;

    final value = PieChartSectionData(
        color: data.color,
        value: data.number,
        title: '${data.number}',
        titleStyle: TextStyle(fontSize: fontsize, color: Colors.white),
        radius: radius
    );
    return MapEntry(index, value);
  }).values.toList();

  IndicatorWidget_e(List<PieClass> data) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((_data) => Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: buildIndicator(color: _data.color, text: _data.name, isSquare: true)
      )).toList()
  );

  IndicatorWidget_d(List<PieClass> data) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((_data) => Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: buildIndicator(color: _data.color, text: _data.name, isSquare: true)
      )).toList()
  );

  IndicatorWidget_f(List<PieClass> data) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((_data) => Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: buildIndicator(color: _data.color, text: _data.name, isSquare: true)
      )).toList()
  );

  IndicatorWidget_s(List<PieClass> data) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((_data) => Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: buildIndicator(color: _data.color, text: _data.name, isSquare: true)
      )).toList()
  );

  Widget buildIndicator({
    Color color = Colors.black,
    String text = "",
    bool isSquare = false,
    double size = 16,
    Color textColor = Colors.black
  }) => Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: isSquare? BoxShape.rectangle : BoxShape.circle,
              color: color
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 24.0))
      ]
  );

  int touchedindex = -1;

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMainforAdmin(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        toolbarHeight: 2,
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
          Center(child: Column(children: <Widget>[
            const SizedBox(height: 30),
            const Text("Based On Data From Yesterday", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedindex = -1;
                        return;
                      }
                      touchedindex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: getSection_e(exercise, touchedindex)
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: IndicatorWidget_e(exercise)
                )
              ],
            ),
          ])),
          Center(child: Column(children: <Widget>[
            const SizedBox(height: 30),
            const Text("Based On Data From Yesterday", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedindex = -1;
                        return;
                      }
                      touchedindex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: getSection_d(diet, touchedindex)
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IndicatorWidget_d(diet)
                )
              ],
            ),
          ])),
          Center(child: Column(children: <Widget>[
            const SizedBox(height: 30),
            const Text("Based On Data From Yesterday", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedindex = -1;
                        return;
                      }
                      touchedindex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: getSection_f(finance, touchedindex)
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IndicatorWidget_f(finance)
                )
              ],
            ),
          ])),
          Center(child: Column(children: <Widget>[
            const SizedBox(height: 30),
            const Text("Based On Data From Yesterday", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedindex = -1;
                        return;
                      }
                      touchedindex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: getSection_s(social, touchedindex)
                )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IndicatorWidget_s(social)
                )
              ],
            ),
          ]))
        ]
      )
    )
  );
}

class AppointmentApproval extends StatefulWidget{
  @override
  _appointmentApproval createState()=> _appointmentApproval();
}

class _appointmentApproval extends State<AppointmentApproval> {
  final user = FirebaseAuth.instance.currentUser!;

  _date() {
    final DateTime now = DateTime.now().subtract(const Duration(days:1));
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  var emaillist = [];
  List<ApptClass> apptlist = [];
  bool duplicate = false;

  readAppt() {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        setState(() {
          emaillist.add(result.data()["Email"]);
        });
      }
      for (String i in emaillist) {
        FirebaseFirestore.instance.collection('TrackApp').where("Email", isGreaterThanOrEqualTo: i).get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            String name = result.data()["Name"];
            FirebaseFirestore.instance.collection('TrackApp/$i/Appointment').where("FromDate", isGreaterThanOrEqualTo: _date()).get().then((querySnapshot) {
              for (var result in querySnapshot.docs) {
                var ac = ApptClass(
                    name: name,
                    email: i,
                    from: (result.data()["FromDate"] as Timestamp).toDate(),
                    to: (result.data()["ToDate"] as Timestamp).toDate(),
                    subject: result.data()["Subject"],
                    notes: result.data()["Notes"],
                    status: result.data()["Status"],
                    staff: result.data()["Staff"]
                );

                for (ApptClass a in apptlist) {
                  if (a.email == ac.email) {
                    if (a.from == ac.from) {
                      if (a.subject == ac.subject) {
                        setState(() {
                          duplicate = true;
                        });
                      }
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
          }
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

  _approve(ApptClass appt) {
    try {
      final docUser = FirebaseFirestore.instance
          .collection("TrackApp/${appt.email}/Appointment")
          .doc("Appointment_${appt.from}_${appt.subject}");
      docUser.update({'Status': 1});
      docUser.update({'Staff': user.email});
      _toAppointmentApproval(context);
    } catch(e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  _decline(ApptClass appt) {
    try {
      final docUser = FirebaseFirestore.instance
          .collection("TrackApp/${appt.email}/Appointment")
          .doc("Appointment_${appt.from}_${appt.subject}");
      docUser.update({'Status': 2});
      docUser.update({'Staff': user.email});
      _toAppointmentApproval(context);
    } catch(e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  _success(ApptClass appt) {
    try {
      final docUser = FirebaseFirestore.instance
          .collection("TrackApp/${appt.email}/Appointment")
          .doc("Appointment_${appt.from}_${appt.subject}");
      docUser.update({'Status': 3});
      _toAppointmentApproval(context);
    } catch(e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
    }
  }

  _fail(ApptClass appt) {
    try {
      final docUser = FirebaseFirestore.instance
          .collection("TrackApp/${appt.email}/Appointment")
          .doc("Appointment_${appt.from}_${appt.subject}");
      docUser.update({'Status': 4});
      _toAppointmentApproval(context);
    } catch(e) {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30
      );
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

  isyellow(Color color) {
    bool isyellow = false;
    if (color == Colors.yellow) {
      isyellow = true;
    }
    return isyellow;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      readAppt();
    });
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _toMainforAdmin(context);
      apptlist.clear();
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
            _toMainforAdmin(context);
            apptlist.clear();
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
                      const SizedBox(height: 10),
                      TextFormField(
                        readOnly: true,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          floatingLabelBehavior:FloatingLabelBehavior.always,
                          labelText: 'Requester',
                          hintText: data.name,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
                      Expanded(child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(5),
                            width: 60,
                            child: RaisedButton(
                              child: const Text("A", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                              color: Colors.redAccent,
                              onPressed: () {
                                setState(() {
                                  _approve(data);
                                });
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5),
                            width: 60,
                            child: RaisedButton(
                              child: const Text("D", style: TextStyle(fontSize: 28.0, color: Colors.redAccent),),
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  _decline(data);
                                });
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5),
                            width: 60,
                            child: RaisedButton(
                              child: const Text("S", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                              color: Colors.redAccent,
                              onPressed: () {
                                setState(() {
                                  _success(data);
                                });
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5),
                            width: 60,
                            child: RaisedButton(
                              child: const Text("F", style: TextStyle(fontSize: 28.0, color: Colors.redAccent),),
                              color: Colors.white,
                              onPressed: () {
                                setState(() {
                                  _fail(data);
                                });
                              },
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: RaisedButton(
                        child: const Text("Back", style: TextStyle(fontSize: 28.0, color: Colors.white),),
                        color: Colors.redAccent,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                )
                ),
              )
          ]))
        ]
      )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.notes, color: Colors.white),
        backgroundColor: Colors.redAccent,
        onPressed: () {
          _toAppointmentReport(context);
        },
      ),
    )
  );
}

class AppointmentReport extends StatefulWidget {
  @override
  appointmentReport createState() => appointmentReport();
}

class appointmentReport extends State<AppointmentReport> {
  final double barWidth = 40;

  var emaillist = [], checked = [];
  bool duplicate = false;

  double total = 0, pending = 0, approved = 0, declined = 0, success = 0, failed = 0;
  static List<BarClass> rpt = [];
  static int interval = 5;

  _date(DateTime now) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    final DateTime dt = DateTime.parse(formatted);
    return(dt);
  }

  readRpt() {
    FirebaseFirestore.instance.collection('TrackApp').where('Is_whc_user', isEqualTo: false).get().then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        setState(() {
          emaillist.add(result.data()["Email"]);
        });
      }
      rpt.add(BarClass(name: "Total", number: total, color: Colors.deepPurple, id: 0));
      rpt.add(BarClass(name: "Pending", number: pending, color: Colors.black, id: 1));
      rpt.add(BarClass(name: "Approved", number: approved, color: Colors.blueAccent, id: 2));
      rpt.add(BarClass(name: "Declined", number: declined, color: Colors.red, id: 3));
      rpt.add(BarClass(name: "Success", number: success, color: Colors.green, id: 4));
      rpt.add(BarClass(name: "Failed", number: failed, color: Colors.orangeAccent, id: 5));
      for (String i in emaillist) {
        FirebaseFirestore.instance.collection('TrackApp/$i/Appointment').where('FromDate', isGreaterThanOrEqualTo: _date(DateTime.now().subtract(const Duration(days:30)))).get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            setState(() {
              total += 1;
            });
            if (result.data()["Status"] == 0) {
              setState(() {
                pending += 1;
              });
            }
            else if (result.data()["Status"] == 1) {
              setState(() {
                approved += 1;
              });
            }
            else if (result.data()["Status"] == 2) {
              setState(() {
                declined += 1;
              });
            }
            else if (result.data()["Status"] == 3) {
              setState(() {
                success += 1;
              });
            }
            else if (result.data()["Status"] == 4) {
              setState(() {
                failed += 1;
              });
            }
          }
          for (var x in rpt) {
            if (x.name == "Total") {
              int index = rpt.indexOf(x);
              rpt[index].number = total;
            }
            else if (x.name == "Pending") {
              int index = rpt.indexOf(x);
              rpt[index].number = pending;
            }
            else if (x.name == "Approved") {
              int index = rpt.indexOf(x);
              rpt[index].number = approved;
            }
            else if (x.name == "Declined") {
              int index = rpt.indexOf(x);
              rpt[index].number = declined;
            }
            else if (x.name == "Success") {
              int index = rpt.indexOf(x);
              rpt[index].number = success;
            }
            else if (x.name == "Failed") {
              int index = rpt.indexOf(x);
              rpt[index].number = failed;
            }
          }
        });
      }
      return rpt.toSet().toList();
    });
  }

  @override
  void initState() {
    readRpt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      rpt.clear();
      _toAppointmentApproval(context);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Appointment", style: TextStyle(fontSize: 30.0, color: Colors.white)),
        centerTitle: true,
        leading: const CloseButton()
      ),
      body: Center(child: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          const Text("Appointment Status for Past 30 Days", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: total,
                minY: 0,
                groupsSpace: 20,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: ApptBarTitles.getTopBottomTitles(),
                  bottomTitles: ApptBarTitles.getTopBottomTitles(),
                  leftTitles: ApptBarTitles.getSideTitles(),
                  rightTitles: ApptBarTitles.getSideTitles()
                ),
                gridData: FlGridData(
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                        color: Colors.transparent,
                        strokeWidth: 0
                    );
                  },
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                        color: Colors.red,
                        strokeWidth: 2
                    );
                  }
                ),
                barGroups: rpt.map((data) => BarChartGroupData(
                  x: data.id,
                  barRods: [
                    BarChartRodData(
                      toY: data.number,
                      width: barWidth,
                      colors: [data.color],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6)
                      )
                    )
                  ]
                )).toList()
              )
            )
          ),
        ]
      )),
    )
  );
}

void _toMainforAdmin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainforAdmin()), (Route<dynamic> route) => false);
}
void _toLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
}
void _toDemographic(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Demographic()), (Route<dynamic> route) => false);
}
void _toGoalsChecking(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => GoalsChecking()), (Route<dynamic> route) => false);
}
void _toAppointmentApproval(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AppointmentApproval()), (Route<dynamic> route) => false);
}
void _toAppointmentReport(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AppointmentReport()), (Route<dynamic> route) => false);
}