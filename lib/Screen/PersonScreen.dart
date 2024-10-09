import 'dart:io';

import 'package:canbonapp/Screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonScreen extends StatefulWidget {
  @override
  _PersonScreenState createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  String name = '';
  String email = '';
  String profilePictureUrl = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final databaseReference = FirebaseDatabase.instance.ref();
  final storageReference = FirebaseStorage.instance.ref();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      setState(() {
        name = updatedUser?.displayName ?? '';
        email = updatedUser?.email ?? '';
        profilePictureUrl = updatedUser?.photoURL ?? '';
        nameController.text = name;
        emailController.text = email;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateProfile(
            displayName: nameController.text, photoURL: profilePictureUrl);
        await user.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;

        final userRef = databaseReference.child('users').child(user.uid);
        await userRef.update({
          'name': nameController.text,
          'email': emailController.text,
          'profilePictureUrl': profilePictureUrl,
        });

        setState(() {
          name = updatedUser?.displayName ?? 'Unknown';
          email = updatedUser?.email ?? '';
          profilePictureUrl = updatedUser?.photoURL ?? '';
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        print('Error updating profile: $e');
      }
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('แก้ไขโปรไฟล์'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profilePictureUrl.isNotEmpty
                      ? NetworkImage(profilePictureUrl)
                      : AssetImage('assets/default_profile.png')
                          as ImageProvider,
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('เปลี่ยนรูปโปรไฟล์'),
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'ชื่อ'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'อีเมล'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes =
            await file.readAsBytes(); // ใช้ readAsBytes แทน readAsBytesSync
        final storageReference = FirebaseStorage.instance.ref().child(
            'profile_pictures/${FirebaseAuth.instance.currentUser!.uid}');
        final uploadTask =
            storageReference.putData(bytes); // ส่งข้อมูลเป็น bytes
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          profilePictureUrl = downloadUrl;
        });
      }
    } catch (e) {
      print('Error picking or uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('โปรไฟล์'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profilePictureUrl.isNotEmpty
                      ? NetworkImage(profilePictureUrl)
                      : AssetImage('assets/default_profile.png')
                          as ImageProvider,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'ข้อมูลผู้ใช้',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.person, color: Colors.teal.shade400),
                title: Text('ชื่อ'),
                subtitle: Text(name),
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.teal.shade400),
                title: Text('อีเมล'),
                subtitle: Text(email),
              ),
              SizedBox(height: 32),
              Text(
                'การตั้งค่าบัญชี',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.teal.shade400),
                title: Text('แก้ไขโปรไฟล์'),
                onTap: _editProfile,
              ),
              ListTile(
                leading: Icon(Icons.security, color: Colors.teal.shade400),
                title: Text('การตั้งค่าความปลอดภัย'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.teal.shade400),
                title: Text('เกี่ยวกับ'),
                onTap: () {},
              ),
              SizedBox(height: 32),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
                onTap: () {
                  _logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
