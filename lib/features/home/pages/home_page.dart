import 'package:flutter/material.dart';

import '../../../shared/ui/placeholder_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      eyebrow: '首页 3D 地球选山',
      title: 'BeyondPeaks',
      message: '3D 地球内容将在这里接入。',
    );
  }
}
