import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

final logger = Logger();

class VotingScreen extends StatefulWidget {
  const VotingScreen({Key? key}) : super(key: key);

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  List<PresidentialCandidate> candidates = [];
  String? userVotedFor; // Track which candidate user voted for
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
    // Refresh every 2 seconds for real-time updates
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _loadCandidates();
        });
      }
    });
  }

  void _loadCandidates() {
    final db = DatabaseService();
    setState(() {
      candidates = db.getAllPresidentialCandidates();
      isLoading = false;
    });
  }

  Future<void> _castVote(PresidentialCandidate candidate) async {
    // Check if user already voted
    if (userVotedFor != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ You already voted for ${userVotedFor}. One vote per person!'),
          backgroundColor: AppTheme.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Cast vote
    final db = DatabaseService();
    candidate.votes += 1;
    await db.addPresidentialCandidate(candidate);

    setState(() {
      userVotedFor = candidate.name;
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ You voted for ${candidate.name} (${candidate.party})!'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );

    logger.i('✅ Vote cast for ${candidate.name}');

    // Refresh to show updated votes
    await Future.delayed(const Duration(milliseconds: 500));
    _loadCandidates();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🗳️ Presidential Vote'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate total votes
    final totalVotes = candidates.fold<int>(0, (sum, c) => sum + c.votes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🗳️ Presidential Elections'),
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCandidates();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vote Distribution Chart
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vote Distribution',
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

              // Your Vote Status
              if (userVotedFor != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    border: Border.all(color: AppTheme.success),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You voted for: $userVotedFor',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (userVotedFor != null) const SizedBox(height: 24),

              // Total Votes Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  border: Border.all(color: AppTheme.info),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Total Votes: ${totalVotes.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Candidates List
              const Text(
                'Candidates',
                style: TextStyle(
                  fontSize: 18,
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
                final isUserVoted = userVotedFor == candidate.name;
                final isLeading = candidate.votes ==
                    candidates.fold<int>(
                        0, (max, c) => c.votes > max ? c.votes : max);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: userVotedFor == null
                        ? () => _castVote(candidate)
                        : null,
                    child: Card(
                      elevation: isUserVoted ? 4 : 1,
                      color: isUserVoted
                          ? AppTheme.success.withOpacity(0.1)
                          : AppTheme.cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isUserVoted ? AppTheme.success : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withOpacity(0.05),
                              color.withOpacity(0.02),
                            ],
                          ),
                        ),
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          candidate.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
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
                                  if (isLeading)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'LEADING',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  if (isUserVoted)
                                    const SizedBox(width: 8),
                                  if (isUserVoted)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppTheme.success,
                                      size: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Vote count and percentage
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${candidate.votes.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} votes',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Vote Button Info
              if (userVotedFor == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    border: Border.all(color: AppTheme.warning),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app, color: AppTheme.warning),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tap a candidate card to cast your vote',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: candidates.asMap().entries.map((entry) {
        final index = entry.key;
        final candidate = entry.value;
        final color = colors[index % colors.length];
        final percentage = totalVotes > 0
            ? ((candidate.votes / totalVotes) * 100)
            : 0.0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${candidate.name}: ${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}