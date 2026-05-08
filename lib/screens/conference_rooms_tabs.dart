import 'package:flutter/material.dart';
import 'conference_rooms_data.dart';

class ConferenceRoomsTabs extends StatelessWidget {
  const ConferenceRoomsTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: demoRooms.length,
      child: Column(
        mainAxisSize: MainAxisSize.min, // 👈 key fix
        children: [
          // ── Tab Bar ──
          Container(
            color: Colors.blue,
            
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              tabs: demoRooms.keys
                  .map((type) => Tab(text: type))
                  .toList(),
            ),
          ),
          // ── Tab Content ──
          SizedBox(
            height: 300, // 👈 fixed height for content area
            child: TabBarView(
              children: demoRooms.entries
                  .map((entry) => _RoomTabContent(rooms: entry.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Each tab content ──
class _RoomTabContent extends StatelessWidget {
  final List<Map<String, String>> rooms;

  const _RoomTabContent({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final links = (room['links'] ?? '')
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room name
                Row(
                  children: [
                    const Icon(Icons.meeting_room_outlined,
                        size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      room['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // Links
                ...links.map((link) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.link,
                              size: 16, color: Colors.black),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              link,
                              style: const TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}