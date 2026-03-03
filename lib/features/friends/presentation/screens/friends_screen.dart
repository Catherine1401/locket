import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/friends/injection.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Data
  List<dynamic> _friends = [];
  List<dynamic> _incomingRequests = [];
  List<dynamic> _outgoingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final getFriends = await ref.read(getFriendsUseCaseProvider.future);
      final getIncoming = await ref.read(getIncomingRequestsUseCaseProvider.future);
      final getOutgoing = await ref.read(getOutgoingRequestsUseCaseProvider.future);

      final friends = await getFriends.call();
      final incoming = await getIncoming.call();
      final outgoing = await getOutgoing.call();

      if (mounted) {
        setState(() {
          _friends = friends; // Friend object or dynamic
          _incomingRequests = incoming;
          _outgoingRequests = outgoing;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAccept(String requestId) async {
    try {
      final respondUseCase = await ref.read(respondFriendRequestUseCaseProvider.future);
      final success = await respondUseCase.call(requestId, 'accept');
      if (success) _loadData();
    } catch (e) {
      // 
    }
  }

  Future<void> _handleReject(String requestId) async {
    try {
      final respondUseCase = await ref.read(respondFriendRequestUseCaseProvider.future);
      final success = await respondUseCase.call(requestId, 'reject');
      if (success) _loadData();
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Bạn bè',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: MyColors.bgButtonLogin,
          labelColor: MyColors.bgButtonLogin,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Bạn bè'),
            Tab(text: 'Lời mời'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MyColors.bgButtonLogin))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(),
                _buildRequestsList(),
              ],
            ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return const Center(
        child: Text(
          'Bạn chưa có bạn bè nào',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        // Handle serialization differences (since getFriends might return Friend object)
        final friend = _friends[index];
        final id = friend.id;
        final name = friend.name ?? friend.displayName ?? 'Người dùng';
        final avatar = friend.avatarUrl ?? friend.avatar;

        return ListTile(
          leading: _buildAvatar(avatar),
          title: Text(name, style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }

  Widget _buildRequestsList() {
    if (_incomingRequests.isEmpty && _outgoingRequests.isEmpty) {
      return const Center(
        child: Text(
          'Không có lời mời nào',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: [
        if (_incomingRequests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('LỜI MỜI KẾT BẠN', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          ..._incomingRequests.map((req) {
            final id = req['id'].toString();
            final name = req['name'] ?? 'Người dùng';
            final avatar = req['avatar'];

            return ListTile(
              leading: _buildAvatar(avatar),
              title: Text(name, style: const TextStyle(color: Colors.white)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => _handleReject(id),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleAccept(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.bgButtonLogin,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Chấp nhận', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
        
        if (_outgoingRequests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('ĐÃ GỬI', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          ..._outgoingRequests.map((req) {
            final name = req['name'] ?? 'Người dùng';
            final avatar = req['avatar'];

            return ListTile(
              leading: _buildAvatar(avatar),
              title: Text(name, style: const TextStyle(color: Colors.white)),
              trailing: const Text(
                'Đã gửi yêu cầu',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildAvatar(String? url) {
    return CircleAvatar(
      backgroundColor: Colors.grey[800],
      radius: 24,
      backgroundImage: url != null ? CachedNetworkImageProvider(url) : null,
      child: url == null ? const Icon(Icons.person, color: Colors.white) : null,
    );
  }
}
