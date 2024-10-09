import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CarbonFootprintKnowledgeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ความรู้เกี่ยวกับคาร์บอนฟุตพรินต์',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Container(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/images/carbon_footprint1.png',
                  height: 400,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                Text(
                  'ทำความเข้าใจกับคาร์บอนฟุตพรินต์',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                SizedBox(height: 20),
                _buildKnowledgeText(
                    'คาร์บอนฟุตพรินต์คือปริมาณการปล่อยก๊าซคาร์บอนไดออกไซด์ (CO2) ที่เกิดจากกิจกรรมต่าง ๆ '
                    'ของบุคคล องค์กร เหตุการณ์ หรือผลิตภัณฑ์ โดยทั่วไปแล้วคาร์บอนฟุตพรินต์จะถูกวัดเป็นกิโลกรัม '
                    'หรือเป็นตันของ CO2 ที่ปล่อยออกมาภายในหนึ่งปีหรือจากกิจกรรมเฉพาะ เช่น การขนส่ง'),
                SizedBox(height: 20),
                _buildKnowledgeText(
                    'เรือก็มีส่วนในการปล่อยคาร์บอนเช่นกัน โดยขึ้นอยู่กับการใช้เชื้อเพลิงและระยะทางในการเดินทาง '
                    'ไม่ว่าจะเป็นเรือเพื่อการพักผ่อนหรือเพื่อการพาณิชย์ การเข้าใจและคำนวณคาร์บอนฟุตพรินต์ของคุณ '
                    'จะช่วยให้คุณสามารถดำเนินการลดการปล่อยก๊าซเหล่านี้ได้'),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.green.shade800,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'คำแนะนำ: การลดการใช้เชื้อเพลิง การเปลี่ยนไปใช้เชื้อเพลิงที่สะอาดกว่า หรือการลดระยะทาง '
                        'เป็นวิธีการที่มีประสิทธิภาพในการลดคาร์บอนฟุตพรินต์จากการใช้เรือ',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.green.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildKnowledgeText(
                    'การเรียนรู้เพิ่มเติมเกี่ยวกับการปล่อยก๊าซคาร์บอนและการนำแนวทางที่ยั่งยืนมาใช้ '
                    'สามารถช่วยลดการปล่อยก๊าซเรือนกระจกและมีส่วนร่วมในการต่อสู้กับการเปลี่ยนแปลงสภาพภูมิอากาศได้อย่างมีประสิทธิภาพ'),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _launchURL();
                  },
                  child: Text(
                    'แหล่งที่มา: Ecomatcher',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKnowledgeText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        height: 1.5,
        color: Colors.grey.shade800,
      ),
    );
  }

  void _launchURL() async {
    const url =
        'https://www.nature.org/en-us/get-involved/how-to-help/carbon-footprint-calculator/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'ไม่สามารถเปิดลิงก์ได้: $url';
    }
  }
}
