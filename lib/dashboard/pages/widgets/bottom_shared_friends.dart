import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/toast.dart';
import '../service/user_service.dart';

class SelectFriendForSharingSheet extends StatefulWidget {
  const SelectFriendForSharingSheet({super.key});

  @override
  State<SelectFriendForSharingSheet> createState() =>
      _SelectFriendForSharingSheetState();
}

class _SelectFriendForSharingSheetState
    extends State<SelectFriendForSharingSheet> {
  List<Map<String, dynamic>> friends = [];
  String? selectedShortId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final service = UserService();
    final (ok, msg, _, list) = await service.getFriendshipSummary();

    if (!mounted) return;

    if (!ok || list == null) {
      showToastWrong(context, msg ?? "Error loading friends");
      setState(() => loading = false);
      return;
    }

    setState(() {
      friends = list.map((f) {
        final fname = f["first_name"] ?? "";
        final lname = f["last_name"] ?? "";
        return {
          "short_id": f["short_id"]?.toString() ?? "",
          "name": "$fname $lname".trim(),
          "avatar": "images/user.png",
        };
      }).toList();

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          // HANDLE
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Add a new friend...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Poppins',
            ),
          ),

          const SizedBox(height: 25),

          // MAIN LIST
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: loading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.green,
                ),
              )
                  : friends.isEmpty
                  ? const Center(
                child: Text(
                  "No friends found",
                  style: TextStyle(
                    color: AppColors.dark_gray,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 15),
                itemCount: friends.length,
                separatorBuilder: (_, __) =>
                const Divider(color: AppColors.light_gray),
                itemBuilder: (_, i) {
                  final f = friends[i];
                  final isSelected =
                      selectedShortId == f["short_id"];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedShortId = f["short_id"];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      child: Row(
                        children: [
                          // Avatar
                          ClipOval(
                            child: Image.asset(
                              f["avatar"],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Name
                          Expanded(
                            child: Text(
                              f["name"],
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),

                          // Checkbox
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.green
                                    : AppColors.dark_gray,
                                width: 2,
                              ),
                              color: isSelected
                                  ? AppColors.green
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                size: 18, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 15),

          // CONFIRM BUTTON
          GestureDetector(
            onTap: () {
              if (selectedShortId == null) {
                showToastInfo(context, "Select a friend first");
                return;
              }
              Navigator.pop(context, selectedShortId);
            },
            child: Container(
              width: 200,
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  "CONFIRM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
