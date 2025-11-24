import 'package:flutter/material.dart';

import '../../../utility/app_colors.dart';
import '../models/friend.dart';

class FriendsList extends StatefulWidget {
  final List<Friend> friends;

  const FriendsList({super.key, required this.friends});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.friends.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final friend = widget.friends[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(friend.avatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    friend.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                    ),
                  ),
                ),
                Checkbox(
                  value: friend.selected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (value) {
                    setState(() {
                      friend.selected = value!;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
