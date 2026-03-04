import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/moments/domain/entities/moment_page.dart';
import 'package:locket/features/moments/presentation/riverpod/moment_feed_provider.dart';
import 'package:locket/features/moments/presentation/screens/feed_screen.dart';

class GridScreen extends ConsumerStatefulWidget {
  const GridScreen({super.key});

  @override
  ConsumerState<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends ConsumerState<GridScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(gridProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridState = ref.watch(gridProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 44),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Mọi người',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // ── Grid ─────────────────────────────────────────────────
            Expanded(
              child: gridState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: MyColors.bgButtonLogin, strokeWidth: 2))
                  : gridState.moments.isEmpty
                      ? const Center(
                          child: Text('Chưa có khoảnh khắc nào',
                              style: TextStyle(color: Colors.white60)))
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(2),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: 1,
                          ),
                          itemCount: gridState.moments.length,
                          itemBuilder: (context, index) {
                            final item = gridState.moments[index];
                            return _GridTile(
                              item: item,
                              onTap: () => _openFeedAt(context, item),
                            );
                          },
                        ),
            ),

            if (gridState.isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                    color: MyColors.bgButtonLogin, strokeWidth: 2),
              ),

            // ── Bottom Nav ─────────────────────────────────────────
            _GridBottomNav(
              onFeedTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const FeedScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFeedAt(BuildContext context, GridMoment item) {
    // Invalidate feed provider để force reload từ moment này
    ref.invalidate(momentFeedProvider);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FeedScreen()),
    );
  }
}

// ── Grid Tile ─────────────────────────────────────────────────────────────────

class _GridTile extends StatelessWidget {
  final GridMoment item;
  final VoidCallback onTap;
  const _GridTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: item.thumbnail != null
          ? CachedNetworkImage(
              imageUrl: item.thumbnail!,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const ColoredBox(color: Colors.black26),
              errorWidget: (_, __, ___) =>
                  const ColoredBox(color: Colors.black12),
            )
          : const ColoredBox(
              color: Colors.black26,
              child: Icon(Icons.image_not_supported_outlined,
                  color: Colors.white38, size: 24),
            ),
    );
  }
}

// ── Bottom Nav ─────────────────────────────────────────────────────────────────

class _GridBottomNav extends StatelessWidget {
  final VoidCallback? onFeedTap;
  const _GridBottomNav({this.onFeedTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Grid icon (active)
          GestureDetector(
            onTap: null,
            child: const Icon(Icons.grid_view_rounded,
                color: Colors.white, size: 28),
          ),

          // Camera button → back/feed
          GestureDetector(
            onTap: onFeedTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: MyColors.bgButtonLogin, width: 3),
              ),
              child: Center(
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Share icon
          const Icon(Icons.ios_share, color: Colors.white54, size: 26),
        ],
      ),
    );
  }
}
