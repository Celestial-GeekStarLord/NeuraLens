import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  bool _isSubmitting = false;
  AnimationController? _controller; // nullable to prevent early access

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.stop();
    _controller?.dispose();
    _nameController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

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

      _nameController.clear();
      _feedbackController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _animatedTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return AnimatedBuilder(
      animation: _controller ?? kAlwaysDismissedAnimation,
      builder: (context, _) {
        final progress = _controller?.value ?? 0.0;
        final colors = [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.purple,
          Colors.pink,
        ];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: SweepGradient(
              colors: colors,
              transform: GradientRotation(progress * 2 * math.pi),
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          "Feedback",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            letterSpacing: 1.2,
          ),
        ),

        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 6,
        shadowColor: Colors.purpleAccent.withOpacity(0.6),
      ),
      body: controller == null
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 2,
                      colors: [
                        Colors.deepPurple.withOpacity(0.15),
                        const Color.fromARGB(255, 0, 0, 0),
                      ],
                      center: Alignment(
                        math.cos(controller.value * 2 * math.pi),
                        math.sin(controller.value * 2 * math.pi),
                      ),
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.pink,
                                Colors.orange,
                                Colors.yellow,
                                Colors.green,
                                Colors.blue,
                                Colors.purple,
                              ],
                              transform: GradientRotation(
                                controller.value * 2 * math.pi,
                              ),
                            ).createShader(bounds),
                            child: const Text(
                              "We Value Your Feedback!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _animatedTextField(
                            controller: _nameController,
                            label: "Your Name (optional)",
                          ),
                          const SizedBox(height: 20),
                          _animatedTextField(
                            controller: _feedbackController,
                            label: "Your Feedback",
                            maxLines: 6,
                          ),
                          const SizedBox(height: 40),
                          GestureDetector(
                            onTap: _isSubmitting ? null : _submitFeedback,
                            child: AnimatedBuilder(
                              animation: controller,
                              builder: (context, _) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: SweepGradient(
                                      colors: const [
                                        Colors.red,
                                        Colors.orange,
                                        Colors.yellow,
                                        Colors.green,
                                        Colors.blue,
                                        Colors.purple,
                                        Colors.pink,
                                      ],
                                      transform: GradientRotation(
                                        controller.value * 2 * math.pi,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: _isSubmitting
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Submit Feedback",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
