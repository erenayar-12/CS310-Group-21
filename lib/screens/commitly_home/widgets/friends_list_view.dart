import 'package:flutter/material.dart';
import '../../../data/friend.dart';
import '../../../friend_profile_page.dart';


class FriendsListView extends StatelessWidget {
  final List<Friend> friends;

  const FriendsListView({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Friends",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: null, // Only UI needed
                child: Row(
                  children: [
                    Icon(Icons.person_add, size: 16),
                    SizedBox(width: 5),
                    Text("Add Friend"),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),

        // FRIEND CARDS
        ...friends.map((f) => _buildFriendCard(context, f)).toList(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFriendCard(BuildContext context, Friend f) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FriendProfilePage(
            name: f.name,
            level: f.level,
            streak: f.streak,
            topHabit: f.topHabit,
            avatarColor: f.color,
          )),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0,2),
            )
          ],
        ),
        child: Row(
          children: [
            // Avatar circle
            CircleAvatar(
              radius: 25,
              backgroundColor: f.color,
              child: const Icon(Icons.emoji_people, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Row(children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                    Text(" Lvl ${f.level}   "),
                    Icon(Icons.local_fire_department,
                        color: Colors.orange, size: 16),
                    Text(" ${f.streak} days"),
                  ]),
                ],
              ),
            ),

            // Top habit tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                f.topHabit,
                style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
