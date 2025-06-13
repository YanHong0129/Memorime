import 'package:flutter/material.dart';


class SelectFriendsPage extends StatefulWidget {
  const SelectFriendsPage({super.key});

  @override
  State<SelectFriendsPage> createState() => _SelectFriendsPageState();
}

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  List<Map<String, dynamic>> _friends = [];
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    // fetchFriendList().then((friends) {
    //   setState(() {
    //     _friends = friends;
    //   });
    // });
  }

  void _submitSelection() {
    Navigator.pop(context, _selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Friends")),
      body: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          final uid = friend['uid'];
          final name = friend['username'];

          return CheckboxListTile(
            value: _selectedIds.contains(uid),
            title: Text(name),
            onChanged: (checked) {
              setState(() {
                if (checked!) {
                  _selectedIds.add(uid);
                } else {
                  _selectedIds.remove(uid);
                }
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitSelection,
        label: const Text("Done"),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
