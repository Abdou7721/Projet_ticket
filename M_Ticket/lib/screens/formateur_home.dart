import 'package:flutter/material.dart';
import 'package:m_ticket/screens/liste_ticket.dart';
import 'package:m_ticket/screens/ticket_en_attente.dart';

class FormateurHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF491B6D),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  // Naviguer vers la page des notifications
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour! DOOL',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF491B6D),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bienvenue !!!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatusCard(
                    'Tickets en attente',
                    '10',
                    Colors.grey,
                    context,
                  ),
                  _buildStatusCard(
                    'Tickets en cours de traitement',
                    '10',
                    Colors.yellow,
                    context,
                  ),
                  _buildStatusCard(
                    'Tickets résolus récemment',
                    '10',
                    Colors.green,
                    context,
                  ),
                  _buildStatusCard(
                    'Tous les tickets',
                    '30',
                    Colors.blue,
                    context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF491B6D),
        unselectedItemColor: Color(0xFFD9D9D9),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      String title, String count, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Tickets en attente') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListeTicketEnAttente()),
          );
        }
        // Gérer la navigation ou l'action ici pour les autres cartes si nécessaire
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Color(0xFF491B6D)),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF491B6D),
                ),
              ),
              SizedBox(height: 8),
              CircleAvatar(
                backgroundColor: color,
                radius: 20,
                child: Text(
                  count,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
