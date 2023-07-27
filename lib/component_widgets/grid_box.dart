import 'package:flutter/material.dart';

import '/data/user_post.dart';

class GridBox {
  static List<Widget> loadingListContainer() {
    return const [
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple),
      ColoredBox(color: Colors.deepPurple)
    ];
  }

  static Widget loadingContainer() {
    return const ColoredBox(color: Colors.deepPurple);
  }

  static Widget errorContainer() {
    return const ColoredBox(
      color: Color.fromRGBO(147, 120, 169, 1.0),
      child: Center(
        child: Icon(Icons.error),
      ),
    );
  }

  static Widget getPostsImages(String url) {
 //   print('URL is :$url');
    return Image.network(
      url,
      fit: BoxFit.fill,
      errorBuilder: (_, wid, chunk) => errorContainer(),
    );
  }
}
