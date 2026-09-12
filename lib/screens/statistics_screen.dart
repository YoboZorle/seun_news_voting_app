import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('📊 Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<StatsProvider>(
        builder: (context, statsProvider, _) {
          final stats = statsProvider.stats;
          final engagement = statsProvider.engagementByCategory;
          final topPosts = statsProvider.topPosts;

          return RefreshIndicator(
            onRefresh: () async => statsProvider.refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _StatCard(icon: Icons.article, label: 'Total Posts', value: stats.totalPosts.toString(), color: Colors.blue),
                      _StatCard(icon: Icons.visibility, label: 'Total Views', value: stats.totalViews.toString(), color: Colors.green),
                      _StatCard(icon: Icons.how_to_vote, label: 'Total Votes', value: stats.totalVotes.toString(), color: Colors.orange),
                      _StatCard(icon: Icons.trending_up, label: 'Engagement', value: stats.totalEngagements.toString(), color: Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Engagement by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: engagement.isEmpty
                          ? Center(child: Text('No data yet', style: TextStyle(color: Colors.grey.shade600)))
                          : Column(
                              children: engagement.entries.map((e) {
                                final maxValue = engagement.values.isNotEmpty ? engagement.values.reduce((a, b) => a > b ? a : b) : 1;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('${e.value}', style: TextStyle(color: Colors.grey.shade600)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: e.value / maxValue,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey.shade300,
                                          valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Top Posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (topPosts.isEmpty)
                    Center(child: Text('No posts yet', style: TextStyle(color: Colors.grey.shade600)))
                  else
                    ...topPosts.map((post) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 6),
                                    Text('${post.viewCount} views • ${post.likes} likes', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              Icon(Icons.trending_up, color: Colors.green.shade700),
                            ],
                          ),
                        ),
                      ),
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(0.1), color.withOpacity(0.05)])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }
}
