import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/post.dart';

class PostServiceException implements Exception {
  final String message;
  const PostServiceException(this.message);

  @override
  String toString() => message;
}

class PostService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration _timeout = Duration(seconds: 10);

  /// GET /posts
  Future<List<Post>> fetchPosts() async {
    // 1. Buat alamat
    final uri = Uri.parse('$_baseUrl/posts');
    // 2. Kirim request
    final response = await _send(() => http.get(uri));
    // 3. Cek status code
    _checkStatus(response, 200);
    // 4. Ubah JSON menjadi objek
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /posts/{id}/comments
  Future<List<Comment>> fetchComments(int postId) async {
    final uri = Uri.parse('$_baseUrl/posts/$postId/comments');
    final response = await _send(() => http.get(uri));
    _checkStatus(response, 200);
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /posts
  Future<Post> createPost({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl/posts');
    final response = await _send(
      () => http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'title': title, 'body': body, 'userId': userId}),
      ),
    );
    _checkStatus(response, 201);
    return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ---- helper ----

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on SocketException {
      throw const PostServiceException(
          'Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException {
      throw const PostServiceException(
          'Koneksi terlalu lama. Silakan coba lagi.');
    } on http.ClientException {
      throw const PostServiceException(
          'Tidak ada koneksi internet. Periksa jaringan Anda.');
    }
  }

  void _checkStatus(http.Response response, int expected) {
    if (response.statusCode != expected) {
      throw PostServiceException(
          'Server bermasalah (kode ${response.statusCode}).');
    }
  }
}
