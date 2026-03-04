import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/friends/domain/entities/friend.dart';
import 'package:locket/features/friends/domain/entities/friend_request.dart';
import 'package:locket/features/friends/injection.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  List<Friend> _friends = [];
  List<FriendRequest> _incomingRequests = [];
  List<FriendRequest> _outgoingRequests = [];
  bool _isLoading = true;
  bool _showAllFriends = false;
  bool _showAllSuggestions = false;
  bool _showAllOutgoing = false;

  static const _kPreviewCount = 3;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final getFriends = await ref.read(getFriendsUseCaseProvider.future);
      final getIncoming =
          await ref.read(getIncomingRequestsUseCaseProvider.future);
      final getOutgoing =
          await ref.read(getOutgoingRequestsUseCaseProvider.future);
      final results = await Future.wait([
        getFriends.call(),
        getIncoming.call(),
        getOutgoing.call(),
      ]);
      if (mounted) {
        setState(() {
          _friends = results[0] as List<Friend>;
          _incomingRequests = results[1] as List<FriendRequest>;
          _outgoingRequests = results[2] as List<FriendRequest>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUnfriend(Friend friend) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy kết bạn',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Hủy kết bạn với ${friend.name}?',
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy kết bạn',
                style: TextStyle(color: MyColors.danger)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final useCase = await ref.read(removeFriendUseCaseProvider.future);
    await useCase.call(friend.id);
    _loadData();
  }

  Future<void> _handleAccept(FriendRequest req) async {
    final useCase = await ref.read(respondFriendRequestUseCaseProvider.future);
    await useCase.call(req.id, 'accept');
    _loadData();
  }

  Future<void> _handleCancelRequest(FriendRequest req) async {
    final useCase =
        await ref.read(deleteFriendRequestUseCaseProvider.future);
    await useCase.call(req.id);
    _loadData();
  }

  void _copyShareLink() {
    final shareCode = ref.read(profileProvider).value?.shareCode;
    if (shareCode == null || shareCode.isEmpty) return;
    final link = 'locket://app/add-friend/$shareCode';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã copy link!'),
        backgroundColor: MyColors.bgButtonLogin,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    color: MyColors.bgButtonLogin, strokeWidth: 2))
            : RefreshIndicator(
                color: MyColors.bgButtonLogin,
                backgroundColor: const Color(0xFF2C2C2C),
                onRefresh: _loadData,
                child: CustomScrollView(
                  slivers: [
                    // ── AppBar ────────────────────────────────────
                    SliverAppBar(
                      backgroundColor: const Color(0xFF1A1A1A),
                      elevation: 0,
                      pinned: false,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                        onPressed: () => context.pop(),
                      ),
                      title: Column(
                        children: [
                          Text(
                            '${_friends.length} người bạn',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Mời một người bạn để tiếp tục',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      centerTitle: true,
                    ),

                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // ── Search bar ────────────────────────
                          _SearchBar(),

                          const SizedBox(height: 20),

                          // ── Find from other apps ──────────────
                          _FindFromAppsSection(),

                          const SizedBox(height: 20),

                          // ── Divider ───────────────────────────
                          const Divider(
                              color: Color(0xFF2C2C2C), thickness: 1),

                          // ── Bạn bè của bạn ───────────────────
                          if (_friends.isNotEmpty) ...[
                            _buildFriendsSection(),
                            const SizedBox(height: 8),
                            const Divider(
                                color: Color(0xFF2C2C2C), thickness: 1),
                          ],

                          // ── Các đề xuất (incomming requests) ─
                          if (_incomingRequests.isNotEmpty) ...[
                            _buildSuggestionsSection(),
                            const SizedBox(height: 8),
                            const Divider(
                                color: Color(0xFF2C2C2C), thickness: 1),
                          ],

                          // ── Outgoing requests ─────────────────
                          if (_outgoingRequests.isNotEmpty) ...[
                            _buildOutgoingSection(),
                            const SizedBox(height: 8),
                            const Divider(
                                color: Color(0xFF2C2C2C), thickness: 1),
                          ],

                          // ── Share link ────────────────────────
                          _buildShareSection(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Bạn bè của bạn ───────────────────────────────────────────────────────

  Widget _buildFriendsSection() {
    final displayed =
        _showAllFriends ? _friends : _friends.take(_kPreviewCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.group_outlined, label: 'Bạn bè của bạn'),
        ...displayed.map(
          (f) => _FriendTile(
            name: f.name,
            avatar: f.avatar,
            onRemove: () => _handleUnfriend(f),
          ),
        ),
        if (_friends.length > _kPreviewCount)
          _SeeMoreButton(
            shown: _showAllFriends,
            onTap: () => setState(() => _showAllFriends = !_showAllFriends),
          ),
      ],
    );
  }

  // ── Các đề xuất (incoming requests) ──────────────────────────────────────

  Widget _buildSuggestionsSection() {
    final displayed = _showAllSuggestions
        ? _incomingRequests
        : _incomingRequests.take(_kPreviewCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
            icon: Icons.person_add_outlined, label: 'Lời mời kết bạn'),
        ...displayed.map(
          (req) => _SuggestionTile(
            name: req.name,
            avatar: req.avatar,
            subtitle: 'Mời họ tham gia 🐻',
            addLabel: 'Chấp nhận',
            onAdd: () => _handleAccept(req),
          ),
        ),
        if (_incomingRequests.length > _kPreviewCount)
          _SeeMoreButton(
            shown: _showAllSuggestions,
            onTap: () =>
                setState(() => _showAllSuggestions = !_showAllSuggestions),
          ),
      ],
    );
  }

  // ── Add your contacts (outgoing requests) ───────────────────────────────────

  Widget _buildOutgoingSection() {
    final displayed = _showAllOutgoing
        ? _outgoingRequests
        : _outgoingRequests.take(_kPreviewCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
            icon: Icons.contacts_outlined, label: 'Add your contacts'),
        ...displayed.map(
          (req) => _SuggestionTile(
            name: req.name,
            avatar: req.avatar,
            subtitle: 'Đang chờ phản hồi',
            addLabel: 'Thu hồi',
            addColor: const Color(0xFF3A3A3A),
            addTextColor: Colors.white,
            onAdd: () => _handleCancelRequest(req),
          ),
        ),
        if (_outgoingRequests.length > _kPreviewCount)
          _SeeMoreButton(
            shown: _showAllOutgoing,
            onTap: () => setState(() => _showAllOutgoing = !_showAllOutgoing),
          ),
      ],
    );
  }

  // ── Chia sẻ liên kết ─────────────────────────────────────────────────────

  Widget _buildShareSection() {
    final platforms = [
      _SharePlatform(
        icon: Icons.messenger_rounded,
        color: const Color(0xFF0099FF),
        label: 'Messenger',
        onTap: _copyShareLink,
      ),
      _SharePlatform(
        icon: Icons.photo_camera,
        color: const Color(0xFFE1306C),
        label: 'Tin nhắn Instagram',
        onTap: _copyShareLink,
      ),
      _SharePlatform(
        icon: Icons.camera_alt_rounded,
        color: const Color(0xFFF56040),
        label: 'Tin Instagram',
        onTap: _copyShareLink,
      ),
      _SharePlatform(
        icon: Icons.message_rounded,
        color: const Color(0xFF34C759),
        label: 'Tin nhắn',
        onTap: _copyShareLink,
      ),
      _SharePlatform(
        icon: Icons.mood_rounded,
        color: const Color(0xFFFFFC00),
        label: 'Snapchat',
        onTap: _copyShareLink,
      ),
      _SharePlatform(
        icon: Icons.chat_rounded,
        color: const Color(0xFF25D366),
        label: 'WhatsApp',
        onTap: _copyShareLink,
      ),
      _SharePlatform(
        icon: Icons.more_horiz_rounded,
        color: const Color(0xFF3A3A3A),
        label: 'Các ứng dụng khác',
        onTap: _copyShareLink,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              Icon(Icons.link_rounded, color: Colors.grey, size: 16),
              SizedBox(width: 6),
              Text(
                'Chia sẻ liên kết Locket của bạn',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...platforms.map(
          (p) => ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: p.color,
                shape: BoxShape.circle,
              ),
              child: Icon(p.icon, color: Colors.white, size: 18),
            ),
            title: Text(p.label,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
            trailing: const Icon(Icons.chevron_right,
                color: Colors.grey, size: 20),
            onTap: p.onTap,
          ),
        ),
      ],
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // Navigate to add friend by share code
          context.push('/add-friend/');
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              SizedBox(width: 12),
              Icon(Icons.search_rounded, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text(
                'Thêm một người bạn mới',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Find from Other Apps ────────────────────────────────────────────────────

class _FindFromAppsSection extends StatelessWidget {
  const _FindFromAppsSection();

  @override
  Widget build(BuildContext context) {
    final apps = [
      _AppIcon(
        color: const Color(0xFF0099FF),
        icon: Icons.messenger_rounded,
        label: 'Messenger',
      ),
      _AppIcon(
        color: const Color(0xFFE1306C),
        icon: Icons.camera_alt_rounded,
        label: 'Insta',
      ),
      _AppIcon(
        color: const Color(0xFF34C759),
        icon: Icons.message_rounded,
        label: 'Tin nhắn',
      ),
      _AppIcon(
        color: const Color(0xFF3A3A3A),
        icon: Icons.more_horiz_rounded,
        label: 'Khác',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.grey, size: 16),
              SizedBox(width: 6),
              Text(
                'Find friends from other apps',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: apps
                .map((a) => Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: a,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _AppIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  const _AppIcon(
      {required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Friend Tile ──────────────────────────────────────────────────────────────

class _FriendTile extends StatelessWidget {
  final String name;
  final String? avatar;
  final VoidCallback onRemove;
  const _FriendTile(
      {required this.name, this.avatar, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: _Avatar(url: avatar, radius: 22, name: name),
      title: Text(name,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500)),
      trailing: GestureDetector(
        onTap: onRemove,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF3A3A3A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

// ─── Suggestion Tile ──────────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  final String name;
  final String? avatar;
  final String subtitle;
  final String addLabel;
  final Color addColor;
  final Color addTextColor;
  final VoidCallback onAdd;

  const _SuggestionTile({
    required this.name,
    this.avatar,
    required this.subtitle,
    required this.onAdd,
    this.addLabel = '+ Thêm',
    this.addColor = MyColors.bgButtonLogin,
    this.addTextColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: _Avatar(url: avatar, radius: 22, name: name),
      title: Text(name,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: GestureDetector(
        onTap: onAdd,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: addColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            addLabel,
            style: TextStyle(
                color: addTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// ─── See More Button ──────────────────────────────────────────────────────────

class _SeeMoreButton extends StatelessWidget {
  final bool shown;
  final VoidCallback onTap;
  const _SeeMoreButton({required this.shown, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            shown ? 'Thu gọn' : 'Xem thêm',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? url;
  final double radius;
  final String? name;
  const _Avatar({this.url, required this.radius, this.name});

  static const _kPalette = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF4D96FF),
    Color(0xFF6BCB77),
    Color(0xFFFF922B),
    Color(0xFFCC5DE8),
    Color(0xFFFF6B9D),
    Color(0xFF00B4D8),
  ];

  Color get _bg {
    if (name == null || name!.isEmpty) return const Color(0xFF3A3A3A);
    return _kPalette[name!.codeUnitAt(0) % _kPalette.length];
  }

  Widget _initial() {
    final ch = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: _bg,
      child: Text(
        ch,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return _initial();
    return CircleAvatar(
      radius: radius,
      backgroundColor: _bg,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          placeholder: (_, __) => _initial(),
          errorWidget: (_, __, ___) => _initial(),
        ),
      ),
    );
  }
}

// ─── Share Platform ───────────────────────────────────────────────────────────

class _SharePlatform {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _SharePlatform(
      {required this.icon,
      required this.color,
      required this.label,
      required this.onTap});
}
