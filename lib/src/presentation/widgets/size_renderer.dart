import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SizeRenderer extends StatefulWidget {
  final Widget child;
  final Function(Size size, GlobalKey key) onSizeRendered;

  const SizeRenderer({
    super.key,
    required this.onSizeRendered,
    required this.child,
  });

  @override
  State createState() => _SizeRendererState();
}

class _SizeRendererState extends State<SizeRenderer> {
  final key = GlobalKey();
  Size oldSize = Size.zero;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(onCreated);
  }

  void onCreated(_) {
    var context = key.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (newSize == null || oldSize == newSize) return;

    oldSize = newSize;
    widget.onSizeRendered(newSize, key);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: key,
      child: widget.child,
    );
  }
}
