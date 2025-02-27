import 'package:flutter/material.dart';

class MarketingMessage extends StatefulWidget {
  final String message;
  final Duration displayDuration;
  final VoidCallback onDismiss;

  const MarketingMessage({
    super.key,
    required this.message,
    this.displayDuration = const Duration(seconds: 50),
    required this.onDismiss,
  });

  @override
  _MarketingMessageState createState() => _MarketingMessageState();
}

class _MarketingMessageState extends State<MarketingMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 50000),
      vsync: this,
    );

    // Define the slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0), // Start off-screen at the top
      end: Offset.zero, // End at the top of the screen
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start the animation when the widget is built
    _controller.forward().then((_) {
      // Wait for the display duration, then slide back up
      Future.delayed(widget.displayDuration, () {
        _controller.reverse().then((_) {
          // Notify the parent that the message has been dismissed
          widget.onDismiss();
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.red, // Temporary background color for debugging
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          widget.message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
