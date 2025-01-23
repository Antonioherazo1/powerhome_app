import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power House App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

// Pantalla principal
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Variables iniciales
  String broker = 'test.mosquitto.org'; // Dirección del broker MQTT
  String topic = 'power/house/data'; // Tema MQTT
  List<Map<String, dynamic>> dataPoints = [
    {'time': '10:00', 'value': 20},
    {'time': '10:05', 'value': 25},
    {'time': '10:10', 'value': 30},
  ]; // Datos simulados para la gráfica

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Configuración de pantallas
    _screens = [
      MqttDashboardScreen(
        broker: broker,
        topic: topic,
        dataPoints: dataPoints,
      ),
      DataHistoryScreen(dataHistory: dataPoints),
      SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Pantalla de Dashboard
class MqttDashboardScreen extends StatelessWidget {
  final String broker;
  final String topic;
  final List<Map<String, dynamic>> dataPoints;

  MqttDashboardScreen({
    required this.broker,
    required this.topic,
    required this.dataPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Dashboard'),
      ),
      body: SfCartesianChart(
        title: ChartTitle(text: 'Data Visualization'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries>[
          LineSeries<Map<String, dynamic>, String>(
            dataSource: dataPoints,
            xValueMapper: (data, _) => data['time'] as String,
            yValueMapper: (data, _) => data['value'] as int,
            name: 'Sensor Data',
          ),
        ],
      ),
    );
  }
}

// Pantalla de Historial de Datos
class DataHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dataHistory;

  DataHistoryScreen({required this.dataHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data History'),
      ),
      body: ListView.builder(
        itemCount: dataHistory.length,
        itemBuilder: (context, index) {
          final entry = dataHistory[index];
          return ListTile(
            title: Text('Time: ${entry['time']}'),
            subtitle: Text('Value: ${entry['value']}'),
          );
        },
      ),
    );
  }
}

// Pantalla de Configuración
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}
