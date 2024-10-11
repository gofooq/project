// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // ใช้สำหรับจัดการรูปแบบวันที่

// class DetailScreen extends StatelessWidget {
//   final Map<String, dynamic> calculationData;

//   DetailScreen({required this.calculationData});

//   // ฟังก์ชันจัดการรูปแบบวันที่
//   String formatDateTime(DateTime dateTime) {
//     return DateFormat('yyyy-MM-dd HH:mm:ss')
//         .format(dateTime); // ไม่ให้มี . ต่อท้ายเวลา
//   }

//   @override
//   Widget build(BuildContext context) {
//     DateTime date = (calculationData['date'] is Timestamp)
//         ? (calculationData['date'] as Timestamp).toDate()
//         : DateTime.now(); // ตั้งค่าเป็นวันที่ปัจจุบันหากไม่มีข้อมูลวันที่

//     String formattedDate = formatDateTime(date);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('รายละเอียดการคำนวณ'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'รายละเอียดการคำนวณ',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Text(
//                 'การใช้ไฟฟ้า: ${calculationData['electricityCarbon Amount']} กก. CO2'),
//             SizedBox(height: 8),
//             Text(
//                 'การเดินทาง: ${calculationData['travelCarbon Amount']} กก. CO2'),
//             SizedBox(height: 8),
//             Text(
//                 'การบริโภคอาหาร: ${calculationData['foodCarbon Amount']} กก. CO2'),
//             SizedBox(height: 8),
//             Text(
//                 'คาร์บอนรวม: ${calculationData['totalCarbon Amount']} กก. CO2'),
//             SizedBox(height: 8),
//             Text('วันที่: $formattedDate'), // ใช้วันที่ที่ถูกจัดรูปแบบแล้ว
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ใช้สำหรับจัดการรูปแบบวันที่

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> calculationData;
  final bool isCarbonCredit; // Flag to determine the type of data

  DetailScreen({required this.calculationData, required this.isCarbonCredit});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController electricityController;
  late TextEditingController travelController;
  late TextEditingController foodController;

  @override
  void initState() {
    super.initState();
    electricityController = TextEditingController(text: widget.calculationData['electricityCarbon Amount'].toString());
    travelController = TextEditingController(text: widget.calculationData['travelCarbon Amount'].toString());
    foodController = TextEditingController(text: widget.calculationData['foodCarbon Amount'].toString());
  }

  @override
  void dispose() {
    electricityController.dispose();
    travelController.dispose();
    foodController.dispose();
    super.dispose();
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // Format the date
  }

  void _saveChanges() async {
    final updatedData = {
      'electricityCarbon Amount': double.tryParse(electricityController.text) ?? 0.0,
      'travelCarbon Amount': double.tryParse(travelController.text) ?? 0.0,
      'foodCarbon Amount': double.tryParse(foodController.text) ?? 0.0,
      'totalCarbon Amount': (double.tryParse(electricityController.text) ?? 0.0) +
                           (double.tryParse(travelController.text) ?? 0.0) +
                           (double.tryParse(foodController.text) ?? 0.0),
      'date': FieldValue.serverTimestamp(), // Update date to current timestamp
    };

    await FirebaseFirestore.instance.collection(widget.isCarbonCredit ? 'carboncredit' : 'carbonCalculations')
      .doc(widget.calculationData['id']) // Make sure you have the ID
      .update(updatedData);

    Navigator.pop(context); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = (widget.calculationData['date'] is Timestamp)
        ? (widget.calculationData['date'] as Timestamp).toDate()
        : DateTime.now(); // ตั้งค่าเป็นวันที่ปัจจุบันหากไม่มีข้อมูลวันที่

    String formattedDate = formatDateTime(date);

    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดการคำนวณ'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
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
            TextField(
              controller: electricityController,
              decoration: InputDecoration(labelText: 'การใช้ไฟฟ้า (กก. CO2)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            TextField(
              controller: travelController,
              decoration: InputDecoration(labelText: 'การเดินทาง (กก. CO2)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            TextField(
              controller: foodController,
              decoration: InputDecoration(labelText: 'การบริโภคอาหาร (กก. CO2)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            Text('คาร์บอนรวม: ${(double.tryParse(electricityController.text) ?? 0.0) + (double.tryParse(travelController.text) ?? 0.0) + (double.tryParse(foodController.text) ?? 0.0)} กก. CO2'),
            SizedBox(height: 8),
            Text('วันที่: $formattedDate'), // ใช้วันที่ที่ถูกจัดรูปแบบแล้ว
          ],
        ),
      ),
    );
  }
}
