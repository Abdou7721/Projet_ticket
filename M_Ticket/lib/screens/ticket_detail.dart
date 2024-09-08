import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketDetailPage extends StatefulWidget {
  final String ticketId;
  final String title;
  final String status;
  final String category;
  final String description;
  final String reponse;

  TicketDetailPage({
    required this.ticketId,
    required this.title,
    required this.status,
    required this.category,
    required this.description,
    required this.reponse,
  });

  @override
  _TicketDetailPageState createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  late TextEditingController _reponseController;
  bool _isReponseModified = false;

  @override
  void initState() {
    super.initState();
    _reponseController = TextEditingController(text: widget.reponse);

    // Détecter les changements dans le texte de la réponse
    _reponseController.addListener(() {
      if (_reponseController.text != widget.reponse) {
        setState(() {
          _isReponseModified = true;
        });
      } else {
        setState(() {
          _isReponseModified = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _reponseController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerModifications() async {
    if (_isReponseModified) {
      try {
        // Recherchez le document en utilisant un autre champ unique, comme 'title'
        var querySnapshot = await FirebaseFirestore.instance
            .collection('tickets_crees')
            .where('title', isEqualTo: widget.title)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Supposons qu'il n'y a qu'un seul document correspondant
          var docId = querySnapshot.docs.first.id;

          // Mettez à jour le document
          await FirebaseFirestore.instance
              .collection('tickets_crees')
              .doc(docId)
              .update({'reponse': _reponseController.text});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Modifications enregistrées avec succès.')),
          );

          // Réinitialiser l'état modifié
          setState(() {
            _isReponseModified = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Document non trouvé.')),
          );
        }
      } catch (e) {
        print('Erreur lors de l\'enregistrement des modifications : $e'); // Afficher l'erreur dans la console
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement des modifications.')),
        );
      }
    }
  }


  void _traiterTicket() async {
    if (_isReponseModified) {
      await _enregistrerModifications();
    }

    try {
      // Recherchez le document en utilisant un autre champ unique, comme 'title'
      var querySnapshot = await FirebaseFirestore.instance
          .collection('tickets_crees')
          .where('title', isEqualTo: widget.title)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Supposons qu'il n'y a qu'un seul document correspondant
        var docId = querySnapshot.docs.first.id;

        // Mettez à jour le statut du document
        await FirebaseFirestore.instance
            .collection('tickets_crees')
            .doc(docId)
            .update({'statut': 'Resolu'});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le ticket a été marqué comme résolu.')),
        );

        Navigator.of(context).pop(); // Retour à la page précédente
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document non trouvé.')),
        );
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut du ticket : $e'); // Afficher l'erreur dans la console
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du statut du ticket.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isEditable = widget.status == 'En cours';

    return Scaffold(
      appBar: AppBar(
        title: Text('Détail du ticket', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF491B6D),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Titre: ${widget.title}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text('État du ticket: ${widget.status}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8.0),
                  Text('Catégorie: ${widget.category}', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: TextEditingController(text: widget.description),
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              readOnly: true,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _reponseController,
              decoration: InputDecoration(
                hintText: 'Réponse au ticket',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              readOnly: !isEditable,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: isEditable && _isReponseModified ? _enregistrerModifications : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF491B6D),
              ),
              child: Text('Enregistrer les modifications', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isEditable ? _traiterTicket : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF491B6D),
              ),
              child: Text('Traiter', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
