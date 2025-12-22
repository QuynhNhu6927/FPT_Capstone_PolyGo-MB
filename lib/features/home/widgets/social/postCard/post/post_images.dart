import 'package:flutter/material.dart';

class PostImages extends StatelessWidget {
  final List<String> imageUrls;
  // final List<Color?> imageBgColors;

  const PostImages({
    super.key,
    required this.imageUrls,
    // required this.imageBgColors,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return SizedBox.shrink();

    final imagesToShow = imageUrls.length > 4 ? 4 : imageUrls.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final spacing = 4.0;

        Widget buildImage(int i, {double? w, double? h, bool overlay = false}) {
          return GestureDetector(
            onTap: () => _showFullImage(context, i),
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: (Colors.grey).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrls[i],
                      fit: BoxFit.cover,
                    ),
                    if (overlay)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        alignment: Alignment.center,
                        child: Text(
                          '+${imageUrls.length - 4}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        switch (imagesToShow) {
          case 1:
            return buildImage(0, w: width, h: width * 0.6);
          case 2:
            double w = (width - spacing) / 2;

            return Row(
              children: [
                buildImage(0, w: w, h: w),
                SizedBox(width: spacing),
                buildImage(1, w: w, h: w),
              ],
            );
          case 3:
          case 3:
            double totalWidth = width - spacing;
            double leftW = totalWidth * 0.6;
            double rightW = totalWidth * 0.4;

            double rightH = rightW;              // ảnh 1:1
            double leftH = rightH * 2 + spacing; // chiều cao khớp cột phải

            return Row(
              children: [
                buildImage(0, w: leftW, h: leftH),
                SizedBox(width: spacing),
                Column(
                  children: [
                    buildImage(1, w: rightW, h: rightH),
                    SizedBox(height: spacing),
                    buildImage(2, w: rightW, h: rightH),
                  ],
                ),
              ],
            );

          case 4:
          default:
          double box = (width - spacing) / 2;

          return Column(
            children: [
              Row(
                children: [
                  buildImage(0, w: box, h: box),
                  SizedBox(width: spacing),
                  buildImage(1, w: box, h: box),
                ],
              ),
              SizedBox(height: spacing),
              Row(
                children: [
                  buildImage(2, w: box, h: box),
                  SizedBox(width: spacing),
                  buildImage(3, w: box, h: box, overlay: imageUrls.length > 4),
                ],
              ),
            ],
          );

        }
      },
    );
  }

  void _showFullImage(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: PageView.builder(
          controller: PageController(initialPage: index),
          itemCount: imageUrls.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Image.network(imageUrls[i], fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
