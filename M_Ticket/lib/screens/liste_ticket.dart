import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:m_ticket/screens/creation_ticket.dart';
import 'package:intl/intl.dart';

class ListeTicket extends StatefulWidget {
  @override
  _ListeTicketState createState() => _ListeTicketState();
}

class _ListeTicketState extends State<ListeTicket> {
  final CollectionReference ticketsCollection =
  FirebaseFirestore.instance.collection('tickets_crees');
  bool isDescending = true;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser; // Récupérer l'utilisateur connecté

    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF491B6D),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTicketPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isDescending ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isDescending = !isDescending;
              });
            },
          ),
        ],
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
                stream: ticketsCollection
                    .where('uid', isEqualTo: user!.uid) // Filtrer par utilisateur
                    .snapshots(),
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
                      var createdAt =
                      (ticket['created_at'] as Timestamp).toDate();
                      var formattedDate =
                      DateFormat('dd/MM/yyyy').format(createdAt);
                      var formattedTime =
                      DateFormat('HH:mm').format(createdAt);
                      var statut = ticket['statut'] ?? 'En attente';

                      Color circleColor;
                      Color statusColor;

                      switch (statut) {
                        case 'En cours':
                          circleColor = Colors.green;
                          statusColor = Colors.green;
                          break;
                        case 'Resolu':
                          circleColor = Colors.blue;
                          statusColor = Colors.blue;
                          break;
                        default:
                          circleColor = Colors.grey;
                          statusColor = Colors.grey[600]!;
                          break;
                      }

                      return ListTile(
                        leading: Icon(Icons.circle, color: circleColor),
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
                                color: statusColor,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ticket['description']),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDate,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  formattedTime,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirmer la suppression'),
                                content: Text(
                                    'Voulez-vous vraiment supprimer ce ticket ?'),
                                actions: [
                                  TextButton(
                                    child: Text('Annuler'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: Text('Supprimer'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                            );
                            if (confirmDelete) {
                              await ticketsCollection.doc(ticket.id).delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ticket supprimé')),
                              );
                            }
                          },
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
