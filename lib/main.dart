import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = '';

    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('3.2'),
        ),
        body: FutureBuilder<List<Post>>(
          future: fetchPosts(http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Ошибка получения данных'),
              );
            } else if (snapshot.hasData) {
              return MyListView(posts: snapshot.data!);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class MyListView extends StatelessWidget {
  const MyListView({Key? key, required this.posts}) : super(key: key);

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(5),
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        return _MyListItem(post: posts[index]);
      },
    );
  }
}

class _MyListItem extends StatelessWidget {
  const _MyListItem({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          const Icon(Icons.message),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title:',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                Text(
                  'Body:',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  post.body,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: (){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            action: SnackBarAction(
              label: '',
              onPressed: () {},
            ),
            content: Text('Title: ${post.title}'),
            duration: const Duration(milliseconds: 1500),
            width: 280.0, // Width of the SnackBar.
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
      },
    );
  }
}

Future<List<Post>> fetchPosts(http.Client client) async {
  final response =
  await client.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

  return compute(parsePosts, response.body);
}

List<Post> parsePosts(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Post>((json) => Post.fromJson(json)).toList();
}

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}