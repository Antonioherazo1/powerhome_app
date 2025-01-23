import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MqttDashboardScreen extends StatefulWidget {
  final String broker;
  final String topic;
  final List<String> dataPoints;

  const MqttDashboardScreen({
    Key? key,
    required this.broker,
    required this.topic,
    required this.dataPoints,
  }) : super(key: key);

  @override
  _MqttDashboardScreenState createState() => _MqttDashboardScreenState();
}

class _MqttDashboardScreenState extends State<MqttDashboardScreen> {
  late List<ChartData> chartData;

  @override
  void initState() {
    super.initState();
    // Convertimos los puntos de datos en una lista de objetos ChartData
    chartData = widget.dataPoints
        .map((point) {
          final splitData = point.split(',');
          if (splitData.length == 2) {
            return ChartData(
              x: double.tryParse(splitData[0]) ?? 0.0,
              y: double.tryParse(splitData[1]) ?? 0.0,
            );
          }
          return null;
        })
        .where((data) => data != null)
        .cast<ChartData>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          title: ChartTitle(text: 'MQTT Data Chart'),
          legend: Legend(isVisible: true),
          primaryXAxis: NumericAxis(title: AxisTitle(text: 'X-Axis')),
          primaryYAxis: NumericAxis(title: AxisTitle(text: 'Y-Axis')),
          // Aquí corregimos el tipo de series a CartesianSeries
          series: <CartesianSeries>[
            LineSeries<ChartData, double>(
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              name: 'Data Series',
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }
}

// Clase para almacenar los datos del gráfico
class ChartData {
  final double x;
  final double y;

  ChartData({required this.x, required this.y});
}
