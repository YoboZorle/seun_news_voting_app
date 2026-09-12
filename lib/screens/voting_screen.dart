import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/voting_provider.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({Key? key}) : super(key: key);

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('🗳️ Public Opinion', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(icon: Icon(Icons.policy), text: 'Reforms'),
            Tab(icon: Icon(Icons.person), text: 'Contestants'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_ReformsTab(), _ContestantsTab()],
      ),
    );
  }
}

class _ReformsTab extends StatelessWidget {
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
                Icon(Icons.ballot, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No reforms available', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reforms.length,
          itemBuilder: (context, index) => _ReformCard(reform: reforms[index]),
        );
      },
    );
  }
}

class _ReformCard extends StatelessWidget {
  final PoliticalReform reform;
  const _ReformCard({required this.reform});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reform.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(reform.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            const SizedBox(height: 16),
            _VoteBar(label: 'Support', count: reform.supportVotes, percentage: reform.supportPercentage, color: Colors.green),
            const SizedBox(height: 12),
            _VoteBar(label: 'Oppose', count: reform.opposeVotes, percentage: reform.opposePercentage, color: Colors.red),
            const SizedBox(height: 12),
            _VoteBar(label: 'Neutral', count: reform.neutralVotes, percentage: reform.neutralPercentage, color: Colors.orange),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<VotingProvider>().voteReformSupport(reform.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote recorded!')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Support'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<VotingProvider>().voteReformOppose(reform.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote recorded!')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    icon: const Icon(Icons.thumb_down),
                    label: const Text('Oppose'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<VotingProvider>().voteReformNeutral(reform.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote recorded!')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
                    child: const Text('Neutral'),
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

class _ContestantsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, _) {
        final contestants = votingProvider.contestants;
        if (contestants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No contestants available', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contestants.length,
          itemBuilder: (context, index) => _ContestantCard(contestant: contestants[index]),
        );
      },
    );
  }
}

class _ContestantCard extends StatelessWidget {
  final PoliticalContestant contestant;
  const _ContestantCard({required this.contestant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade100),
                  child: Icon(Icons.person, size: 32, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contestant.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${contestant.party} • ${contestant.position}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _VoteBar(label: 'Support', count: contestant.supportVotes, percentage: contestant.supportPercentage, color: Colors.green),
            const SizedBox(height: 12),
            _VoteBar(label: 'Oppose', count: contestant.opposeVotes, percentage: contestant.opposePercentage, color: Colors.red),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<VotingProvider>().voteContestantSupport(contestant.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote recorded!')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Support'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<VotingProvider>().voteContestantOppose(contestant.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote recorded!')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    icon: const Icon(Icons.thumb_down),
                    label: const Text('Oppose'),
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
  final int count;
  final double percentage;
  final Color color;

  const _VoteBar({required this.label, required this.count, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('${percentage.toStringAsFixed(1)}% ($count votes)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
