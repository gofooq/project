import 'package:canbonapp/Screen/CalculationScreen.dart';
import 'package:canbonapp/Screen/HistoryScreen.dart';
import 'package:canbonapp/Screen/KnowledgeScreen.dart';
import 'package:canbonapp/Screen/PersonScreen.dart';
import 'package:canbonapp/Screen/carbon_credit_screen.dart';
import 'package:canbonapp/Screen/graphscreen.dart';
import 'package:canbonapp/Screen/login_screen.dart';
import 'package:canbonapp/Screen/notifications_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 18, 7, 109)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    Graphscreen(),
    HistoryScreen(),
    CarbonFootprintKnowledgeScreen(),
    PersonScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text(''),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
            icon: const Icon(Icons.notifications,
                color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ],
      ),
      drawer: const NavigationDrawer(),
      body: _pages[index],
      bottomNavigationBar: CurvedNavigationBar(
        index: index,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.insert_chart, size: 30, color: Colors.white),
          Icon(Icons.history, size: 30, color: Colors.white),
          Icon(Icons.book, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: const Color.fromARGB(255, 0, 128, 55),
        buttonBackgroundColor: Colors.blue.shade200,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            this.index = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  Future<User?> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        final userName = user?.displayName ?? 'Guest';
        final userEmail = user?.email ?? 'example@example.com';

        return Drawer(
          child: Column(
            children: [
              buildHeader(context, userName, userEmail),
              Expanded(child: buildMenuItems(context)),
            ],
          ),
        );
      },
    );
  }

  Widget buildHeader(BuildContext context, String userName, String userEmail) =>
      Container(
        color: const Color.fromARGB(255, 0, 128, 55),
        padding: EdgeInsets.only(
          top: 24 + MediaQuery.of(context).padding.top,
          bottom: 16,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage('https://www.example.com/default_profile.png'),
              ),
              const SizedBox(height: 8),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                userEmail,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      );

  Widget buildMenuItems(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          children: [
            buildMenuItem(
              context,
              icon: Icons.home,
              text: 'Home',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const MyHomePage(title: 'Home')),
                );
              },
            ),
            buildMenuItem(
              context,
              icon: Icons.history,
              text: 'ประวัติการคำนวณ',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HistoryScreen()));
              },
            ),
            buildMenuItem(
              context,
              icon: Icons.energy_savings_leaf,
              text: 'เครดิต',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CarbonCreditScreen()));
              },
            ),
            buildMenuItem(
              context,
              icon: Icons.book,
              text: 'ความรู้',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CarbonFootprintKnowledgeScreen()));
              },
            ),
            const Divider(color: Colors.black54),
            buildMenuItem(
              context,
              icon: Icons.account_tree,
              text: 'Plugins',
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PersonScreen()));
              },
            ),
            buildMenuItem(
              context,
              icon: Icons.notifications,
              text: 'Notifications',
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NotificationsScreen()));
              },
            ),
          ],
        ),
      );

  Widget buildMenuItem(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade800),
      title: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.white,
//               Colors.grey.shade200,
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 'ยินดีต้อนรับสู่ Carbon Footprint',
//                 style: TextStyle(
//                   color: Colors.black87,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 18),
//               Text(
//                 'สำรวจและจัดการคาร์บอนฟุตพรินต์ของคุณ',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 18,
//                 ),
//               ),
//               SizedBox(height: 32),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                   childAspectRatio: (screenWidth / 2) / ((screenWidth / 2) *1.4),
//                   children: [
//                     _buildFeatureCard(
//                       context,
//                       icon: Icons.calculate_outlined,
//                       title: 'คำนวณการปล่อยคาร์บอน',
//                       color: Colors.green.shade400,
//                       page: CalculationScreen(),
//                     ),
//                     _buildFeatureCard(
//                       context,
//                       icon: Icons.history,
//                       title: 'ประวัติการคำนวณ',
//                       color: Colors.blue.shade400,
//                       page: HistoryScreen(),
//                     ),
//                     _buildFeatureCard(
//                       context,
//                       icon: Icons.energy_savings_leaf,
//                       title: 'คำนวณเครดิตคาร์บอน',
//                       color: Colors.orange.shade400,
//                       page: CarbonCreditScreen(),
//                     ),
//                     _buildFeatureCard(
//                       context,
//                       icon: Icons.book_outlined,
//                       title: 'ความรู้คาร์บอน',
//                       color: Colors.red.shade400,
//                       page: CarbonFootprintKnowledgeScreen(),
//                     ),
//                   ]
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureCard(BuildContext context,
//       {required IconData icon,
//       required String title,
//       required Color color,
//       required Widget page}) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => page),
//         );
//       },
//       child: Card(
//         color: color,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 40, color: Colors.white),
//               SizedBox(height: 10),
//               Text(
//                 title,
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          // วางข้อความด้านบนสุดของหน้าจอ
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            color: const Color.fromARGB(255, 255, 255, 255), // พื้นหลังสีเขียว
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'ยินดีต้อนรับสู่ Carbon Footprint',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'สำรวจและจัดการคาร์บอนฟุตพรินต์ของคุณ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade200,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 28), // เพิ่มช่องว่าง
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: (screenWidth / 2) / ((screenWidth / 2) * 1.5),
                        children: [
                          _buildFeatureCard(
                            context,
                            icon: Icons.calculate_outlined,
                            title: 'คำนวณการปล่อยคาร์บอน',
                            color: Colors.green.shade400,
                            page: CalculationScreen(),
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.history,
                            title: 'ประวัติการคำนวณ',
                            color: Colors.blue.shade400,
                            page: HistoryScreen(),
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.energy_savings_leaf,
                            title: 'คำนวณเครดิตคาร์บอน',
                            color: Colors.orange.shade400,
                            page: CarbonCreditScreen(),
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.book_outlined,
                            title: 'ความรู้คาร์บอน',
                            color: Colors.red.shade400,
                            page: CarbonFootprintKnowledgeScreen(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required Widget page}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        color: color,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
