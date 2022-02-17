import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserClass {
  final DateTime dob;
  final String name;
  final String email;
  final String gender;
  final String race;
  final int coin;
  final bool is_whc_user;

  UserClass({
    required this.dob,
    required this.name,
    required this.email,
    required this.gender,
    required this.race,
    required this.coin,
    this.is_whc_user = false,
  });

  Map<String, dynamic> toJson() => {
    'Dob': dob,
    'Name': name,
    'Email': email,
    'Gender': gender,
    'Race': race,
    'Coins': coin,
    'Is_whc_user': is_whc_user
  };

  static UserClass fromJson(Map<String, dynamic> json) => UserClass(
      dob: (json['Dob'] as Timestamp).toDate(),
      name: json['Name'],
      email: json['Email'],
      gender: json['Gender'],
      coin: json['Coins'],
      race: json['Race']
  );
}

class ExerciseClass {
  final DateTime date;
  final int duration;
  final int goal;
  final bool redeem;

  ExerciseClass({
    required this.date,
    required this.duration,
    required this.goal,
    required this.redeem
  });

  Map<String, dynamic> toJson() => {
    'Date': date,
    'Duration': duration,
    'Goal': goal,
    'Redeem': redeem
  };

  static ExerciseClass fromJson(Map<String, dynamic> json) => ExerciseClass(
      date: (json['Date'] as Timestamp).toDate(),
      duration: json['Duration'],
      goal: json['Goal'],
      redeem: json['Redeem']
  );
}

class DietClass {
  final DateTime date;
  final bool breakfast;
  final bool lunch;
  final bool teatime;
  final bool dinner;
  final bool supper;
  final int goal;
  final bool redeem;

  DietClass({
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.teatime,
    required this.dinner,
    required this.supper,
    required this.goal,
    required this.redeem
  });

  Map<String, dynamic> toJson() => {
    'Date': date,
    "Breakfast" : breakfast,
    "Lunch" : lunch,
    "Teatime" : teatime,
    "Dinner" : dinner,
    "Supper" : supper,
    'Goal': goal,
    "Redeem": redeem
  };

  static DietClass fromJson(Map<String, dynamic> json) => DietClass(
      date: (json['Date'] as Timestamp).toDate(),
      breakfast: json["Breakfast"],
      lunch: json["Lunch"],
      teatime: json["Teatime"],
      dinner: json["Dinner"],
      supper: json["Supper"],
      goal: json['Goal'],
      redeem: json["Redeem"]
  );
}

class FinanceClass {
  final DateTime date;
  final double amt;
  final double goal;
  final bool redeem;

  FinanceClass({
    required this.date,
    required this.amt,
    required this.goal,
    required this.redeem
  });

  Map<String, dynamic> toJson() => {
    'Date': date,
    'Amt': amt,
    'Goal': goal,
    'Redeem': redeem
  };

  static FinanceClass fromJson(Map<String, dynamic> json) => FinanceClass(
      date: (json['Date'] as Timestamp).toDate(),
      amt: json['Amt'].toDouble(),
      goal: json['Goal'].toDouble(),
      redeem: json['Redeem']
  );
}

class SocialClass {
  final DateTime date;
  final int duration;
  final int goal;
  final bool redeem;

  SocialClass({
    required this.date,
    required this.duration,
    required this.goal,
    required this.redeem
  });

  Map<String, dynamic> toJson() => {
    'Date': date,
    'Duration': duration,
    'Goal': goal,
    'Redeem': redeem
  };

  static SocialClass fromJson(Map<String, dynamic> json) => SocialClass(
      date: (json['Date'] as Timestamp).toDate(),
      duration: json['Duration'],
      goal: json['Goal'],
      redeem: json['Redeem']
  );
}

class GoalClass {
  final int conf;
  final int goal;

  GoalClass({
    required this.conf,
    required this.goal
  });

  Map<String, dynamic> toJson() => {
    'Conf': conf,
    'Goal': goal
  };

  static GoalClass fromJson(Map<String, dynamic> json) => GoalClass(
      conf: json['Conf'],
      goal: json['Goal']
  );
}

class FinGoalClass {
  final int conf;
  final double goal;

  FinGoalClass({
    required this.conf,
    required this.goal
  });

  Map<String, dynamic> toJson() => {
    'Conf': conf,
    'Goal': goal
  };

  static FinGoalClass fromJson(Map<String, dynamic> json) => FinGoalClass(
      conf: json['Conf'],
      goal: json['Goal'].toDouble()
  );
}

class RewardClass {
  String name;
  int price;
  int quantity;

  RewardClass({
    required this.name,
    required this.price,
    required this.quantity
  });

  Map<String, dynamic> toJson() => {
    'Name': name,
    'Quantity': quantity,
    'Date': DateTime.now()
  };
}

class EventClass {
  final DateTime from;
  final DateTime to;
  final String subject;
  final String notes;
  final String staff;
  final int status;

  EventClass({
    required this.from,
    required this.to,
    required this.subject,
    required this.notes,
    required this.staff,
    required this.status
  });

  static EventClass fromJson(Map<String, dynamic> json) => EventClass(
      from: (json['FromDate'] as Timestamp).toDate(),
      to: (json['ToDate'] as Timestamp).toDate(),
      subject: json['Subject'],
      notes: json['Notes'],
      staff: json['Staff'],
      status: json['Status']
  );
}

class PieClass {
  String name;
  double number;
  Color color;

  PieClass({
    required this.name,
    required this.number,
    required this.color
  });
}

class BarClass {
  int id;
  String name;
  double number;
  Color color;

  BarClass({
    required this.id,
    required this.name,
    required this.number,
    required this.color
  });
}

class ApptClass {
  final String name;
  final String email;
  final DateTime from;
  final DateTime to;
  final String subject;
  final String notes;
  final String staff;
  final int status;

  ApptClass({
    required this.name,
    required this.email,
    required this.from,
    required this.to,
    required this.subject,
    required this.notes,
    required this.staff,
    required this.status
  });
}