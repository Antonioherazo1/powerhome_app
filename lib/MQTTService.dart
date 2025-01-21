import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  final String broker = 'thinc.site'; // Cambia esto por tu broker
  final int port = 1883;
  final String clientIdentifier = 'flutter_client';
  late MqttServerClient client;

  void connectToBroker() async {
    client = MqttServerClient(broker, clientIdentifier);
    client.port = port;
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    final MqttConnectMessage connectMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connectMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Error conectando al broker: $e');
      disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Conectado al broker');
      subscribeToTopic('test/topic'); // Suscríbete al tema deseado
    } else {
      print('Error: ${client.connectionStatus}');
      disconnect();
    }
  }

  void subscribeToTopic(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
      final MqttPublishMessage message =
          messages[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Mensaje recibido: $payload'); // Aquí manejarás los datos recibidos
      onMessageReceived!(payload);
    });
  }

  void onConnected() {
    print('Conexión exitosa');
  }

  void onDisconnected() {
    print('Desconectado del broker');
  }

  void disconnect() {
    client.disconnect();
  }

  // Función de callback para manejar los datos recibidos
  void Function(String)? onMessageReceived;
}
