import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

final logger = Logger();

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<PresidentialCandidate> candidates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Refresh every 2 seconds for real-time updates
    _startRealTimeUpdates();
  }

  void _startRealTimeUpdates() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _loadData();
        _startRealTimeUpdates();
      }
    });
  }

  void _loadData() {
    final db = DatabaseService();
    setState(() {
      candidates = db.getAllPresidentialCandidates();
      isLoading = false;
    });
    logger.i('📊 Statistics updated: ${candidates.map((c) => '${c.name}: ${c.votes}').join(', ')}');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('📊 Election Statistics'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalVotes = candidates.fold<int>(0, (sum, c) => sum + c.votes);
    final leadingCandidate = candidates.isEmpty
        ? null
        : candidates.reduce((a, b) => a.votes > b.votes ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Election Statistics'),
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading Candidate
              if (leadingCandidate != null)
                Card(
                  elevation: 4,
                  color: Colors.blue.shade50,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade700,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🏆 LEADING CANDIDATE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          leadingCandidate.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          leadingCandidate.party,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  leadingCandidate.votes
                                      .toString()
                                      .replaceAllMapped(
                                      RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                          (m) => ','),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Votes',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${((leadingCandidate.votes / totalVotes) * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Share',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Vote Distribution Pie Chart
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Presidential Election Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: _generatePieSections(candidates),
                            centerSpaceRadius: 50,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLegend(candidates),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Overall Statistics
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Statistics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        'Total Votes Cast',
                        totalVotes.toString().replaceAllMapped(
                            RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ','),
                        Icons.how_to_vote,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        'Participating Candidates',
                        candidates.length.toString(),
                        Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        'Average Votes per Candidate',
                        (candidates.isEmpty
                            ? 0
                            : (totalVotes / candidates.length).toStringAsFixed(0))
                            .toString(),
                        Icons.bar_chart,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Detailed Candidate Results
              const Text(
                'Detailed Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...candidates.asMap().entries.map((entry) {
                final index = entry.key;
                final candidate = entry.value;
                final percentage = totalVotes > 0
                    ? ((candidate.votes / totalVotes) * 100)
                    : 0.0;
                final colors = [
                  Colors.blue.shade700,
                  Colors.green.shade700,
                  Colors.orange.shade700,
                  Colors.purple.shade700,
                  Colors.red.shade700,
                ];
                final color = colors[index % colors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      candidate.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      candidate.party,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: color,
                                    ),
                                  ),
                                  Text(
                                    candidate.votes
                                        .toString()
                                        .replaceAllMapped(
                                        RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                            (m) => ','),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(
      List<PresidentialCandidate> candidates) {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.red.shade700,
    ];
    final total = candidates.fold<int>(0, (sum, c) => sum + c.votes);

    return candidates.asMap().entries.map((entry) {
      final index = entry.key;
      final candidate = entry.value;
      final percentage =
      total > 0 ? ((candidate.votes / total) * 100) : 0.0;

      return PieChartSectionData(
        value: candidate.votes.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List<PresidentialCandidate> candidates) {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.red.shade700,
    ];

    final totalVotes = candidates.fold<int>(0, (sum, c) => sum + c.votes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: candidates.asMap().entries.map((entry) {
        final index = entry.key;
        final candidate = entry.value;
        final color = colors[index % colors.length];
        final percentage = totalVotes > 0
            ? ((candidate.votes / totalVotes) * 100)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${candidate.name} (${candidate.party})',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryOrange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}