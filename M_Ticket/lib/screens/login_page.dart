import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:m_ticket/screens/admin_dashboard.dart';
import 'package:m_ticket/screens/admin_signup.dart';
import 'package:m_ticket/screens/liste_ticket.dart';
import 'package:m_ticket/screens/signup_page.dart';
import 'package:m_ticket/screens/ticket_en_attente.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Etudiant';
  bool _obscureText = true; // Ajouté pour contrôler la visibilité du mot de passe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Bienvenue sur:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText, // Utiliser la variable d'état pour la visibilité
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey, // Optionnel : change la couleur de l'icône
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText; // Basculer la visibilité du mot de passe
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Add forgot password functionality
                  },
                  child: const Text('Mot de passe oublié ?'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildRoleOption('Etudiant'),
                  _buildRoleOption('Formateur'),
                  _buildRoleOption('Admin'),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Couleur de fond
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  try {
                    print('Email: ${_emailController.text}');
                    print('Mot de passe: ${_passwordController.text}');

                    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
                    // Récupérer le rôle de l'utilisateur depuis Firestore
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).get();
                    String role = userDoc['role'];

                    // Vérifier que le rôle correspond à celui sélectionné sur l'interface
                    if (role == _selectedRole) {
                      if (role == 'Etudiant') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ListeTicket()), // Rediriger vers la page d'accueil étudiant
                        );
                      } else if (role == 'Admin') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AdminDashboard()), // Rediriger vers le tableau de bord admin
                        );
                      } else if (role == 'Formateur') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ListeTicketEnAttente()), // Rediriger vers le tableau de bord formateur
                        );
                      }
                    } else {
                      // Si le rôle ne correspond pas, afficher un message d'erreur
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ce rôle ne vous est pas autorisé.')),
                      );
                      FirebaseAuth.instance.signOut(); // Déconnexion pour éviter tout accès non autorisé
                    }
                  } catch (e, stackTrace) {
                    if (e is FirebaseAuthException) {
                      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Erreur de connexion FirebaseAuth');
                    } else {
                      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Erreur inconnue');
                    }
                    print('Erreur de connexion : $e');
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'LOG IN',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    ); // Ajouter la fonctionnalité de création de compte
                  },
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role) {
    return Column(
      children: <Widget>[
        Radio<String>(
          value: role,
          groupValue: _selectedRole,
          onChanged: (String? value) {
            setState(() {
              _selectedRole = value!;
            });
          },
        ),
        Text(role),
      ],
    );
  }
}
