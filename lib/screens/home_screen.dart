import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> categories = ['all', 'politics', 'finance', 'tech', 'entertainment', 'sports', 'health'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
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
        title: const Text('🇳🇬 NaijaNews & Views'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryOrange,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((category) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppTheme.categoryEmojis[category] ?? '📰', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    category[0].toUpperCase() + category.substring(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          return _NewsCategoryList(category: category);
        }).toList(),
      ),
    );
  }
}

class _NewsCategoryList extends StatelessWidget {
  final String category;

  const _NewsCategoryList({required this.category});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, _) {
        final newsList = category == 'all'
            ? newsProvider.getAllNews()
            : newsProvider.getCategoryNews(category);

        if (newsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.newspaper_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No news yet', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => newsProvider.refreshNews(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              return NewsCard(news: newsList[index], newsProvider: newsProvider);
            },
          ),
        );
      },
    );
  }
}

class NewsCard extends StatelessWidget {
  final News news;
  final NewsProvider newsProvider;

  const NewsCard({
    Key? key,
    required this.news,
    required this.newsProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.network(
                  news.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              // Category badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.categoryColors[news.category] ?? AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${AppTheme.categoryEmojis[news.category]} ${news.category.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Time badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    news.timeAgo,
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  news.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Content preview
                Text(
                  news.content,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Source
                Text(
                  news.source,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                // Engagement metrics
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _EngagementStat(icon: Icons.thumb_up_outlined, count: news.likes, color: Colors.blue, label: 'Likes'),
                      _EngagementStat(icon: Icons.thumb_down_outlined, count: news.dislikes, color: Colors.red, label: 'Dislikes'),
                      _EngagementStat(icon: Icons.share_outlined, count: news.shares, color: Colors.green, label: 'Shares'),
                      _EngagementStat(icon: Icons.visibility_outlined, count: news.viewCount, color: Colors.purple, label: 'Views'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.categoryColors[news.category] ?? AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Read', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => newsProvider.likeNews(news.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Icon(Icons.thumb_up, size: 16),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => newsProvider.shareNews(news.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Icon(Icons.share, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EngagementStat extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final String label;

  const _EngagementStat({
    required this.icon,
    required this.count,
    required this.color,
    required this.label,
  });

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(_formatCount(count), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
      ],
    );
  }
}
