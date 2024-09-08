import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_ticket/screens/ticket_detail.dart';

class ListeTicketEnAttente extends StatefulWidget {
  @override
  _ListeTicketState createState() => _ListeTicketState();
}

class _ListeTicketState extends State<ListeTicketEnAttente> {
  final CollectionReference ticketsCollection =
  FirebaseFirestore.instance.collection('tickets_crees');
  bool isDescending = true;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des tickets', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF491B6D),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un ticket',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ticketsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final tickets = snapshot.data!.docs.where((doc) {
                    return doc['title']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                        doc['description']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());
                  }).toList();

                  if (tickets.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun Ticket enregistré',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      var ticket = tickets[index];
                      var statut =
                          ticket['statut'] ?? 'En attente'; // Récupérer le statut ou définir une valeur par défaut

                      // Déterminer l'état de l'icône 'assignment' et la couleur de l'icône 'circle'
                      bool isAssignmentEnabled = statut == 'En attente' || statut == 'En cours';
                      Color circleColor;

                      // Logique de couleur pour l'icône circle
                      if (statut == 'En cours') {
                        circleColor = Colors.green; // Vert pour "En cours"
                      } else if (statut == 'En attente') {
                        circleColor = Colors.grey; // Gris pour "En attente"
                      } else {
                        circleColor = Colors.blue; // Bleu pour les autres statuts
                      }

                      return ListTile(
                        leading: Icon(
                          Icons.circle,
                          color: circleColor, // Appliquer la couleur déterminée
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ticket['title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              statut,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(ticket['description']),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.assignment,
                            color: isAssignmentEnabled
                                ? Colors.blue
                                : Colors.grey, // Désactiver l'icône 'assignment' si le statut est résolu
                          ),
                          onPressed: isAssignmentEnabled
                              ? () async {
                            // Mise à jour du statut dans Firestore
                            await ticketsCollection
                                .doc(ticket.id)
                                .update({'statut': 'En cours'}).then((_) {
                              // Ensuite, on récupère à nouveau les données mises à jour du ticket
                              var updatedTicket = ticketsCollection.doc(ticket.id).get();

                              updatedTicket.then((updatedData) {
                                // Ensuite, on navigue vers la page de détails du ticket avec le statut mis à jour
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TicketDetailPage(
                                      title: updatedData['title'],
                                      status: updatedData['statut'], // Utilisation du statut mis à jour
                                      category: updatedData['category'],
                                      description: updatedData['description'],
                                      reponse: updatedData['reponse'] ?? '',
                                      ticketId: ticket.id,
                                    ),
                                  ),
                                );
                              });
                            });

                            // Notification SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ticket pris en charge')),
                            );
                          }
                              : null, // Désactiver le bouton si le statut n'est pas modifiable
                        ),

                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
