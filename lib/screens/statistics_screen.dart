import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, _) {
        final candidates = votingProvider.presidentialCandidates;
        final totalVotes = votingProvider.totalVotes;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 VOTING STATISTICS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Votes', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(votingProvider.formatVotes(totalVotes),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Voters', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(votingProvider.formatVotes(votingProvider.totalVoters),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Participation', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('${((totalVotes / votingProvider.totalVoters) * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Candidate breakdown
            const Text('🏆 CANDIDATE BREAKDOWN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...candidates.map((candidate) {
              final percentage = totalVotes > 0 ? (candidate.votes / totalVotes) * 100 : 0.0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(candidate.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text(candidate.party, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          ),
                          Text(votingProvider.formatVotes(candidate.votes),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalVotes > 0 ? candidate.votes / totalVotes : 0,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('${((totalVotes > 0 ? candidate.votes / totalVotes : 0) * 100).toStringAsFixed(0)} of $totalVotes',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
