import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/voting_provider.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({Key? key}) : super(key: key);

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen>
    with TickerProviderStateMixin {
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
        title: const Text('🇳🇬 2027 Nigerian Elections',
            style: TextStyle(fontWeight: FontWeight.bold)),
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

// PRESIDENTIAL VOTING TAB
class _PresidentialTab extends StatelessWidget {
  const _PresidentialTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, _) {
        final candidates = votingProvider.presidentialCandidates;

        if (candidates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No candidates available',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        final totalVotes = candidates.fold<int>(
            0, (int sum, c) => (sum + c.votes) as int);
        final topCandidate = candidates.isNotEmpty
            ? candidates.reduce((a, b) => a.votes > b.votes ? a : b)
            : null;

        return RefreshIndicator(
          onRefresh: () async => votingProvider.refreshData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2027 PRESIDENTIAL ELECTIONS',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text('Vote for your preferred candidate',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total Votes: ${_formatNumber(totalVotes)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...candidates.map((candidate) {
                final isLeading = candidate.id == topCandidate?.id;
                return _PresidentialCandidateCard(
                  candidate: candidate,
                  isLeading: isLeading,
                  totalVotes: totalVotes,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _PresidentialCandidateCard extends StatelessWidget {
  final PresidentialCandidate candidate;
  final bool isLeading;
  final int totalVotes;

  const _PresidentialCandidateCard({
    required this.candidate,
    required this.isLeading,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
    totalVotes > 0 ? (candidate.votes / totalVotes) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLeading ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage:
                  NetworkImage(candidate.imageUrl),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(candidate.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(candidate.party,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (isLeading)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('LEADING',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                  Colors.blue.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatNumber(candidate.votes)} votes',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<VotingProvider>()
                      .votePresidential(candidate.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '✅ Voted for ${candidate.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700),
                child: const Text('Vote',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// GOVERNORS VOTING TAB
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
        final candidates = selectedState.isEmpty
            ? []
            : votingProvider.getGovernorCandidatesByState(selectedState);
        final totalVotes = candidates.fold<int>(
            0, (int sum, c) => (sum + c.votes) as int);

        return RefreshIndicator(
          onRefresh: () async => votingProvider.refreshData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade700,
                      Colors.green.shade900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2027 GOVERNORSHIP ELECTIONS',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text('Vote for your preferred governor',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select State',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedState.isEmpty ? null : selectedState,
                  hint: const Text('Select a state'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => selectedState = newValue);
                    }
                  },
                  items: states.map((String state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList() as List<DropdownMenuItem<String>>,
                ),
              ),
              const SizedBox(height: 16),
              if (selectedState.isEmpty)
                Center(
                  child: Text('Select a state to see candidates',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else if (candidates.isEmpty)
                Center(
                  child: Text('No candidates available for $selectedState',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else ...[
                  Text('Total Votes: ${_formatNumber(totalVotes)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ...candidates.map((candidate) =>
                      _GovernorCandidateCard(
                        candidate: candidate,
                        totalVotes: totalVotes,
                      )),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _GovernorCandidateCard extends StatelessWidget {
  final GovernorCandidate candidate;
  final int totalVotes;

  const _GovernorCandidateCard({
    required this.candidate,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
    totalVotes > 0 ? (candidate.votes / totalVotes) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(candidate.name[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(candidate.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${candidate.party} - ${candidate.state}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                  Colors.green.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatNumber(candidate.votes)} votes (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                  fontSize: 12, color: Colors.green.shade700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<VotingProvider>()
                      .voteGovernor(candidate.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '✅ Voted for ${candidate.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700),
                child: const Text('Vote',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// LGA VOTING TAB
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
        final states = votingProvider.getLGAStates();
        final lgas = selectedState.isEmpty
            ? []
            : votingProvider.getLGAsByState(selectedState);
        final candidates = selectedLGA.isEmpty
            ? []
            : votingProvider.getLGACandidatesByLGA(selectedLGA);
        final totalVotes = candidates.fold<int>(
            0, (int sum, c) => (sum + c.votes) as int);

        return RefreshIndicator(
          onRefresh: () async => votingProvider.refreshData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade700,
                      Colors.orange.shade900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2027 LOCAL GOVERNMENT ELECTIONS',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text('Vote for your preferred LGA representative',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select State',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedState.isEmpty ? null : selectedState,
                  hint: const Text('Select a state'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedState = newValue;
                        selectedLGA = '';
                      });
                    }
                  },
                  items: states.map((String state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList() as List<DropdownMenuItem<String>>,
                ),
              ),
              const SizedBox(height: 16),
              if (lgas.isNotEmpty) ...[
                const Text('Select Local Government',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedLGA.isEmpty ? null : selectedLGA,
                    hint: const Text('Select LGA'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => selectedLGA = newValue);
                      }
                    },
                    items: states.map((String state) {
                      return DropdownMenuItem<String>(value: state, child: Text(state));
                    }).toList() as List<DropdownMenuItem<String>>,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (selectedLGA.isEmpty)
                Center(
                  child: Text('Select an LGA to see candidates',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else if (candidates.isEmpty)
                Center(
                  child: Text('No candidates available for $selectedLGA',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else ...[
                  Text('Total Votes: ${_formatNumber(totalVotes)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ...candidates.map((candidate) =>
                      _LGACandidateCard(
                        candidate: candidate,
                        totalVotes: totalVotes,
                      )),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _LGACandidateCard extends StatelessWidget {
  final LGACandidate candidate;
  final int totalVotes;

  const _LGACandidateCard({
    required this.candidate,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
    totalVotes > 0 ? (candidate.votes / totalVotes) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(candidate.name[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(candidate.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${candidate.party} - ${candidate.lga}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                  Colors.orange.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatNumber(candidate.votes)} votes (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                  fontSize: 12, color: Colors.orange.shade700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<VotingProvider>()
                      .voteLGA(candidate.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '✅ Voted for ${candidate.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700),
                child: const Text('Vote',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// REFORMS VOTING TAB
class _ReformsTab extends StatelessWidget {
  const _ReformsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, _) {
        final reforms = votingProvider.reforms;

        if (reforms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No reforms available',
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => votingProvider.refreshData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade700,
                      Colors.purple.shade900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('POLITICAL REFORMS VOTING',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text('Vote on proposed national reforms',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...reforms.map((reform) => _ReformCard(reform: reform)),
            ],
          ),
        );
      },
    );
  }
}

class _ReformCard extends StatelessWidget {
  final Reform reform;

  const _ReformCard({required this.reform});

  @override
  Widget build(BuildContext context) {
    final supportVotes =
        reform.supportVotes ?? 0;
    final opposeVotes = reform.opposeVotes ?? 0;
    final neutralVotes = reform.neutralVotes ?? 0;
    final total =
        supportVotes + opposeVotes + neutralVotes;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reform.title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(reform.description,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            _VoteBar(
              label: 'Support',
              votes: supportVotes,
              total: total,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _VoteBar(
              label: 'Oppose',
              votes: opposeVotes,
              total: total,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            _VoteBar(
              label: 'Neutral',
              votes: neutralVotes,
              total: total,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<VotingProvider>()
                          .voteReformSupport(reform.id);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text('✅ Voted Support'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Support'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.green.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<VotingProvider>()
                          .voteReformOppose(reform.id);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text('✅ Voted Oppose'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.thumb_down),
                    label: const Text('Oppose'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.red.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<VotingProvider>()
                          .voteReformNeutral(reform.id);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text('✅ Voted Neutral'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.drag_handle),
                    label: const Text('Neutral'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteBar extends StatelessWidget {
  final String label;
  final int votes;
  final int total;
  final Color color;

  const _VoteBar({
    required this.label,
    required this.votes,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (votes / total) * 100 : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor:
              AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            '${percentage.toStringAsFixed(1)}% (${_formatNumber(votes)})',
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// HELPER FUNCTION
String _formatNumber(int number) {
  return number.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
  );
}