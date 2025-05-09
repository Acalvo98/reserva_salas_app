import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllReservationsScreen extends StatelessWidget {
  const AllReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservationsRef = FirebaseFirestore.instance.collection(
      'reservations',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Todas las reservas')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            reservationsRef.orderBy('startTime', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('❌ Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('⚠️ No hay reservas registradas'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final startTime =
                  data['startTime'] != null
                      ? (data['startTime'] as Timestamp).toDate().toLocal()
                      : null;
              final endTime =
                  data['endTime'] != null
                      ? (data['endTime'] as Timestamp).toDate().toLocal()
                      : null;
              final createdAt =
                  data['createdAt'] != null
                      ? (data['createdAt'] as Timestamp).toDate().toLocal()
                      : null;

              final roomName = data['roomName'] ?? 'Sin nombre';
              final userName = data['userName'] ?? 'Usuario desconocido';
              final notes = data['notes'] ?? 'Sin notas';
              final status = data['status'] ?? 'sin estado';

              Color statusColor;
              switch (status) {
                case 'active':
                  statusColor = Colors.green;
                  break;
                case 'cancelled':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(roomName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Responsable: $userName'),
                      if (startTime != null) Text('Inicio: $startTime'),
                      if (endTime != null) Text('Fin: $endTime'),
                      Text('Notas: $notes'),
                      Text(
                        'Estado: $status',
                        style: TextStyle(color: statusColor),
                      ),
                      if (createdAt != null)
                        Text(
                          'Creado: $createdAt',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
