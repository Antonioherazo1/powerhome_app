// Importa las librerías necesarias
import 'package:flutter/material.dart'; // Para construir interfaces gráficas.
import 'package:mqtt_client/mqtt_client.dart'; // Para conectarse a un servidor MQTT.
import 'package:mqtt_client/mqtt_server_client.dart'; // Cliente específico para servidores MQTT.
import 'package:fl_chart/fl_chart.dart'; // Para crear gráficos en la interfaz.

// Punto de entrada principal de la aplicación.
void main() {
  runApp(
      MyApp()); // Llama a la clase principal de la app para iniciar la ejecución.
}

// Define la clase principal de la aplicación.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor de Energía', // Título de la aplicación.
      theme: ThemeData(primarySwatch: Colors.blue), // Tema principal.
      home: EnergyMonitor(), // Página principal de la aplicación.
    );
  }
}

// Widget principal que muestra el monitor de energía.
class EnergyMonitor extends StatefulWidget {
  @override
  _EnergyMonitorState createState() => _EnergyMonitorState();
}

// Estado asociado al widget principal.
class _EnergyMonitorState extends State<EnergyMonitor> {
  late MqttServerClient client; // Cliente para conectarse al servidor MQTT.
  String status = 'Desconectado'; // Estado de conexión inicial.
  String consumo = '0 W'; // Valor inicial del consumo de energía.
  List<FlSpot> dataPoints = []; // Lista de puntos para la gráfica.
  double xValue = 0; // Representa el tiempo en la gráfica.

  // Método que se ejecuta al iniciar el widget.
  @override
  void initState() {
    super.initState();
    connectToBroker(); // Conectar al servidor MQTT al iniciar.
  }

  // Conexión al servidor MQTT.
  Future<void> connectToBroker() async {
    client = MqttServerClient(
        'thinc.site', 'flutter_client'); // Dirección y nombre del cliente.
    client.port = 1883; // Puerto del servidor MQTT.
    client.logging(on: true); // Habilitar logs para depuración.
    client.keepAlivePeriod = 20; // Mantener viva la conexión cada 20 segundos.

    // Configurar las funciones que se ejecutarán en eventos del cliente.
    client.onDisconnected = onDisconnected; // Al desconectarse.
    client.onConnected = onConnected; // Al conectarse.
    client.onSubscribed = onSubscribed; // Al suscribirse a un tema.

    // Mensaje de conexión inicial al servidor MQTT.
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(
            'flutter_client') // Identificador único del cliente.
        .startClean() // Inicia una sesión nueva y limpia.
        .withWillQos(MqttQos.atMostOnce); // Nivel de calidad de servicio.

    client.connectionMessage = connMessage; // Asignar el mensaje de conexión.

    // Intentar conectar al servidor.
    try {
      await client.connect();
    } catch (e) {
      print('Error al conectar: $e'); // Imprime un mensaje en caso de error.
      client.disconnect(); // Desconecta en caso de fallo.
    }
  }

  // Función que se ejecuta al desconectarse del servidor MQTT.
  void onDisconnected() {
    setState(() {
      status = 'Desconectado'; // Actualizar el estado a desconectado.
    });
    print('Desconectado del broker'); // Mensaje en consola.
  }

  // Función que se ejecuta al conectarse al servidor MQTT.
  void onConnected() {
    setState(() {
      status = 'Conectado'; // Actualizar el estado a conectado.
    });
    print('Conectado al broker'); // Mensaje en consola.
    client.subscribe(
        'energia/consumo', MqttQos.atMostOnce); // Suscribirse al tema.
  }

  // Función que se ejecuta al suscribirse exitosamente a un tema.
  void onSubscribed(String topic) {
    print('Suscrito a $topic'); // Mensaje en consola.

    // Escuchar mensajes del servidor MQTT.
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
          message.payload.message); // Obtener el mensaje recibido.

      double consumoActual;
      try {
        consumoActual =
            double.parse(payload); // Intentar convertir el mensaje a un número.
      } catch (e) {
        consumoActual = 0; // Si falla, asignar 0.
      }

      setState(() {
        consumo = '$consumoActual W'; // Actualizar el consumo en pantalla.
        dataPoints.add(
            FlSpot(xValue, consumoActual)); // Agregar un punto a la gráfica.
        xValue += 1; // Incrementar el tiempo.

        // Mantener solo los últimos 1000 puntos en la gráfica.
        if (dataPoints.length > 1000) {
          dataPoints.removeAt(0); // Eliminar el punto más antiguo.
        }
      });

      print('Mensaje recibido: $payload'); // Mostrar el mensaje en consola.
    });
  }

  // Construcción de la interfaz gráfica.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitor de Energía'), // Título de la barra superior.
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16.0), // Espaciado alrededor del contenido.
        child: Column(
          children: [
            // Mostrar el estado de conexión.
            Text(
              'Estado de Conexión:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              status,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: status == 'Conectado' ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 40),

            // Mostrar el consumo actual.
            Text(
              'Consumo Actual:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              consumo,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),

            // Título de la gráfica.
            Text(
              'Gráfica de Consumo:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),

            // Gráfica de consumo.
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataPoints, // Puntos de la gráfica.
                      isCurved: true, // Suavizar las líneas.
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40, // Espacio para las etiquetas.
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: dataPoints.isNotEmpty
                      ? dataPoints.first.x
                      : 0, // Mínimo en X.
                  maxX: dataPoints.isNotEmpty
                      ? dataPoints.last.x
                      : 100, // Máximo en X.
                  minY: -20,
                  maxY: 20, // Máximo en Y.
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
