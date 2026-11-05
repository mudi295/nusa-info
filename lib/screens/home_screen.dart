import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import 'add_post_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _service = PostService();
  late Future<List<Post>> _postsFuture;

  // Pengumuman baru dari form (API palsu tidak menyimpan data sungguhan).
  final List<Post> _newPosts = [];

  @override
  void initState() {
    super.initState();
    _postsFuture = _service.fetchPosts(); // dipanggil di initState, bukan build
  }

  void _reload() {
    setState(() {
      _postsFuture = _service.fetchPosts();
    });
  }

  Future<void> _onRefresh() async {
    _reload();
    try {
      await _postsFuture;
    } catch (_) {
      // error ditampilkan oleh FutureBuilder
    }
  }

  Future<void> _openAddPost() async {
    final result = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => const AddPostScreen()),
    );
    if (result != null && mounted) {
      setState(() => _newPosts.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengumuman berhasil dibuat!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NusaInfo')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPost,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = [..._newPosts, ...?snapshot.data];
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${post.id}')),
                  title: Text(post.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(post.body,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailScreen(post: post)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
