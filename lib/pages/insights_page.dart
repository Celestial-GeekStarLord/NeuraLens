import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> insights = [
    {
      'mode': 'Describe Mode',
      'summary':
          'Gemini analyzed 5 new images and provided detailed visual descriptions.',
      'time': 'Today, 10:45 AM',
      'color': Colors.cyanAccent,
    },
    {
      'mode': 'List Items Mode',
      'summary':
          'Recognized and listed 7 grocery items from camera input accurately.',
      'time': 'Yesterday, 7:20 PM',
      'color': Colors.deepPurpleAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCard(Map<String, dynamic> item) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [item['color'].withOpacity(0.5), Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: item['color'].withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            leading: Icon(
              item['mode'] == 'Describe Mode'
                  ? Icons.image_search_rounded
                  : Icons.list_alt_rounded,
              color: item['color'],
              size: 40,
            ),
            title: Text(
              item['mode'],
              style: TextStyle(
                color: item['color'],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                item['summary'],
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            trailing: Text(
              item['time'],
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Neuralens Insights"),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 6,
        shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 2,
                colors: [Colors.deepPurple.withOpacity(0.15), Colors.black],
                center: Alignment(
                  math.cos(_controller.value * 2 * math.pi),
                  math.sin(_controller.value * 2 * math.pi),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: const [
                        Colors.cyanAccent,
                        Colors.purpleAccent,
                        Colors.blueAccent,
                        Colors.pinkAccent,
                      ],
                      transform: GradientRotation(
                        _controller.value * 2 * math.pi,
                      ),
                    ).createShader(bounds),
                    child: const Text(
                      "AI Interaction Insights",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      itemCount: insights.length,
                      itemBuilder: (context, index) =>
                          _buildAnimatedCard(insights[index]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      shadowColor: Colors.purpleAccent,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Coming soon: AI summaries and voice logs",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.graphic_eq_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Generate AI Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
