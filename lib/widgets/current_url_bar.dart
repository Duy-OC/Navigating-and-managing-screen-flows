import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CurrentUrlBar extends StatelessWidget implements PreferredSizeWidget {
  // url: truyền ở màn ngoài go_router (errorBuilder, Navigator.push) vì
  // không có GoRouterState để đọc.
  const CurrentUrlBar({super.key, this.url});

  final String? url;

  @override
  Size get preferredSize => const Size.fromHeight(24);

  @override
  Widget build(BuildContext context) {
    // [NAV] hiện URL hiện tại để demo trên điện thoại (không cần chạy web)
    final text = url ?? GoRouterState.of(context).uri.toString();
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 24,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
