import 'package:canbonapp/main.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CarbonPage extends StatefulWidget {
  final Map<String, String> results;

  CarbonPage({required this.results});

  @override
  _Carbonpage createState() => _Carbonpage();
}

class _Carbonpage extends State<CarbonPage> {
  List<Map<String, String>> savedResults = [];

  @override
  void initState() {
    super.initState();
    _loadSavedResults();
  }

  Future<void> _loadSavedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final _savedResults = prefs.getStringList('savedResults') ?? [];

    setState(() {
      savedResults = _savedResults.map((result) {
        final parts = result.split('|');
        return {parts[0]: parts[1]};
      }).toList();
    });
  }

  Future<void> _saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsToSave = widget.results.entries.map((entry) {
      return '${entry.key}|${entry.value}';
    }).toList();

    await prefs.setStringList('savedResults', resultsToSave);
    _loadSavedResults(); 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คาร์บอนสรุปผล'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คาร์บอนที่คำนวณได้',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.results.length,
                itemBuilder: (context, index) {
                  final key = widget.results.keys.elementAt(index);
                  final value = widget.results[key]!;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      title: Text(
                        key,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                } 
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: '',)), // หน้า Home ของคุณ
                    (Route<dynamic> route) => false, // ลบ stack ทั้งหมดและกลับไปยัง Home
                  );
                },
                child: Text('เสร็จสิ้น'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green[800],    // สีข้อความในปุ่ม
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),

              ),
            ),
        ],
        ),
      ),
      
    );
  }
}
