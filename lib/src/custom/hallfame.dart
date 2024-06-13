import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Hallfame extends StatefulWidget {
  const Hallfame({super.key});

  @override
  State<Hallfame> createState() => _HallfameState();
}

class _HallfameState extends State<Hallfame> {
  Future<List<Map<String, dynamic>>> _fetchScores() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('scores')
        .orderBy('score', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No scores available.'));
          } else {
            final scores = snapshot.data!;
            return ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final scoreData = scores[index];
                return ListTile(
                  title: Text(scoreData['playerName']),
                  subtitle: Text('Score: ${scoreData['score']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
