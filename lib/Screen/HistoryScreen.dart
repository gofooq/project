import 'package:canbonapp/Screen/detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteCalculation(String docId) async {
    try {
      await _firestore.collection('carbonCalculations').doc(docId).delete();
      print('ลบข้อมูลสำเร็จ');
    } catch (e) {
      print('เกิดข้อผิดพลาดในการลบข้อมูล: $e');
    }
  }

  // ฟังก์ชันจัดการรูปแบบเวลา
  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'ประวัติการคำนวณ',
        style: TextStyle(
          color: Colors.black,
          fontSize: 27,
          fontWeight: FontWeight.bold,
        ),
      )),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('carbonCalculations')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('ไม่มีประวัติการคำนวณ'));
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              final docData = doc.data() as Map<String, dynamic>;

              // ตรวจสอบว่าข้อมูลเป็น Timestamp หรือไม่ก่อนเรียกใช้ toDate()
              DateTime date = (docData['date'] is Timestamp)
                  ? (docData['date'] as Timestamp).toDate()
                  : DateTime.now();

              // เรียกใช้ฟังก์ชัน formatDateTime
              String formattedDate = formatDateTime(date);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                      'Total CO2: ${docData['totalCarbon Amount']} กก. CO2'),
                  subtitle: Text('Date: $formattedDate'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // แสดงการยืนยันก่อนลบข้อมูล
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('ยืนยันการลบ'),
                                content:
                                    Text('คุณต้องการลบข้อมูลนี้ใช่หรือไม่?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('ยกเลิก'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('ลบ'),
                                    onPressed: () {
                                      _deleteCalculation(doc.id);
                                      Navigator.of(context).pop(); // ปิด dialog
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailScreen(calculationData: docData),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
