import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'Accueil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Bienvenue, Administrateur!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
