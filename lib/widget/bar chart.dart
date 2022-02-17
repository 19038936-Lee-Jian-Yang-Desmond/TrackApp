import 'package:fl_chart/fl_chart.dart';
import 'package:login/staff_interface.dart';

class GoalsBarTitles {
  static SideTitles getTopBottomTitles() => SideTitles(
    showTitles: true,
    margin: 10,
    reservedSize: 20,
    getTitles: (double id) => goalsChecking.goalset.firstWhere((element) => element.id == id.toInt()).name
  );

  static SideTitles getSideTitles() => SideTitles(
    showTitles: true,
    interval: goalsChecking.interval.toDouble(),
    margin: 10,
    reservedSize: 20,
    getTitles: (double value) => "${value.toInt()}"
  );
}

class ApptBarTitles {
  static SideTitles getTopBottomTitles() => SideTitles(
      showTitles: true,
      margin: 10,
      reservedSize: 20,
      getTitles: (double id) => appointmentReport.rpt.firstWhere((element) => element.id == id.toInt()).name
  );

  static SideTitles getSideTitles() => SideTitles(
      showTitles: true,
      interval: appointmentReport.interval.toDouble(),
      margin: 10,
      reservedSize: 20,
      getTitles: (double value) => "${value.toInt()}"
  );
}