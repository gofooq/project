import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNotificationCard(
              title: 'Update Available',
              description:
                  'A new version of the app is available. Update now for new features.',
              date: '2024-08-29',
            ),
            _buildNotificationCard(
              title: 'Maintenance Notice',
              description:
                  'The app will undergo maintenance on 2024-09-01. Expect temporary outages.',
              date: '2024-08-28',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String date,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(description),
        trailing: Text(
          date,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
