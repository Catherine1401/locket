import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/friends/injection.dart';
import 'package:locket/features/moments/domain/entities/moment_page.dart';
import 'package:locket/features/moments/presentation/riverpod/moment_feed_provider.dart';
import 'package:locket/features/moments/presentation/screens/feed_screen.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gridState = ref.watch(gridProvider);
    final friends = ref.watch(friendsListProvider).value ?? [];
    final myAvatarUrl = ref.watch(profileProvider).value?.avatarUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ─────────────────────────────────────────────
            FeedTopBar(
              filterUserId: gridState.filterUserId,
              friends: friends,
              myAvatarUrl: myAvatarUrl,
              onFilterChanged: (userId) =>
                  ref.read(gridProvider.notifier).setFilter(userId),
            ),

            // ── Grid ─────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  gridState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: MyColors.bgButtonLogin, strokeWidth: 2))
                      : gridState.moments.isEmpty
                          ? const Center(
                              child: Text('Chưa có khoảnh khắc nào',
                                  style: TextStyle(color: Colors.white60)))
                          : NotificationListener<ScrollNotification>(
                              onNotification: (n) {
                                if (n is ScrollEndNotification) {
                                  if (_scrollController.position.maxScrollExtent > 0 && 
                                      _scrollController.position.pixels >=
                                          _scrollController.position.maxScrollExtent -
                                              300) {
                                    ref.read(gridProvider.notifier).loadMore();
                                  }
                                } else if (n is OverscrollNotification) {
                                  if (n.overscroll < -10 || n.overscroll > 10) {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                }
                                return false;
                              },
                              child: GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics()),
                                controller: _scrollController,
                                padding: const EdgeInsets.only(top: 10, bottom: 100), // Không padding 2 bên, nhường chỗ cho nút ở đáy
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
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

                  // ── Floating Camera Nav ────────────────────────────────
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 48 + 32), // Cân bằng không gian với nút phải
                        // Nút camera giữa
                        GestureDetector(
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const FeedScreen()),
                              );
                            }
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              border: Border.all(
                                  color: MyColors.bgButtonLogin, width: 4),
                            ),
                            child: Center(
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black26, 
                                ),
                                child: Center(
                                  child: Container(
                                    width: 44,
                                    height: 44,
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
                        const SizedBox(width: 32),
                        // Nút video phụ bên phải
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.video_collection_rounded,
                              color: Colors.white70, size: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFeedAt(BuildContext context, GridMoment item) {
    ref.read(momentFeedProvider.notifier).loadInitial(initialMomentId: item.id);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => FeedScreen(initialMomentId: item.id)),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // Ảnh bo tròn đẹp theo UI
        child: item.thumbnail != null
            ? CachedNetworkImage(
                imageUrl: item.thumbnail!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const ColoredBox(color: Color(0xFF1E1E1E)),
                errorWidget: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF1E1E1E)),
              )
            : const ColoredBox(
                color: Color(0xFF1E1E1E),
                child: Icon(Icons.image_not_supported_outlined,
                    color: Colors.white38, size: 24),
              ),
      ),
    );
  }
}

