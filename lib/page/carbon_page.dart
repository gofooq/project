import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ใช้สำหรับจัดการรูปแบบวันที่

class CarbonFootprintDetailScreen extends StatelessWidget {
  final Map<String, dynamic> calculationData;

  CarbonFootprintDetailScreen({required this.calculationData});

  // ฟังก์ชันจัดการรูปแบบวันที่
  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // Format the date
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = (calculationData['date'] is Timestamp)
        ? (calculationData['date'] as Timestamp).toDate()
        : DateTime.now(); // Set to current date if no date data

    String formattedDate = formatDateTime(date);

    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดการคำนวณคาร์บอนฟุตพรินต์'),
        backgroundColor: Colors.green[700], // Nature-themed color
      ),
      body: Center( // Centering the content
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.green[50], // Light green background for the card
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายละเอียดการคำนวณ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[900]),
                  ),
                  SizedBox(height: 16),
                  Text('การใช้ไฟฟ้า: ${calculationData['electricityCarbon Amount'] ?? 0.0} กก. CO2'),
                  SizedBox(height: 8),
                  Text('การเดินทาง: ${calculationData['travelCarbon Amount'] ?? 0.0} กก. CO2'),
                  SizedBox(height: 8),
                  Text('การบริโภคอาหาร: ${calculationData['foodCarbon Amount'] ?? 0.0} กก. CO2'),
                  SizedBox(height: 8),
                  Text('คาร์บอนรวม: ${calculationData['totalCarbon Amount'] ?? 0.0} กก. CO2'),
                  SizedBox(height: 8),
                  Text('วันที่: $formattedDate', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
