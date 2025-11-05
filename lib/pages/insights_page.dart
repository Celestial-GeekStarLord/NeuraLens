import 'package:firstone/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ Drawer icon shows up here
        title: const Text("About Us"),
        backgroundColor: Colors.black,
      ),
      drawer: const AppDrawer(),

      body: const Center(
        child: Text(
          "Here you’ll see feedbacks and logs "
          "from your Gemini interactions soon.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
