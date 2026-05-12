// import 'package:flutter/material.dart';
// import 'conference_rooms_data.dart';

// class ConferenceRoomsCard extends StatefulWidget {
//   const ConferenceRoomsCard({super.key});

//   @override
//   State<ConferenceRoomsCard> createState() => _ConferenceRoomsCardState();
// }

// class _ConferenceRoomsCardState extends State<ConferenceRoomsCard> {
//   int _current = 0;
//   final List<String> _halls = demoRooms.keys.toList();

//   void _navigate(int dir) {
//     setState(() {
//       _current = (_current + dir).clamp(0, _halls.length - 1);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hall = _halls[_current];
//     final rooms = demoRooms[hall]!;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Header with nav arrows ──
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               onPressed: _current > 0 ? () => _navigate(-1) : null,
//               icon: const Icon(Icons.arrow_back_ios_new_rounded),
//             ),
//             Column(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 25, 122, 201),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     hall,
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text('${_current + 1} of ${_halls.length}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//               ],
//             ),
//             IconButton(
//               onPressed:
//                   _current < _halls.length - 1 ? () => _navigate(1) : null,
//               icon: const Icon(Icons.arrow_forward_ios_rounded),
//             ),
//           ],
//         ),

//         const SizedBox(height: 8),

//         // ── Room cards ──
//         ...rooms.map((room) {
//           final links = (room['links'] ?? '')
//               .split('\n')
//               .map((l) => l.trim())
//               .where((l) => l.isNotEmpty)
//               .toList();

//           return Card(
//             margin: const EdgeInsets.only(bottom: 10),
//             elevation: 2,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             child: Padding(
//               padding: const EdgeInsets.all(14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     const Icon(Icons.meeting_room_outlined, size: 18),
//                     const SizedBox(width: 8),
//                     Text(room['name'] ?? '',
//                         style: const TextStyle(
//                             fontSize: 15, fontWeight: FontWeight.bold)),
//                   ]),
//                   const Divider(height: 16),
//                   ...links.map((link) => Row(children: [
//                         const Icon(Icons.link, size: 16, color: Colors.blue),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(link,
//                               style: const TextStyle(
//                                   color: Colors.blue,
//                                   decoration: TextDecoration.underline,
//                                   fontSize: 13),
//                               overflow: TextOverflow.ellipsis),
//                         ),
//                       ])),
//                 ],
//               ),
//             ),
//           );
//         }),

//         const SizedBox(height: 8),

//         // ── Dot indicators ──
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(
//             _halls.length,
//             (i) => GestureDetector(
//               onTap: () => setState(() => _current = i),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 margin: const EdgeInsets.symmetric(horizontal: 4),
//                 width: 8,
//                 height: 8,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: i == _current ? Colors.blue : Colors.grey[400],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ConferenceRoomsCard extends StatefulWidget {
  const ConferenceRoomsCard({super.key});

  @override
  State<ConferenceRoomsCard> createState() => _ConferenceRoomsCardState();
}

class _ConferenceRoomsCardState extends State<ConferenceRoomsCard> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAllConferenceRooms());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();

    if (prov.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.error != null) {
      return Center(child: Text(prov.error!));
    }

    // Group rooms by type
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final room in prov.allConferenceRooms) {
      final type = room['type']?.toString() ?? 'Other';
      grouped.putIfAbsent(type, () => []).add(room);
    }

    if (grouped.isEmpty) {
      return const Center(child: Text('No conference rooms found'));
    }

    final types = grouped.keys.toList();
    final currentType = types[_current];
    final rooms = grouped[currentType]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header with nav arrows ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _current > 0
                  ? () => setState(() => _current--)
                  : null,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentType,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${_current + 1} of ${types.length}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            IconButton(
              onPressed: _current < types.length - 1
                  ? () => setState(() => _current++)
                  : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── Room cards ──
...rooms.map((room) {
  final links = (room['links']?.toString() ?? '')
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  return Card(
    margin: const EdgeInsets.only(bottom: 10),
    elevation: 2,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.meeting_room_outlined,
                size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                room['name']?.toString() ?? '',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark),
              ),
            ),
          ]),
          if (links.isNotEmpty) ...[
            const Divider(height: 16),
            ...links.map((link) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(link);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open: $link')),
                        );
                      }
                    },
                    child: Row(children: [
                      const Icon(Icons.link,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          link,
                          style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ),
                )),
          ],
        ],
      ),
    ),
  );
}),

const SizedBox(height: 8),

        // ── Dot indicators ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            types.length,
            (i) => GestureDetector(
              onTap: () => setState(() => _current = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _current
                      ? AppTheme.primary
                      : Colors.grey[400],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}