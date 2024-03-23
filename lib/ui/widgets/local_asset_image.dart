// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';

class LocalAssetImage extends StatefulWidget {
  const LocalAssetImage({super.key, 
    required this.name,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.color,
    this.fit = BoxFit.fill,
  });

  final String name;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Color? color;
  final BoxFit? fit;

  @override
  State<StatefulWidget> createState() => LocalAssetImageState();
}

class LocalAssetImageState extends State<LocalAssetImage> {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/${widget.name}',
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      color: widget.color,
      fit: widget.fit,
    );
  }
}
