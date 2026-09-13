import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/voting_provider.dart';
import '../theme/app_theme.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({Key? key}) : super(key: key);

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        title: const Text('Vote Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Presidential', icon: Icon(Icons.person)),
            Tab(text: 'Governors', icon: Icon(Icons.location_city)),
            Tab(text: 'Local Govt', icon: Icon(Icons.domain)),
            Tab(text: 'Reforms', icon: Icon(Icons.description)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PresidentialTab(),
          _GovernorsTab(),
          _LGATab(),
          _ReformsTab(),
        ],
      ),
    );
  }
}

// ============================================================
// PRESIDENTIAL TAB
// ============================================================

class _PresidentialTab extends StatelessWidget {
  const _PresidentialTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, _) {
        final candidates = votingProvider.presidentialCandidates;
        final totalVotes = votingProvider.totalVotes;
        final userVotedFor = votingProvider.userVoteState.votedPresidentialId;
        final canVote = votingProvider.canVotePresidential();

        if (candidates.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final leadingCandidate = candidates.isNotEmpty ? candidates[0] : null;

        return RefreshIndicator(
          onRefresh: () => votingProvider.refreshData(),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Leader card
              if (leadingCandidate != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.amber.shade600, Colors.amber.shade800],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('🏆 LEADING', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(leadingCandidate.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(leadingCandidate.party, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 12),
                      Text('${votingProvider.formatVotes(leadingCandidate.votes)} votes',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalVotes > 0 ? leadingCandidate.votes / totalVotes : 0,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${votingProvider.getVotePercentage(leadingCandidate).toStringAsFixed(1)}% of ${votingProvider.formatVotes(totalVotes)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

              // Voting comparison
              Container(
                padding: const EdgeInsets.all(12),
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
                        Icon(Icons.trending_up, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text('VOTING RANKINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      candidates.length,
                      (index) => _VotingRankItem(
                        rank: index + 1,
                        candidate: candidates[index],
                        totalVotes: totalVotes,
                        votingProvider: votingProvider,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Your vote section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: canVote ? Colors.green.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: canVote ? Colors.green.shade300 : Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    if (canVote) ...[
                      const Text('CAST YOUR VOTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 12),
                      ...candidates.map((candidate) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await votingProvider.votePresidential(candidate.id);
                              if (success) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✅ You voted for ${candidate.name}!'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Vote for ${candidate.name}'),
                          ),
                        );
                      }).toList(),
                    ] else ...[
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 40),
                      const SizedBox(height: 8),
                      const Text('✓ YOU HAVE VOTED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 4),
                      Text('You voted for: $userVotedFor', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('You can only vote once per election',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Live stats
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.purple.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text('LIVE VOTING STATISTICS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
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
                    _StatRow('Total Votes', votingProvider.formatVotes(totalVotes)),
                    const SizedBox(height: 8),
                    _StatRow('Total Voters', votingProvider.formatVotes(votingProvider.totalVoters)),
                    const SizedBox(height: 8),
                    _StatRow('Participation', '${((totalVotes / votingProvider.totalVoters) * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VotingRankItem extends StatelessWidget {
  final int rank;
  final PresidentialCandidate candidate;
  final int totalVotes;
  final VotingProvider votingProvider;

  const _VotingRankItem({
    required this.rank,
    required this.candidate,
    required this.totalVotes,
    required this.votingProvider,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalVotes > 0 ? (candidate.votes / totalVotes) * 100 : 0.0;
    final isLeader = rank == 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isLeader ? Colors.amber.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    rank == 1 ? '🏆' : '$rank',
                    style: TextStyle(
                      color: isLeader ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(candidate.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(candidate.party, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(votingProvider.formatVotes(candidate.votes), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalVotes > 0 ? candidate.votes / totalVotes : 0,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation<Color>(isLeader ? Colors.amber.shade600 : Colors.blue.shade400),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ============================================================
// GOVERNORS TAB
// ============================================================

class _GovernorsTab extends StatefulWidget {
  const _GovernorsTab();

  @override
  State<_GovernorsTab> createState() => _GovernorsTabState();
}

class _GovernorsTabState extends State<_GovernorsTab> {
  String selectedState = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, _) {
        final states = votingProvider.getGovernorStates();
        final candidates = selectedState.isEmpty ? [] : votingProvider.getGovernorCandidatesByState(selectedState);
        final totalVotes = votingProvider.getTotalVotes(candidates);

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            DropdownButton<String>(
              value: selectedState.isEmpty ? null : selectedState,
              hint: const Text('Select a state'),
              isExpanded: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => selectedState = newValue);
                }
              },
              items: (states as List<String>)
                  .map<DropdownMenuItem<String>>((String state) {
                return DropdownMenuItem<String>(value: state, child: Text(state));
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (selectedState.isEmpty)
              const Center(child: Text('Select a state to see candidates'))
            else ...[
              // Live stats
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Votes', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(votingProvider.formatVotes(totalVotes),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
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
              ),
              const SizedBox(height: 12),
              ...candidates.asMap().entries.map((entry) {
                int idx = entry.key;
                var candidate = entry.value;
                final hasVoted = votingProvider.hasVotedGovernor(candidate.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${idx + 1}.', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(candidate.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  Text(candidate.party, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Text(votingProvider.formatVotes(candidate.votes),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalVotes > 0 ? candidate.votes / totalVotes : 0,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${votingProvider.getVotePercentage(candidate).toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              onPressed: hasVoted ? null : () async {
                                await votingProvider.voteGovernor(candidate.id);
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✓ Voted for ${candidate.name}!'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasVoted ? Colors.grey : Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                disabledBackgroundColor: Colors.grey.shade400,
                              ),
                              child: Text(hasVoted ? '✓ Voted' : 'Vote'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        );
      },
    );
  }
}

// ============================================================
// LGA TAB
// ============================================================

class _LGATab extends StatefulWidget {
  const _LGATab();

  @override
  State<_LGATab> createState() => _LGATabState();
}

class _LGATabState extends State<_LGATab> {
  String selectedState = '';
  String selectedLGA = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, _) {
        final states = votingProvider.getGovernorStates();
        final lgas = selectedState.isEmpty ? [] : votingProvider.getLGAsByState(selectedState);
        final candidates = selectedLGA.isEmpty ? [] : votingProvider.getLGACandidatesByLGA(selectedLGA);
        final totalVotes = votingProvider.getTotalVotes(candidates);

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            DropdownButton<String>(
              value: selectedState.isEmpty ? null : selectedState,
              hint: const Text('Select a state'),
              isExpanded: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedState = newValue;
                    selectedLGA = '';
                  });
                }
              },
              items: (states as List<String>)
                  .map<DropdownMenuItem<String>>((String state) {
                return DropdownMenuItem<String>(value: state, child: Text(state));
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (lgas.isNotEmpty) ...[
              DropdownButton<String>(
                value: selectedLGA.isEmpty ? null : selectedLGA,
                hint: const Text('Select LGA'),
                isExpanded: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => selectedLGA = newValue);
                  }
                },
                items: (lgas as List<String>)
                    .map<DropdownMenuItem<String>>((String lga) {
                  return DropdownMenuItem<String>(value: lga, child: Text(lga));
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            if (selectedLGA.isEmpty)
              const Center(child: Text('Select an LGA to see candidates'))
            else ...[
              // Live stats
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Votes', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(votingProvider.formatVotes(totalVotes),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
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
              ),
              const SizedBox(height: 12),
              ...candidates.asMap().entries.map((entry) {
                int idx = entry.key;
                var candidate = entry.value;
                final hasVoted = votingProvider.hasVotedLGA(candidate.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${idx + 1}.', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(candidate.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  Text(candidate.party, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Text(votingProvider.formatVotes(candidate.votes),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalVotes > 0 ? candidate.votes / totalVotes : 0,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${votingProvider.getVotePercentage(candidate).toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              onPressed: hasVoted ? null : () async {
                                await votingProvider.voteLGA(candidate.id);
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✓ Voted for ${candidate.name}!'),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasVoted ? Colors.grey : Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                disabledBackgroundColor: Colors.grey.shade400,
                              ),
                              child: Text(hasVoted ? '✓ Voted' : 'Vote'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        );
      },
    );
  }
}

// ============================================================
// REFORMS TAB
// ============================================================

class _ReformsTab extends StatelessWidget {
  const _ReformsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, _) {
        final reforms = votingProvider.reforms;
        final totalVotes = reforms.fold<int>(0, (sum, r) => sum + r.votes);

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Overall stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Support Votes', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(votingProvider.formatVotes(totalVotes),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
            ),
            const SizedBox(height: 16),
            ...reforms
                .map((reform) {
              final hasVoted = reform.userVoted;
              final percentage = totalVotes > 0 ? (reform.votes / totalVotes) * 100 : 0.0;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and votes
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(reform.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(reform.description,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(votingProvider.formatVotes(reform.votes),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Vote progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalVotes > 0 ? reform.votes / totalVotes : 0,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Implementation progress
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Implementation Progress',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              Text('${reform.progress.toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: reform.progress / 100,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Vote button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: hasVoted
                              ? null
                              : () async {
                                  await votingProvider.voteReform(reform.id);
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('✓ You support this reform: ${reform.title}'),
                                      backgroundColor: Colors.purple,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasVoted ? Colors.grey : Colors.purple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(hasVoted ? '✓ You Support This' : 'Support This Reform'),
                        ),
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
