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
  String profilePictureUrl = ''; // Ensure this is used for displaying the image

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final databaseReference = FirebaseDatabase.instance.ref();
  final storageReference = FirebaseStorage.instance.ref();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data on initialization
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      setState(() {
        name = updatedUser?.displayName ?? '';
        email = updatedUser?.email ?? '';
        profilePictureUrl = updatedUser?.photoURL ?? ''; // Load the profile picture URL
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
        // Update Firebase Authentication user profile
        await user.updateProfile(displayName: nameController.text, photoURL: profilePictureUrl);
        await user.reload(); // Reload the user data after update
        final updatedUser = FirebaseAuth.instance.currentUser;

        // Update Realtime Database with user info
        final userRef = databaseReference.child('users').child(user.uid);
        await userRef.update({
          'name': nameController.text,
          'email': emailController.text,
          'profilePictureUrl': profilePictureUrl,
        });

        setState(() {
          name = updatedUser?.displayName ?? 'Unknown';
          email = updatedUser?.email ?? '';
          profilePictureUrl = updatedUser?.photoURL ?? ''; // Make sure to set the updated photo URL
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        print('Error updating profile: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${FirebaseAuth.instance.currentUser!.uid}');
        
        // Upload the file to Firebase Storage
        final uploadTask = storageReference.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        
        // Get the download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          profilePictureUrl = downloadUrl; // Update the profile picture URL state
        });

        // Call saveProfile to update Firebase Authentication with the new image URL
        _saveProfile();
      }
    } catch (e) {
      print('Error picking or uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
                      : AssetImage('assets/images/default_profile.png') as ImageProvider,
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
                'User Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.person, color: Colors.teal.shade400),
                title: Text('Name'),
                subtitle: Text(name),
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.teal.shade400),
                title: Text('Email'),
                subtitle: Text(email),
              ),
              SizedBox(height: 32),
              Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.teal.shade400),
                title: Text('Edit Profile'),
                onTap: _editProfile,
              ),
              ListTile(
                leading: Icon(Icons.security, color: Colors.teal.shade400),
                title: Text('Security Settings'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.teal.shade400),
                title: Text('About'),
                onTap: () {},
              ),
              SizedBox(height: 32),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
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

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              TextButton(
                onPressed: _pickImage,
                child: Text('Change Profile Picture'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
