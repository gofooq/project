import 'package:canbonapp/page/carbon_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

class CalculationScreen extends StatefulWidget {
  @override
  _CalculationScreenState createState() => _CalculationScreenState();
}

class _CalculationScreenState extends State<CalculationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _unit = TextEditingController();
  final TextEditingController _busController = TextEditingController();
  final TextEditingController _taxiController = TextEditingController();
  final TextEditingController _carController1 = TextEditingController();
  final TextEditingController _carController2 = TextEditingController();
  final TextEditingController _motorcycleController = TextEditingController();
  final TextEditingController _vanController = TextEditingController();
  final TextEditingController _trainController = TextEditingController();
  final TextEditingController _airplaneController1 = TextEditingController();
  final TextEditingController _airplaneController2 = TextEditingController();
  final TextEditingController _boatController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _beerController = TextEditingController();
  final TextEditingController _coffeeController = TextEditingController();
  final TextEditingController _milkController = TextEditingController();
  final TextEditingController _fruitjuiceController = TextEditingController();

  String _electricityResult = '';
  String _travelResult = '';
  String _foodResult = '';
  String _totalTravel = '';
  String _electricity = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  void _calculateAll() {
    print('Calculating all values...');
    setState(() {
      double electricityValue = double.tryParse(_electricityController.text) ?? 0;
      double unit = double.tryParse(_unit.text) ?? 1;
      double busValue = double.tryParse(_busController.text) ?? 0;
      double taxiValue = double.tryParse(_taxiController.text) ?? 0;
      double car1Value = double.tryParse(_carController1.text) ?? 0;
      double car2Value = double.tryParse(_carController2.text) ?? 0;
      double motorcycleValue = double.tryParse(_motorcycleController.text) ?? 0;
      double vanValue = double.tryParse(_vanController.text) ?? 0;
      double trainValue = double.tryParse(_trainController.text) ?? 0;
      double airplaneController1Value = double.tryParse(_airplaneController1.text) ?? 0;
      double airplaneController2Value = double.tryParse(_airplaneController2.text) ?? 0;
      double boatValue = double.tryParse(_boatController.text) ?? 0;
      double daysValue = double.tryParse(_daysController.text) ?? 0;
      double beerValue = double.tryParse(_beerController.text) ?? 0;
      double coffeeValue = double.tryParse(_coffeeController.text) ?? 0;
      double milkValue = double.tryParse(_milkController.text) ?? 0;
      double fruitjuice = double.tryParse(_fruitjuiceController.text) ?? 0;
      
      //การคำนวณคาร์บอนของการใช้ไฟฟ้า
      double electricityCarbon = ((electricityValue/unit) * 0.6933);
      double electricity = (electricityValue/unit);

      //การคำนวณคาร์บอนของการเดินทาง
      double totalTravelCO2 = ( (busValue * 2.850) + 
          ((taxiValue / 14.763) *2.1896 ) +
          ((car1Value / 14.763) *2.1896 ) +
          ((car2Value / 14.763) *2.7446 ) +
          ((motorcycleValue / 37.640 )*2.1896) +
          (vanValue * 10.204) +
          (trainValue * 0.1111) +
          (airplaneController1Value * 0.1733) +
          (airplaneController2Value * 0.1143) +
          (boatValue * 0.0446) );
      
      double totalTravel = (busValue + taxiValue + car1Value + car2Value + motorcycleValue + vanValue + trainValue + airplaneController2Value + airplaneController2Value + boatValue);

      // การคำนวณคาร์บอนของอาหาร
      double foodCO2 = (daysValue * 1.65) + 
        (beerValue * 0.3614) +
        ((coffeeValue *240) *  0.009) +
        ((milkValue * 240) * 0.0027) +
        ((fruitjuice * 240) * 0.005); 


      //ค่ารวมของคาร์บอนแต่ละชนิด
      _totalTravel = 'ระยะทาง: ${totalTravel.toDouble()} กิโลเมตร';
      _travelResult = 'การเดินทาง: ${totalTravelCO2.toStringAsFixed(3)} กก. CO2';
      _foodResult = 'การบริโภคอาหาร: ${foodCO2.toStringAsFixed(3)} กก. CO2';
      _electricityResult = 'การใช้ไฟฟ้า: ${(electricityCarbon.toStringAsFixed(3))} กก. CO2';
      _electricity = 'การใช้ไฟฟ้า: ${(electricity)} unit';
      // บันทึกข้อมูลลง Firestore
      _saveDataToFirebase(electricityCarbon, totalTravelCO2, foodCO2,);
    });
  }

  void _saveDataToFirebase(double electricityCarbon, double travelCO2, double foodCO2) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        double totalCarbon = (electricityCarbon ) + travelCO2 + foodCO2;
        
        // DateTime now = DateTime.now();

        // String formattedTime = DateFormat('HH:mm').format(now);
        
        // สร้าง document ใหม่ใน Firestore
        await _firestore.collection('carbonCalculations').add({
          'userId': user.uid,
          'electricityCarbon Amount': electricityCarbon.toStringAsFixed(3),
          'travelCarbon Amount': travelCO2.toStringAsFixed(3),
          'foodCarbon Amount': foodCO2.toStringAsFixed(3),
          'totalCarbon Amount': totalCarbon.toStringAsFixed(3),
          'date': FieldValue.serverTimestamp(),
        });
        await _firestore.collection('Travel Activity').add({
          'userId': user.uid,
          'distance':_totalTravel,
          'travelCarbon Amount': travelCO2.toStringAsFixed(3),
          'date': FieldValue.serverTimestamp(),
        });
        await _firestore.collection('electricity Activity').add({
          'userId': user.uid,
          'unit':_electricity,
          'electricityCarbon Amount': electricityCarbon.toStringAsFixed(3),
          'date': FieldValue.serverTimestamp(),
        });
        await _firestore.collection('food Activity').add({
          'userId': user.uid,
          'foodCarbon Amount': foodCO2.toStringAsFixed(3),
          'date': FieldValue.serverTimestamp(),
        });
      //   print('Data saved successfully');
       } catch (e) {
      // //   print('Failed to save data: $e');
      }
    }
  }

  void _navigateToStatistics() {
    print('Navigating to statistics...');
    Map<String, String> results = {
      'การใช้ไฟฟ้า': _electricityResult,
      'การเดินทาง': _travelResult,
      'การบริโภคอาหาร': _foodResult,
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
                _buildElectricityPage(),
                _buildTravelPage(),
                _buildFoodPage(),
              ],
            ),
          ),
          _buildPageIndicator(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildElectricityPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ข้อมูลการใช้ไฟฟ้า',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _electricityController,
            keyboardType: TextInputType.number,
            inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
            decoration: InputDecoration(
              labelText: 'ค่าไฟ (เดือน)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            style: TextStyle(fontSize: 16),
          ),
          TextField(
            controller: _unit,
            keyboardType: TextInputType.number,
            inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
            decoration: InputDecoration(
              labelText:( 'ค่าไฟ (ยูนิค(บาท))' ),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ข้อมูลการเดินทาง',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTravelInputField('รถบัส(ระยะทางต่อวัน(กิโลเมตร))', _busController, Icons.directions_bus),
            _buildTravelInputField('แท็กซี่(ระยะทางต่อวัน(กิโลเมตร))', _taxiController, Icons.local_taxi),
            _buildTravelInputField('รถยนต์ส่วนตัว[น้ำมันเบนซิน](ระยะทางต่อวัน(กิโลเมตร))', _carController1, Icons.directions_car),
            _buildTravelInputField('รถยนต์ส่วนตัว[น้ำมันดีเซล](ระยะทางต่อวัน(กิโลเมตร))', _carController2, Icons.directions_car),
            _buildTravelInputField('จักรยานยนต์(ระยะทางต่อวัน(กิโลเมตร))', _motorcycleController, Icons.motorcycle),
            _buildTravelInputField('รถตู้(ระยะทางต่อวัน(กิโลเมตร))', _vanController, Icons.airport_shuttle),
            _buildTravelInputField('รถไฟ(ระยะทางต่อวัน(กิโลเมตร))', _trainController, Icons.train),
            _buildTravelInputField('เครื่องบิน บินในประเทศ(ระยะทางต่อวัน(กิโลเมตร))', _airplaneController1, Icons.flight),
            _buildTravelInputField('เครื่องบิน บินต่างประเทศ(ระยะทางต่อวัน(กิโลเมตร))', _airplaneController2, Icons.flight),
            _buildTravelInputField('เรือ(ระยะทางต่อวัน(กิโลเมตร))', _boatController, Icons.directions_boat),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'การบริโภคอาหาร',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _daysController,
            keyboardType: TextInputType.number,
            inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
            decoration: InputDecoration(
              labelText: 'อาหาร(มื้อ)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _beerController,
            keyboardType: TextInputType.number,
            inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
            decoration: InputDecoration(
              labelText: 'เบียร์ (ขวด)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _coffeeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
            decoration: InputDecoration(
              labelText: 'กาแฟ (แก้ว)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _milkController,
            keyboardType: TextInputType.number,
            inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
            decoration: InputDecoration(
              labelText: 'นม (แก้ว)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _fruitjuiceController,
            keyboardType: TextInputType.number,
            inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
            decoration: InputDecoration(
              labelText: 'น้ำผลไม้ (แก้ว)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelInputField(String label, TextEditingController controller, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // ใส่เฉพาะตัวเลขและจุดทศนิยม
                      ],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: 8,
          
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.green[800] : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
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
        if (_currentPage == 2)
          ElevatedButton(
            onPressed: () {
              _calculateAll(); // คำนวณทั้งหมด
              _navigateToStatistics(); // นำทางไปยังหน้าสถิติ
            },
            child: Text('คำนวณ'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green[800],
            ),
          )
        else if (_currentPage < 2)
          ElevatedButton(
            onPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Text('ถัดไป'),
          ),
      ],
    );
  }
}
