import 'dart:math';
import 'package:canbonapp/page/carbon_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarbonCreditScreen extends StatefulWidget {
  @override
  _CarbonCreditScreenState createState() => _CarbonCreditScreenState();
}

class _CarbonCreditScreenState extends State<CarbonCreditScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  int _numberOfTrees = 1; // จำนวนต้นไม้เริ่มต้น
  List<double> _diameters = [0]; // รายการเก็บเส้นผ่านศูนย์กลางของต้นไม้
  List<double> _heights = [0]; // รายการเก็บความสูงของต้นไม้
  String _canboncreditResult = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void canboncalculate() {
    setState(() {
      double totalCO2Seq = 0; // ตัวแปรเก็บผลรวมของ CO2 ที่คำนวณได้

      for (int i = 0; i < _numberOfTrees; i++) {
        double diameter = _diameters[i];
        double height = _heights[i];

        double AGB = 0.045 * pow(diameter, 2) * pow(height, 0.921);
        double CS = (AGB * 0.47);
        double co2seq = CS * 44 / 12;

        totalCO2Seq += co2seq; // เพิ่มค่า CO2 ของแต่ละต้นไปยังผลรวม
      }

      _canboncreditResult = 'คาร์บอนเครดิตรวม ${totalCO2Seq.toStringAsFixed(2)} กก. CO2eq';
      _saveDataToFirebase(totalCO2Seq); // บันทึกผลรวมใน Firestore
    });
  }

  void _saveDataToFirebase(double co2seq) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('carboncredit').add({
        'userId': user.uid,
        'carboncredit': co2seq.toStringAsFixed(3),
        'date': FieldValue.serverTimestamp(),
      });
    }
  }

  void _navigateToStatistics() {
    Map<String, String> results = {
      'คาร์บอนเครดิต': _canboncreditResult,
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarbonPage(results: results),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('หน้าคำนวณ'),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildcarboncreditPage(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildcarboncreditPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'กรอกจำนวนต้นไม้',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          DropdownButton<int>(
            value: _numberOfTrees,
            items: List.generate(20, (index) => index + 1)
                .map((number) => DropdownMenuItem(
                      value: number,
                      child: Text(number.toString()),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _numberOfTrees = value!;
                _diameters = List.filled(_numberOfTrees, 0);
                _heights = List.filled(_numberOfTrees, 0);
              });
            },
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _numberOfTrees,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ต้นไม้ที่ ${index + 1}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
                      decoration: InputDecoration(
                        labelText: 'เส้นผ่านศูนย์กลาง(ซม.)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _diameters[index] = double.tryParse(value) ?? 0;
                      },
                    ),
                    SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
                      decoration: InputDecoration(
                        labelText: 'ความสูง (ม.)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _heights[index] = double.tryParse(value) ?? 0;
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0)
          ElevatedButton(
            onPressed: () {
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Text('ย้อนกลับ'),
          ),
        Spacer(),
        if (_currentPage == 0)
          ElevatedButton(style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              side: BorderSide(
                color: Colors.green, // สีของขอบปุ่ม
                width: 2, // ความหนาของขอบ
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // ปรับขอบมน
              ),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () {
              canboncalculate(); // คำนวณทั้งหมด
              _navigateToStatistics(); // นำทางไปยังหน้าสถิติ
            },
            child: Text('คำนวณ'),
    
          )
      ],
    );
  }
}
