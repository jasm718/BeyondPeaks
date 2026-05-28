import 'package:flutter/material.dart';

enum AppTab {
  home(
    path: '/home',
    label: '首页',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  climb(
    path: '/climb',
    label: '攀爬',
    icon: Icons.terrain,
    selectedIcon: Icons.terrain,
  ),
  collection(
    path: '/collection',
    label: '收藏',
    icon: Icons.bookmark_border,
    selectedIcon: Icons.bookmark,
  ),
  settings(
    path: '/settings',
    label: '设置',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  );

  const AppTab({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  static AppTab fromPath(String path) {
    return switch (path) {
      '/home' => AppTab.home,
      '/climb' => AppTab.climb,
      '/collection' => AppTab.collection,
      '/settings' => AppTab.settings,
      _ => throw StateError('Unsupported app path: $path'),
    };
  }
}
