import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/voting_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, _) {
        final candidates = votingProvider.presidentialCandidates;
        final totalVotes = votingProvider.getTotalVotes(candidates);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Stats
            SafeArea(child: Container()),
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
                  Row(
                    children: [
                      const Text('📊 PRESIDENTIAL ELECTION', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 6),
                            SizedBox(width: 4),
                            Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Votes Cast', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(votingProvider.formatVotes(totalVotes),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Candidates', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('${candidates.length}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Update Freq.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const Text('Every 500ms',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Circular Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Text('Vote Distribution (Pie Chart)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: candidates.map((candidate) {
                          final percentage = totalVotes > 0 ? (candidate.votes / totalVotes) * 100 : 0.0;
                          return PieChartSectionData(
                            value: candidate.votes.toDouble(),
                            color: _getColorForParty(candidate.party),
                            title: '${percentage.toStringAsFixed(1)}%',
                            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            radius: 80,
                          );
                        }).toList(),
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Legend
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: candidates.map((candidate) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getColorForParty(candidate.party),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            candidate.party,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Candidate breakdown with real-time updates
            const Text('🏆 DETAILED BREAKDOWN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalVotes > 0 ? candidate.votes / totalVotes : 0,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(_getColorForParty(candidate.party)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${percentage.toStringAsFixed(2)}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('≈ ${(candidate.votes / 1000).toStringAsFixed(1)}K votes',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ));
              }).toList(),

            const SizedBox(height: 20),
            // Real-time note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Real-Time Updates', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Votes are being cast continuously every 500ms. Charts update in real-time!',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getColorForParty(String party) {
    switch (party) {
      case 'APC':
        return const Color(0xFF3B82F6); // Blue
      case 'PDP':
        return const Color(0xFFEF4444); // Red
      case 'LP':
        return const Color(0xFF10B981); // Green
      case 'NNPP':
        return const Color(0xFFF59E0B); // Amber
      case 'SDP':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
