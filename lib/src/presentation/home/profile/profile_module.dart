import 'package:flutter/material.dart';

import 'package:coinglass_app/src/presentation/my_profile_tab.dart';

class ProfileModule extends StatelessWidget {
  const ProfileModule({
    super.key,
    required this.onLoginTap,
    required this.onPlaceholderTap,
  });

  final VoidCallback onLoginTap;
  final VoidCallback onPlaceholderTap;

  @override
  Widget build(BuildContext context) {
    return MyProfileTab(
      onLoginTap: onLoginTap,
      onPlaceholderTap: onPlaceholderTap,
    );
  }
}
