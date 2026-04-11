import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';

class AdminConferenceRoomsScreen extends StatefulWidget {
  const AdminConferenceRoomsScreen({super.key});

  @override
  State<AdminConferenceRoomsScreen> createState() =>
      _AdminConferenceRoomsScreenState();
}

class _AdminConferenceRoomsScreenState
    extends State<AdminConferenceRoomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAllConferenceRooms());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final list = prov.allConferenceRooms;
    final error = prov.error;

    return Scaffold(
      body: prov.loading
          ? const LoadingWidget(message: 'Loading conference rooms...')
          : error != null
              ? ErrorWidget2(
                  message: error,
                  onRetry: () =>
                      context.read<ConferenceProvider>().loadAllConferenceRooms())
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<ConferenceProvider>().loadAllConferenceRooms(),
                  child: list.isEmpty
                      ? const Center(child: Text('No conference rooms found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: list.length,
                          itemBuilder: (_, i) =>
                              _RoomCard(room: list[i]),
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
        onPressed: () => _showRoomSheet(context),
      ),
    );
  }

  void _showRoomSheet(BuildContext context, {Map<String, dynamic>? room}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _RoomFormSheet(
        room: room,
        onSaved: () =>
            context.read<ConferenceProvider>().loadAllConferenceRooms(),
      ),
    );
  }
}

// ── Room Card ──────────────────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  const _RoomCard({required this.room});

  String _val(String k) => room[k]?.toString() ?? '-';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.meeting_room_outlined,
                    color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_val('name'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 3),
                      _TypeBadge(_val('type')),
                    ]),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textGrey),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _RoomDetailSheet(room: room),
    );
  }
}

// ── Type badge ─────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge(this.type);

  Color get _color {
    if (type.contains('Pre')) return AppTheme.accent;
    if (type.contains('Workshop')) return AppTheme.success;
    if (type.contains('Scientific')) return AppTheme.warning;
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: _color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10)),
      child: Text(type,
          style: TextStyle(
              fontSize: 11, color: _color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Detail bottom sheet ────────────────────────────────────────────────────

class _RoomDetailSheet extends StatelessWidget {
  final Map<String, dynamic> room;
  const _RoomDetailSheet({required this.room});

  String _val(String k) => room[k]?.toString().trim() ?? '-';

  @override
  Widget build(BuildContext context) {
    final links = _val('links');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (_, controller) => Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Text('Conference Room Details',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
              const Spacer(),
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppTheme.warning),
                tooltip: 'Edit',
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16))),
                    builder: (_) => _RoomFormSheet(
                      room: room,
                      onSaved: () => context
                          .read<ConferenceProvider>()
                          .loadAllConferenceRooms(),
                    ),
                  );
                },
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context),
              ),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _InfoRow('ID', _val('id')),
                _InfoRow('Name', _val('name')),
                _InfoRow('Type', _val('type')),
                _InfoRow('Created On', _val('created_on')),
                if (links.isNotEmpty && links != '-') ...[
                  const SizedBox(height: 8),
                  const Text('Links',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(links,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textDark,
                          height: 1.5)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Delete Conference Room'),
        content: Text('Are you sure you want to delete "${_val('name')}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dCtx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(dCtx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final ok = await context
          .read<ConferenceProvider>()
          .deleteConferenceRoom(room['id'].toString());
      if (!context.mounted) return;
      Navigator.pop(context);
      context.read<ConferenceProvider>().loadAllConferenceRooms();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? 'Conference room deleted'
              : (context.read<ConferenceProvider>().error ??
                  'Delete failed'))));
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
        ),
      ]),
    );
  }
}

// ── Add / Edit form bottom sheet ───────────────────────────────────────────

class _RoomFormSheet extends StatefulWidget {
  final Map<String, dynamic>? room; // null = add, non-null = edit
  final VoidCallback onSaved;
  const _RoomFormSheet({this.room, required this.onSaved});

  @override
  State<_RoomFormSheet> createState() => _RoomFormSheetState();
}

class _RoomFormSheetState extends State<_RoomFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _links;
  String? _type;
  bool _submitting = false;

  static const _roomTypes = [
    'Conference Hall',
    'Pre conference hall',
    'Scientific session rooms',
    'Workshops',
  ];

  bool get _isEdit => widget.room != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
        text: widget.room?['name']?.toString() ?? '');
    _links = TextEditingController(
        text: widget.room?['links']?.toString() ?? '');
    final existingType = widget.room?['type']?.toString();
    _type = (_roomTypes.contains(existingType)) ? existingType : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _links.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    final data = {
      'name': _name.text.trim(),
      'type': _type,
      'links': _links.text.trim(),
    };

    bool ok;
    if (_isEdit) {
      ok = await context
          .read<ConferenceProvider>()
          .updateConferenceRoom(widget.room!['id'].toString(), data);
    } else {
      ok = await context.read<ConferenceProvider>().addConferenceRoom(data);
    }

    setState(() => _submitting = false);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit
              ? 'Conference room updated'
              : 'Conference room added')));
    } else {
      final err = context.read<ConferenceProvider>().error ??
          'Failed to save conference room';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text(_isEdit ? 'Edit Conference Room' : 'Add Conference Room',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary)),
                const Spacer(),
                if (_submitting)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                else
                  TextButton(onPressed: _submit, child: const Text('Save')),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Conference Room Name *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'Type of Conference *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      items: _roomTypes
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _type = v),
                      validator: (v) =>
                          v == null ? 'Please select a type' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _links,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Links',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_isEdit ? 'Update' : 'Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
