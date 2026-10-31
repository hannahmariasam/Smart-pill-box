
import 'package:flutter/material.dart';

class DeviceStatusPage extends StatelessWidget {
  const DeviceStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Status'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Your Pillbox',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Connection Status
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.wifi,
                  color: Colors.green,
                  size: 30,
                ),
                title: const Text('Connection Status'),
                subtitle: const Text('Connected'),
                trailing: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Device Name
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.devices,
                  size: 30,
                  color: Colors.teal,
                ),
                title: const Text('Device Name'),
                subtitle: const Text('Smart Pillbox'),
              ),
            ),

            const SizedBox(height: 15),

            // Battery Level
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.battery_full,
                  size: 30,
                  color: Colors.green,
                ),
                title: const Text('Battery Level'),
                subtitle: const Text('85%'),
              ),
            ),

            const SizedBox(height: 15),

            // Last Synchronisation
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.sync,
                  size: 30,
                  color: Colors.teal,
                ),
                title: const Text('Last Synchronisation'),
                subtitle: const Text('Today, 10:30 AM'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
