import 'package:flutter/material.dart';

import '../../../shared/ui/placeholder_page.dart';

class CollectionPlaceholderPage extends StatelessWidget {
  const CollectionPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: '收藏',
      message: '收藏功能占位。',
    );
  }
}
