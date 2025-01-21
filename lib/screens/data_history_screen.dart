import 'package:flutter/material.dart';

class DataHistoryScreen extends StatelessWidget {
  final List<String> dataHistory;

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
          return ListTile(
            title: Text(dataHistory[index]),
          );
        },
      ),
    );
  }
}
