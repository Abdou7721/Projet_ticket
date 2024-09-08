
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_ticket/screens/liste_ticket.dart';




class CreateTicketPage extends StatefulWidget {
  @override
  _CreateTicketPageState createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reponseController = TextEditingController();


  String? _selectedCategory;

  final CollectionReference ticketsCollection =
  FirebaseFirestore.instance.collection('tickets_crees');

  void _submitTicket() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    String? category = _selectedCategory;
    String reponse = _reponseController.text.trim(); // Champ caché

    User? user = FirebaseAuth.instance.currentUser; // Récupérer l'utilisateur connecté

    if (user != null && title.isNotEmpty && description.isNotEmpty && category != null) {
      await ticketsCollection.add({
        'title': title,
        'description': description,
        'category': category,
        'created_at': Timestamp.now(),
        'statut': 'En attente',
        'reponse': reponse, // Ajout du champ réponse
        'uid': user.uid // Ajout du uid de l'utilisateur
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ticket soumis avec succès !')),
      );

      // Clear the form after submission
      _titleController.clear();
      _descriptionController.clear();
      _reponseController.clear();
      setState(() {
        _selectedCategory = null;
      });
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un ticket', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF491B6D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListeTicket()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titre', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Sujet du ticket',
                border: OutlineInputBorder(),
              ),
              maxLength: 12, // Limite à 12 caractères
            ),
            SizedBox(height: 16.0),
            Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Décrire votre problème',
                border: OutlineInputBorder(),
              ),
              maxLength: 100, // Limite à 100 caractères
              maxLines: 4,
            ),
            SizedBox(height: 16.0),
            Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: [
                DropdownMenuItem(child: Text('Technique'), value: 'Technique'),
                DropdownMenuItem(child: Text('Théorique'), value: 'Théorique'),
                DropdownMenuItem(child: Text('Amélioration'), value: 'Amélioration'),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Choisir la catégorie',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF491B6D),
                  ),
                  child: Text('Soumettre', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF491B6D),
                  ),
                  child: Text('Annuler', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
