import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';

class AdminSignup extends StatefulWidget {
  const AdminSignup({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}
class _SignUpPageState extends State<AdminSignup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final emailFocusNode = FocusNode();


    return Scaffold(
        appBar: AppBar(
          title: const Text('Création de compte formateur'),
        ),
        body: SingleChildScrollView (child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                focusNode: emailFocusNode,  // Associez le FocusNode
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),

              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),

              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.visibility_off),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.visibility_off),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:  _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: const Color(0xFF5F259F), // Couleur du bouton
                ),
                child: const Text(
                  'Créer',
                  style: TextStyle(color: Colors.white), // Couleur du texte du bouton
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Souhaitez-vous:'),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Retourner à la page de connexion
                    },
                    child: const Text(
                      'Annuler ?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),)
    );
  }

  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      print('Les mots de passe ne correspondent pas');
      return;
    }

    try {
      // Enregistrer l'utilisateur avec Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Ajouter des informations supplémentaires dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'Formateur', // ou un autre rôle sélectionné par l'utilisateur
        'subscribedTopics': ['formateurs'], // Stocker les topics dans lesquels l'utilisateur est abonné
        'created_at': Timestamp.now(),
      });

      // Abonner l'utilisateur au topic
      //FirebaseMessaging.instance.subscribeToTopic('formateurs');

      print('Utilisateur créé et enregistré dans Firestore');
    } catch (e) {
      print('Erreur lors de la création du compte : $e');
    }
  }
}
