import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_models.dart';
import '../providers/posts_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _post;
  bool _liked = false;
  bool _disliked = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _incrementViewCount();
  }

  Future<void> _incrementViewCount() async {
    await context.read<PostsProvider>().incrementView(_post.id);
    _refreshPost();
  }

  void _refreshPost() {
    final updatedPost = context.read<PostsProvider>().getAllPosts().firstWhere(
      (p) => p.id == _post.id,
      orElse: () => _post,
    );
    setState(() {
      _post = updatedPost;
    });
  }

  Future<void> _toggleLike() async {
    if (_liked) {
      _liked = false;
    } else {
      _liked = true;
      _disliked = false;
      await context.read<PostsProvider>().likePost(_post.id);
    }
    _refreshPost();
    setState(() {});
  }

  Future<void> _toggleDislike() async {
    if (_disliked) {
      _disliked = false;
    } else {
      _disliked = true;
      _liked = false;
      await context.read<PostsProvider>().dislikePost(_post.id);
    }
    _refreshPost();
    setState(() {});
  }

  void _sharePost() {
    Share.share(
      'Check out: ${_post.title}\n\nRead more in Nigerian News App',
      subject: _post.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(_post.category, style: const TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: _post.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 300,
                color: Colors.grey.shade300,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, size: 80),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_post.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                      ),
                      Text(_post.source, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_post.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(_post.timeAgo, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      const Spacer(),
                      Icon(Icons.visibility, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text('${_post.viewCount} views', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(_post.content, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
                  const SizedBox(height: 32),
                  if (_post.likes + _post.dislikes > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Public Opinion', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: _post.approvalRating / 100,
                                  minHeight: 8,
                                  backgroundColor: Colors.red.shade200,
                                  valueColor: AlwaysStoppedAnimation(Colors.green.shade700),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('${_post.approvalRating.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleLike,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _liked ? Colors.blue : Colors.grey.shade200,
                            foregroundColor: _liked ? Colors.white : Colors.black,
                          ),
                          icon: const Icon(Icons.thumb_up),
                          label: Text('${_post.likes}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleDislike,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _disliked ? Colors.red : Colors.grey.shade200,
                            foregroundColor: _disliked ? Colors.white : Colors.black,
                          ),
                          icon: const Icon(Icons.thumb_down),
                          label: Text('${_post.dislikes}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sharePost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Post> getAllPosts() => context.read<PostsProvider>().getAllPosts();
}
