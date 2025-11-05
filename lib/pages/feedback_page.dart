import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_drawer.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    final name = _nameController.text.trim();
    final feedback = _feedbackController.text.trim();

    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write some feedback')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'name': name.isEmpty ? 'Anonymous' : name,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear fields after submit
      _nameController.clear();
      _feedbackController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting feedback: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        backgroundColor: Colors.black,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "We value your feedback!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Your Name (optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: "Your Feedback",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Feedback",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
