import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart'; // For sharing
import 'package:screenshot/screenshot.dart'; // For taking screenshots// For file handling
import 'package:path_provider/path_provider.dart'; // For saving the screenshot

class TotalCarbonChart1 extends StatefulWidget {
  @override
  _TotalCarbonChartState createState() => _TotalCarbonChartState();
}

class _TotalCarbonChartState extends State<TotalCarbonChart1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScreenshotController _screenshotController = ScreenshotController(); // Screenshot controller

  List<CarbonData> chartData = [];
  List<CarbonData> creditData = [];
  double totalCarbonSum = 0.0;
  double totalCreditSum = 0.0;
  bool showMonthly = false;
  bool showCarbonChart = true;

  @override
  void initState() {
    super.initState();
    _fetchCarbonData();
    _fetchCarbonCreditData();
  }
  // ฟังก์ชันดึงข้อมูลจาก Firebase Firestore
  void _fetchCarbonData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('carbonCalculations')
            .where('userId', isEqualTo: user.uid)
            .orderBy('date', descending: false)
            .get();

        double sum = 0.0; // ตัวแปรเก็บผลรวมชั่วคราว

        List<CarbonData> fetchedData = snapshot.docs.map((doc) {
          double totalCarbonAmount;
          if (doc['totalCarbon Amount'] is int) {
            totalCarbonAmount = (doc['totalCarbon Amount'] as int).toDouble();
          } else if (doc['totalCarbon Amount'] is String) {
            totalCarbonAmount = double.parse(doc['totalCarbon Amount']);
          } else {
            totalCarbonAmount = 0.0;
          }

          sum += totalCarbonAmount; // รวมค่าคาร์บอนแต่ละครั้งที่ดึงมา

          return CarbonData(
            (doc['date'] as Timestamp).toDate(),
            totalCarbonAmount,
          );
        }).toList();
        
        

        setState(() {
          chartData = fetchedData;
          totalCarbonSum = sum;
        });
      } catch (e) {
        print('ดึงข้อมูลล้มเหลว: $e');
      }
    }
  }

  // Fetch carbon credit data from Firestore
  void _fetchCarbonCreditData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('carboncredit')
            .where('userId', isEqualTo: user.uid)
            .orderBy('date', descending: false)
            .get();

        double sum = 0.0; // Temporary sum for carbon credits

        List<CarbonData> fetchedCredits = snapshot.docs.map((doc) {
          double carbonCredit;
          if (doc['carboncredit'] is int) {
            carbonCredit = (doc['carboncredit'] as int).toDouble();
          } else if (doc['carboncredit'] is String) {
            carbonCredit = double.parse(doc['carboncredit']);
          } else {
            carbonCredit = 0.0;
          }

          sum += carbonCredit; // Sum the carbon credits

          return CarbonData(
            (doc['date'] as Timestamp).toDate(),
            carbonCredit,
          );
        }).toList();

        setState(() {
          creditData = fetchedCredits;
          totalCreditSum = sum;
        });
      } catch (e) {
        print('Fetching carbon credit data failed: $e');
      }
    }
  }

  // ฟังก์ชันกรองข้อมูลตามปีสำหรับคาร์บอนเครดิต
  List<CarbonData> _filterCreditDataByYear() {
    Map<String, double> yearlyData = {};

    for (var entry in creditData) {
      String yearKey =
          DateFormat('yyyy').format(entry.date); // กำหนดคีย์เป็นปี
      if (yearlyData.containsKey(yearKey)) {
        yearlyData[yearKey] = yearlyData[yearKey]! + entry.totalCarbonAmount;
      } else {
        yearlyData[yearKey] = entry.totalCarbonAmount;
      }
    }

    return yearlyData.entries
        .map((entry) => CarbonData(
              DateFormat('yyyy').parse(entry.key), // แปลงกลับเป็น DateTime
              entry.value,
            ))
        .toList();
  }
  List<CarbonData> _filterDataByMonth(List<CarbonData> data) {
  Map<String, double> monthlyData = {};

  for (var entry in data) {
    String monthKey =
        DateFormat('MM-yyyy').format(entry.date); // กำหนดคีย์เป็นเดือนและปี
    if (monthlyData.containsKey(monthKey)) {
      monthlyData[monthKey] = monthlyData[monthKey]! + entry.totalCarbonAmount;
    } else {
      monthlyData[monthKey] = entry.totalCarbonAmount;
    }
  }

  return monthlyData.entries
      .map((entry) => CarbonData(
            DateFormat('MM-yyyy').parse(entry.key), // แปลงกลับเป็น DateTime
            entry.value,
          ))
      .toList();
}


  // ฟังก์ชันจัดรูปแบบวันที่ในแกน X
  String _formatDate(DateTime date) {
    return showMonthly
        ? DateFormat('MM-yyyy').format(date) // สำหรับรายเดือน
        : DateFormat('dd-MM-yyyy').format(date); // สำหรับรายวัน
  }

  // The method for fetching the data will remain unchanged...

  // Function to capture and share the screenshot
  Future<void> _captureAndShareChart() async {
  try {
    final directory = await getTemporaryDirectory();
    final imagePath = await _screenshotController.captureAndSave(
      directory.path, // Save image to this path
      fileName: 'carbon_chart.png', // Name of the image file
    );

    // Use XFile for sharing the image
    if (imagePath != null) {
      final XFile imageFile = XFile(imagePath);
      await Share.shareXFiles([imageFile], text: 'Check out my Carbon Chart!');
    } else {
      print('Failed to capture image');
    }
  } catch (e) {
    print('Error capturing and sharing screenshot: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    List<CarbonData> dataToShow = showMonthly ? _filterDataByMonth(chartData) : chartData;
    List<CarbonData> creditsToShow = _filterCreditDataByYear();

    List<charts.Series<CarbonData, DateTime>> series = [
      charts.Series(
        id: 'Total Carbon',
        data: dataToShow,
        domainFn: (CarbonData carbon, _) => carbon.date,
        measureFn: (CarbonData carbon, _) => carbon.totalCarbonAmount,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        areaColorFn: (_, __) => charts.MaterialPalette.green.shadeDefault.lighter,
        fillColorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      )
    ];

    List<charts.Series<CarbonData, DateTime>> creditSeries = [
      charts.Series(
        id: 'Carbon Credits',
        data: creditsToShow,
        domainFn: (CarbonData credit, _) => credit.date,
        measureFn: (CarbonData credit, _) => credit.totalCarbonAmount,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        areaColorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault.lighter,
        fillColorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('กราฟแสดงปริมาณคาร์บอนทั้งหมด และคาร์บอนเครดิต'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _captureAndShareChart, // Share chart when pressed
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ToggleButtons(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('คาร์บอนฟุตพรินต์'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('คาร์บอนเครดิต'),
                  ),
                ],
                isSelected: [showCarbonChart, !showCarbonChart],
                onPressed: (index) {
                  setState(() {
                    showCarbonChart = index == 0;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    showMonthly = !showMonthly;
                  });
                },
                child: Text(showMonthly ? 'แสดงกราฟรายวัน' : 'แสดงกราฟรายเดือน'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Screenshot(
                controller: _screenshotController, // Wrap the chart with Screenshot widget
                child: showCarbonChart
                    ? _buildChart(series, 'ปริมาณคาร์บอนทั้งหมด (กก. CO2)')
                    : _buildChart(creditSeries, 'คาร์บอนเครดิต (กก. CO2eq)'),
              ),
            ),
            SizedBox(height: 16),
            Text(
              showCarbonChart
                  ? 'ปริมาณคาร์บอนทั้งหมด: ${totalCarbonSum.toStringAsFixed(2)} กก. CO2'
                  : 'คาร์บอนเครดิตที่ได้รับทั้งหมด: ${totalCreditSum.toStringAsFixed(2)} กก. CO2eq',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: showCarbonChart ? Colors.green[900] : Colors.blue[900],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<charts.Series<CarbonData, DateTime>> series, String title) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: charts.TimeSeriesChart(
          series,
          animate: true,
          dateTimeFactory: const charts.LocalDateTimeFactory(),
          defaultRenderer: charts.LineRendererConfig(
            includeArea: true,
            stacked: false,
          ),
          primaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec: charts.BasicNumericTickProviderSpec(
              zeroBound: false,
            ),
          ),
          domainAxis: charts.DateTimeAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
              labelStyle: charts.TextStyleSpec(
                fontSize: 12,
                color: charts.MaterialPalette.black,
              ),
              lineStyle: charts.LineStyleSpec(
                color: charts.MaterialPalette.black,
              ),
            ),
            tickFormatterSpec: charts.BasicDateTimeTickFormatterSpec(
              (DateTime date) => _formatDate(date),
            ),
          ),
          behaviors: [
            charts.ChartTitle('วันที่',
                behaviorPosition: charts.BehaviorPosition.bottom,
                titleStyleSpec: charts.TextStyleSpec(
                  fontSize: 14,
                  color: charts.MaterialPalette.gray.shadeDefault,
                )),
            charts.ChartTitle(title,
                behaviorPosition: charts.BehaviorPosition.start,
                titleStyleSpec: charts.TextStyleSpec(
                  fontSize: 14,
                  color: charts.MaterialPalette.gray.shadeDefault,
                )),
          ],
        ),
      ),
    );
  }
}

// คลาสสำหรับเก็บข้อมูลปริมาณคาร์บอนและวันที่
class CarbonData {
  final DateTime date;
  final double totalCarbonAmount;

  CarbonData(this.date, this.totalCarbonAmount);
}
