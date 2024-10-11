// import 'package:canbonapp/page/carbon_page.dart';
// import 'package:canbonapp/page/carboncredit_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// class HistoryScreen extends StatefulWidget {
//   @override
//   _HistoryScreenState createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   bool showCarbonFootprint = true; // Default to showing carbon footprint

//   Future<void> _deleteCalculation(String docId) async {
//     try {
//       await _firestore.collection(showCarbonFootprint ? 'carbonCalculations' : 'carboncredit').doc(docId).delete();
//       print('ลบข้อมูลสำเร็จ');
//     } catch (e) {
//       print('เกิดข้อผิดพลาดในการลบข้อมูล: $e');
//     }
//   }

//   // ฟังก์ชันจัดการรูปแบบเวลา
//   String formatDateTime(DateTime dateTime) {
//     return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'ประวัติการคำนวณ',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 27,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Toggle buttons for selecting history type
//           ToggleButtons(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                 child: Text('คาร์บอนฟุตพรินต์'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                 child: Text('คาร์บอนเครดิต'),
//               ),
//             ],
//             isSelected: [showCarbonFootprint, !showCarbonFootprint],
//             onPressed: (index) {
//               setState(() {
//                 showCarbonFootprint = index == 0; // Update state based on selection
//               });
//             },
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection(showCarbonFootprint ? 'carbonCalculations' : 'carboncredit')
//                   .where('userId', isEqualTo: _auth.currentUser?.uid)
//                   .orderBy('date', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('ไม่มีประวัติการคำนวณ'));
//                 }

//                 final data = snapshot.data!.docs;

//                 return ListView.builder(
//                   itemCount: data.length,
//                   itemBuilder: (context, index) {
//                     final doc = data[index];
//                     final docData = doc.data() as Map<String, dynamic>;

//                     DateTime date = (docData['date'] is Timestamp)
//                         ? (docData['date'] as Timestamp).toDate()
//                         : DateTime.now();

//                     String formattedDate = formatDateTime(date);

//                     return Card(
//                       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                       child: ListTile(
//                         title: Text(
//                           showCarbonFootprint
//                               ? 'Total CO2: ${docData['totalCarbon Amount']} กก. CO2'
//                               : 'Carbon Credits: ${docData['carboncredit']} กก. CO2eq',
//                         ),
//                         subtitle: Text('Date: $formattedDate'),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.delete, color: Colors.red),
//                               onPressed: () {
//                                 // แสดงการยืนยันก่อนลบข้อมูล
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title: Text('ยืนยันการลบ'),
//                                       content: Text('คุณต้องการลบข้อมูลนี้ใช่หรือไม่?'),
//                                       actions: <Widget>[
//                                         TextButton(
//                                           child: Text('ยกเลิก'),
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                         ),
//                                         TextButton(
//                                           child: Text('ลบ'),
//                                           onPressed: () {
//                                             _deleteCalculation(doc.id);
//                                             Navigator.of(context).pop(); // ปิด dialog
//                                           },
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                             Icon(Icons.arrow_forward),
//                           ],
//                         ),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) {
//                                 if (showCarbonFootprint) {
//                                   return CarbonFootprintDetailScreen(calculationData: docData);
//                                 } else {
//                                   return CarbonCreditDetailScreen(calculationData: docData);
//                                 }
//                               },
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:canbonapp/page/carbon_page.dart';
import 'package:canbonapp/page/carboncredit_page.dart';
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

  bool showCarbonFootprint = true; // Default to showing carbon footprint

  Future<void> _deleteCalculation(String docId) async {
    try {
      await _firestore.collection(showCarbonFootprint ? 'carbonCalculations' : 'carboncredit').doc(docId).delete();
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
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700], // Nature-themed color
      ),
      body: Column(
        children: [
          // Toggle buttons for selecting history type
          ToggleButtons(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text('คาร์บอนฟุตพรินต์', style: TextStyle(color: Colors.black)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text('คาร์บอนเครดิต', style: TextStyle(color: Colors.black)),
              ),
            ],
            isSelected: [showCarbonFootprint, !showCarbonFootprint],
            onPressed: (index) {
              setState(() {
                showCarbonFootprint = index == 0; // Update state based on selection
              });
            },
            color: Colors.white, // Color for the selected buttons
            selectedColor: Colors.green[700], // Background color for selected buttons
            fillColor: Colors.green[300], // Background color for buttons
            borderColor: Colors.green[700], // Border color
            borderRadius: BorderRadius.circular(8),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(showCarbonFootprint ? 'carbonCalculations' : 'carboncredit')
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

                    DateTime date = (docData['date'] is Timestamp)
                        ? (docData['date'] as Timestamp).toDate()
                        : DateTime.now();

                    String formattedDate = formatDateTime(date);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      color: Colors.green[50], // Light green background for cards
                      child: ListTile(
                        title: Text(
                          showCarbonFootprint
                              ? 'Total CO2: ${docData['totalCarbon Amount']} กก. CO2'
                              : 'Carbon Credits: ${docData['carboncredit']} กก. CO2eq',
                          style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold), // Dark green for text
                        ),
                        subtitle: Text('Date: $formattedDate', style: TextStyle(color: Colors.grey[700])),
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
                                      content: Text('คุณต้องการลบข้อมูลนี้ใช่หรือไม่?'),
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
                              builder: (context) {
                                // Navigate to the appropriate detail screen
                                return showCarbonFootprint
                                    ? CarbonFootprintDetailScreen(calculationData: docData)
                                    : CarbonCreditDetailScreen(calculationData: docData);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
