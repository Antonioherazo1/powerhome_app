import 'package:flutter/material.dart';
import 'package:power_house/screens/mqtt_dashboard_screen.dart';
import 'package:power_house/screens/settings_screen.dart';
import 'package:power_house/screens/data_history_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => MqttDashboardScreen(
              dataPoints: [], // Proporciona una lista vacía inicial para los puntos de datos
              broker: 'broker.hivemq.com', // Valor inicial del broker MQTT
              topic: 'test/topic', // Tema MQTT predeterminado
            ),
        '/settings': (context) => SettingsScreen(
              onBrokerChange: (broker) => print('Broker cambiado: $broker'),
              onTopicChange: (topic) => print('Tema cambiado: $topic'),
            ),
        '/history': (context) => DataHistoryScreen(
              dataHistory: [], // Proporciona una lista vacía inicial para el historial de datos
            ),
      },
    );
  }
}
