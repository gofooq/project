import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; // เพิ่มการเชื่อมต่อ Realtime Database

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController(); // ฟิลด์ชื่อ
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  Future<FirebaseApp> _initializeFirebase() async {
    return await Firebase.initializeApp(
      // options: FirebaseOptions(
      //  apiKey: 'AIzaSyDoSAA9PKZeIoxSHAUJN_W-kxWzWOMvFx0',
      //   appId: '1:1080929298717:android:eb3c55339382645ddd99f4',
      //   messagingSenderId: '1080929298717',
      //   projectId: 'labb-88805',
      //   databaseURL:'https://labb-88805-default-rtdb.firebaseio.com',
      //   storageBucket:'labb-88805.appspot.com',
      // ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Fluttertoast.showToast(msg: 'Passwords do not match');
        return;
      }

      try {
        // สร้างผู้ใช้ด้วยอีเมลและรหัสผ่าน
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await userCredential.user!
            .updateProfile(displayName: _nameController.text);
        await userCredential.user!.reload();

        DatabaseReference userRef = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(userCredential.user!.uid);
        await userRef.set({
          'name': _nameController.text,
          'email': _emailController.text,
        });

        Fluttertoast.showToast(msg: 'Registration successful');
        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // คุณสามารถเพิ่มชื่อเรื่องถ้าต้องการ
        backgroundColor: Colors.white, // ตั้งค่าสีพื้นหลังเป็นสีขาว
        foregroundColor:
            Colors.black, // ตั้งค่าสีข้อความเป็นสีดำเพื่อให้มองเห็นได้ชัดเจน
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Register',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureTextPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureTextPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureTextPassword = !_obscureTextPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureTextConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureTextConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureTextConfirmPassword =
                                !_obscureTextConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
