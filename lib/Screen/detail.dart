import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ใช้สำหรับจัดการรูปแบบวันที่

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> calculationData;

  DetailScreen({required this.calculationData});

  // ฟังก์ชันจัดการรูปแบบวันที่
  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(dateTime); // ไม่ให้มี . ต่อท้ายเวลา
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = (calculationData['date'] is Timestamp)
        ? (calculationData['date'] as Timestamp).toDate()
        : DateTime.now(); // ตั้งค่าเป็นวันที่ปัจจุบันหากไม่มีข้อมูลวันที่

    String formattedDate = formatDateTime(date);

    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดการคำนวณ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'รายละเอียดการคำนวณ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
                'การใช้ไฟฟ้า: ${calculationData['electricityCarbon Amount']} กก. CO2'),
            SizedBox(height: 8),
            Text(
                'การเดินทาง: ${calculationData['travelCarbon Amount']} กก. CO2'),
            SizedBox(height: 8),
            Text(
                'การบริโภคอาหาร: ${calculationData['foodCarbon Amount']} กก. CO2'),
            SizedBox(height: 8),
            Text(
                'คาร์บอนรวม: ${calculationData['totalCarbon Amount']} กก. CO2'),
            SizedBox(height: 8),
            Text('วันที่: $formattedDate'), // ใช้วันที่ที่ถูกจัดรูปแบบแล้ว
          ],
        ),
      ),
    );
  }
}
