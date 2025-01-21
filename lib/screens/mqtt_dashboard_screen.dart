import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MqttDashboardScreen extends StatelessWidget {
  final List<ChartData> dataPoints;
  final String broker;
  final String topic;

  MqttDashboardScreen({
    required this.dataPoints,
    required this.broker,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Dashboard'),
      ),
      body: Column(
        children: [
          // Gráfico
          Expanded(
            flex: 3,
            child: SfCartesianChart(
              primaryXAxis: NumericAxis(),
              primaryYAxis: NumericAxis(),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries>[
                LineSeries<ChartData, double>(
                  dataSource: dataPoints,
                  xValueMapper: (ChartData point, _) => point.x,
                  yValueMapper: (ChartData point, _) => point.y,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                  enableTooltip: true,
                ),
              ],
            ),
          ),
          // Información del broker y topic
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Broker: $broker', style: TextStyle(fontSize: 16)),
                Text('Topic: $topic', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          // Botones para navegar
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  child: Text('Go to Settings'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/history');
                  },
                  child: Text('View Data History'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final double x;
  final double y;

  ChartData(this.x, this.y);
}
