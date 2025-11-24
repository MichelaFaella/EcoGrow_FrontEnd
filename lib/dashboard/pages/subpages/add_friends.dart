import 'package:flutter/material.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/toast.dart';
import '../service/user_service.dart';

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  String shortId = "";
  List<Map<String, dynamic>> friends = [];
  bool loading = true;

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  // ==========================================================
  // CARICA AMICI DAL BACKEND
  // ==========================================================
  Future<void> _loadFriends() async {
    final userService = UserService();
    final (ok, error, id, list) = await userService.getFriendshipSummary();

    if (!mounted) return;

    if (!ok || id == null || list == null) {
      setState(() => loading = false);
      showToastWrong(context, error ?? "Unable to load friends");
      return;
    }

    final parsed = list.map<Map<String, dynamic>>((f) {
      final fname = f["first_name"] ?? "";
      final lname = f["last_name"] ?? "";
      final fullName = "$fname $lname".trim();

      return {
        "friendship_id": f["friendship_id"]?.toString() ?? "",
        "name": fullName.isEmpty ? "Unknown" : fullName,
        "avatar": "images/user.png",
      };
    }).toList();

    setState(() {
      shortId = id;
      friends = parsed;
      loading = false;
    });

    showToastCorrect(context, "Friends loaded!");
  }

  // ==========================================================
  // AGGIUNGE AMICO
  // ==========================================================
  Future<void> _addFriend() async {
    final input = searchCtrl.text.trim();

    if (input.isEmpty) {
      showToastInfo(context, "Enter a short ID");
      return;
    }

    final userService = UserService();
    final (ok, error) = await userService.addFriendByShortId(input);

    if (!mounted) return;

    if (ok) {
      showToastCorrect(context, "Friend added!");
      searchCtrl.clear();
      setState(() => loading = true);
      await _loadFriends();
    } else {
      showToastWrong(context, error ?? "Error adding friend");
    }
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // HEADER
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: AppColors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      shortId.isEmpty ? "Loading..." : "Your id: $shortId",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 30),

            // SEARCH BAR
            Container(
              width: 300,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: AppColors.dark_gray),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _addFriend(),
                      decoration: const InputDecoration(
                        hintText: 'Add a new friend...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 15),
                      cursorWidth: 0,
                      showCursor: false,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),

            // LISTA AMICI
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
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
                    "No friends yet",
                    style: TextStyle(
                      color: AppColors.dark_gray,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                )
                    : ListView.separated(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10),
                  itemCount: friends.length,
                      separatorBuilder: (_, __) => const Divider(
                          color: AppColors.light_gray, height: 1),
                      itemBuilder: (context, index) {
                        final friend = friends[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 55,
                              height: 55,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle),
                              child: ClipOval(
                                child: Image.asset(
                                  friend["avatar"],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Nome
                            Expanded(
                              child: Text(
                                friend["name"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            // DELETE → CHIAMA API REALE
                            GestureDetector(
                              onTap: () async {
                                final dynamic rawId = friend["friendship_id"];
                                final String fid = rawId?.toString() ?? "";

                                if (fid.isEmpty) {
                                  showToastWrong(context, "Missing friendship ID");
                                  return;
                                }

                                final bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      backgroundColor: AppColors.white,
                                      elevation: 12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      title: const Row(
                                        children: [
                                          Text(
                                            "Are you sure?",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.black,
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),

                                      content: const Text(
                                        "This action will remove all the plants that you share with your friend.",
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                        ),
                                      ),

                                      actionsPadding: const EdgeInsets.only(right: 15, bottom: 10),
                                      actions: [
                                        // CANCEL
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: AppColors.black,
                                              fontFamily: 'Poppins',
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),

                                        // DELETE
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: AppColors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          ),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );


                                if (confirm != true) return; // annullato

                                final userService = UserService();
                                final result = await userService.deleteFriendship(fid);
                                final bool ok = result.$1;
                                final String? error = result.$2;

                                if (!mounted) return;

                                if (ok) {
                                  showToastCorrect(context, "Friend removed!");
                                  setState(() => loading = true);
                                  await _loadFriends();
                                } else {
                                  showToastWrong(context, error ?? "Error deleting friend");
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.delete,
                                  size: 30,
                                  color: AppColors.red,
                                ),
                              ),
                            )
                          ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
