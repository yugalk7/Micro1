import 'package:flutter/material.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});

@override
State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
final name = TextEditingController();
final address = TextEditingController();

@override
void initState() {
super.initState();
load();
}

Future<void> load() async {
final user = await UserService.getUser();
name.text = user["name"]!;
address.text = user["address"]!;
}

Future<void> save() async {
await UserService.saveUser(name.text, address.text);


ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text("Profile Saved")),
);


}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Profile")),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
TextField(
controller: name,
decoration: const InputDecoration(labelText: "Name"),
),
const SizedBox(height: 16),
TextField(
controller: address,
decoration: const InputDecoration(labelText: "Address"),
),
const SizedBox(height: 20),
ElevatedButton(onPressed: save, child: const Text("Save")),
],
),
),
);
}
}
