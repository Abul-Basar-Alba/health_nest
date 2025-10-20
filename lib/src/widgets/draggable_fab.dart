// lib/src/widgets/draggable_fab.dart

import 'package:flutter/material.dart';
import 'package:health_nest/src/screens/activity_dashboard_wrapper.dart';

class DraggableFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final double size;

  const DraggableFAB({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.size = 56.0,
  });

  @override
  DraggableFABState createState() => DraggableFABState();
}

class DraggableFABState extends State<DraggableFAB>
    with TickerProviderStateMixin {
  late Offset _position;
  bool _isVisible = true;
  bool _showCloseButton = false;
  late AnimationController _animationController;
  late AnimationController _closeButtonController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _closeButtonAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _closeButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _closeButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _closeButtonController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set initial position based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    _position = Offset(
      screenWidth - widget.size - 20, // Right edge with margin
      screenHeight - 200, // Above bottom navigation bar
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _closeButtonController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_showCloseButton) {
      // If close button is showing, trigger the action
      widget.onPressed?.call();
      _hideCloseButton();
    } else {
      // Show close button with animation
      setState(() {
        _showCloseButton = true;
      });
      _closeButtonController.forward();
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Auto-hide close button after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (_showCloseButton && mounted) {
          _hideCloseButton();
        }
      });
    }
  }

  void _hideCloseButton() {
    _showCloseButton = false;
    _closeButtonController.reverse();
  }

  void _hideFAB() {
    setState(() {
      _isVisible = false;
    });
    _hideCloseButton();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
    _hideCloseButton(); // Hide close button when dragging
  }

  void _onPanEnd(DragEndDetails details) {
    // Snap to edges
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      // Snap to left or right edge
      if (_position.dx < screenWidth / 2) {
        _position = Offset(20, _position.dy);
      } else {
        _position = Offset(screenWidth - widget.size - 20, _position.dy);
      }

      // Keep within screen bounds
      _position = Offset(
        _position.dx.clamp(20, screenWidth - widget.size - 20),
        _position.dy.clamp(100, screenHeight - widget.size - 100),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return Container(); // Return empty container if hidden
    }

    return Stack(
      children: [
        // Main FAB
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onTap: _onTap,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.backgroundColor ?? Colors.green.shade600,
                          (widget.backgroundColor ?? Colors.green.shade600)
                              .withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        if (_showCloseButton)
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            spreadRadius: 4,
                            blurRadius: 12,
                            offset: const Offset(0, 0),
                          ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          _showCloseButton ? Icons.touch_app : Icons.add,
                          color: widget.foregroundColor ?? Colors.white,
                          size: 28,
                        ),
                        if (_showCloseButton)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'TAP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Close button (appears when FAB is tapped)
        if (_showCloseButton)
          Positioned(
            left: _position.dx + widget.size - 15,
            top: _position.dy - 5,
            child: AnimatedBuilder(
              animation: _closeButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _closeButtonAnimation.value,
                  child: GestureDetector(
                    onTap: _hideFAB,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Usage in MainNavigation
class DraggableFABOverlay extends StatefulWidget {
  final Widget child;

  const DraggableFABOverlay({
    super.key,
    required this.child,
  });

  @override
  DraggableFABOverlayState createState() => DraggableFABOverlayState();
}

class DraggableFABOverlayState extends State<DraggableFABOverlay> {
  final GlobalKey<DraggableFABState> _fabKey = GlobalKey<DraggableFABState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          DraggableFAB(
            key: _fabKey,
            onPressed: () {
              // Navigate to Activity Dashboard
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ActivityDashboardWrapper(),
                ),
              );
            },
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            tooltip: 'Quick Log Activity',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
