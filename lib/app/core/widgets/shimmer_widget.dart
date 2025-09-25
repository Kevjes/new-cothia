import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppColors.surface;
    final highlightColor = widget.highlightColor ?? AppColors.background.withOpacity(0.5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerText({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int titleLines;
  final int subtitleLines;

  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = true,
    this.titleLines = 1,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (hasLeading) ...[
            const ShimmerCircle(size: 40),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < titleLines; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  ShimmerText(
                    width: i == titleLines - 1 ? 100 : null,
                    height: 16,
                  ),
                ],
                if (subtitleLines > 0) ...[
                  const SizedBox(height: 8),
                  for (int i = 0; i < subtitleLines; i++) ...[
                    if (i > 0) const SizedBox(height: 4),
                    ShimmerText(
                      width: i == subtitleLines - 1 ? 150 : null,
                      height: 12,
                    ),
                  ],
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 16),
            const ShimmerContainer(width: 24, height: 24),
          ],
        ],
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.all(8),
      child: ShimmerContainer(
        width: width,
        height: height ?? 120,
        padding: padding ?? const EdgeInsets.all(16),
      ),
    );
  }
}

class ShimmerButton extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerButton({
    super.key,
    this.width,
    this.height = 40,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: width ?? 120,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;

  const ShimmerGrid({
    super.key,
    required this.itemCount,
    this.itemHeight = 120,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerContainer(
          height: itemHeight,
        );
      },
    );
  }
}

// Utility class for creating different shimmer patterns
class ShimmerPatterns {
  static Widget taskCard() {
    return ShimmerCard(
      height: 120,
      padding: const EdgeInsets.all(16),
    );
  }

  static Widget taskListTile() {
    return const ShimmerListTile(
      hasLeading: true,
      hasTrailing: true,
      titleLines: 1,
      subtitleLines: 2,
    );
  }

  static Widget statsCard() {
    return ShimmerCard(
      height: 80,
      padding: const EdgeInsets.all(12),
    );
  }

  static Widget projectCard() {
    return ShimmerCard(
      height: 100,
      padding: const EdgeInsets.all(16),
    );
  }
}