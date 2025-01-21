import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final Function(String) onBrokerChange;
  final Function(String) onTopicChange;

  SettingsScreen({required this.onBrokerChange, required this.onTopicChange});

  @override
  Widget build(BuildContext context) {
    final TextEditingController brokerController = TextEditingController();
    final TextEditingController topicController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuraciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración del Broker MQTT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: brokerController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Dirección del Broker',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Configuración del Tema MQTT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tema',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Llama a las funciones de cambio con los valores ingresados
                onBrokerChange(brokerController.text);
                onTopicChange(topicController.text);
                // Regresar a la pantalla anterior
                Navigator.pop(context);
              },
              child: Text('Guardar Configuración'),
            ),
          ],
        ),
      ),
    );
  }
}
