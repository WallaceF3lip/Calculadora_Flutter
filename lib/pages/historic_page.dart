import 'package:flutter/material.dart';

class HistoricPage extends StatefulWidget {
  const HistoricPage({super.key, required this.historic});
  final List<String> historic;

  @override
  State<HistoricPage> createState() => _HistoricPageState();
}

class _HistoricPageState extends State<HistoricPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historico'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: widget.historic.isEmpty
        ? Center(
            child: Text(
              "Nenhum calculo realizado",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            )
          )    
        : ListView.builder(
          itemCount: widget.historic.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text(
                  widget.historic[index],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        ),
    );
  }
}