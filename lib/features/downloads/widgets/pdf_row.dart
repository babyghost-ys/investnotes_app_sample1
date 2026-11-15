import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A downloaded PDF: its first page, and its title.
class PdfRow extends StatelessWidget {
  const PdfRow({
    super.key,
    required this.path,
    required this.title,
    required this.onTap,
  });

  final String path;
  final String title;
  final VoidCallback onTap;

  /// An A4 page's height for its width.
  static const _aspect = 297 / 210;
  static const _width = 62.0;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: KeelColors.hairline.of(context)),
          ),
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  width: _width,
                  height: _width * _aspect,
                  child: ColoredBox(
                    color: KeelColors.tideDeep.of(context),
                    child: PdfDocumentViewBuilder.file(
                      path,
                      builder: (context, document) => document == null
                          ? const SizedBox.expand()
                          : PdfPageView(
                              document: document,
                              pageNumber: 1,
                              maximumDpi: 150,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: KeelColors.ink.of(context),
                  fontSize: 18,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
