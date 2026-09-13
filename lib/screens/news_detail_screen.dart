import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';

class NewsDetailScreen extends StatefulWidget {
  final News news;

  const NewsDetailScreen({Key? key, required this.news}) : super(key: key);

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late News currentNews;
  bool liked = false;

  @override
  void initState() {
    super.initState();
    currentNews = widget.news;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.categoryColors[currentNews.category] ?? AppTheme.primaryOrange,
        elevation: 0,
        title: Text(
          '${AppTheme.categoryEmojis[currentNews.category]} ${currentNews.category.toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            ClipRect(
              child: Image.network(
                currentNews.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 60),
                  );
                },
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    currentNews.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 12),

                  // Meta info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.categoryColors[currentNews.category]?.withOpacity(0.1) ??
                          Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.source, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          currentNews.source,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          currentNews.timeAgo,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Content
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Story',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getExpandedContent(),
                          style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Engagement Stats
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
                        const Text(
                          'Engagement Metrics',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _StatItem('Views', '${currentNews.viewCount}', Icons.visibility),
                        _StatItem('Likes', '${currentNews.likes}', Icons.thumb_up),
                        _StatItem('Dislikes', '${currentNews.dislikes}', Icons.thumb_down),
                        _StatItem('Shares', '${currentNews.shares}', Icons.share),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trending Score
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade100, Colors.orange.shade100],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Trending Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(
                              '${currentNews.trendingScore.toStringAsFixed(1)}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Engagement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(
                              '${currentNews.engagementRate.toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<NewsProvider>(
        builder: (context, newsProvider, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await newsProvider.likeNews(currentNews.id);
                      setState(() => liked = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: liked ? Colors.blue : Colors.white,
                      foregroundColor: liked ? Colors.white : Colors.blue,
                      side: BorderSide(color: Colors.blue, width: liked ? 0 : 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(liked ? Icons.favorite : Icons.favorite_outline),
                        const SizedBox(width: 6),
                        const Text('Like'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await newsProvider.shareNews(currentNews.id);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Shared!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 6),
                        Text('Share'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getExpandedContent() {
    return '${currentNews.content}\n\n'
        'This is a developing story from ${currentNews.source}. '
        'Our reporters are actively covering this story and will provide updates as new information becomes available.\n\n'
        'Key Details:\n'
        '• Source: ${currentNews.source}\n'
        '• Category: ${currentNews.category.toUpperCase()}\n'
        '• Posted: ${currentNews.timeAgo}\n'
        '• Engagement: ${currentNews.engagementRate.toStringAsFixed(1)}% of viewers are engaged\n\n'
        'Stay tuned for more updates on this story.';
  }

  Widget _StatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
