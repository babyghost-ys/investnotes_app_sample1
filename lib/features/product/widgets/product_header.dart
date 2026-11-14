import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/note_icons.dart';
import 'package:investnotes_app_sample1/core/widgets/payoff_glyph.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';

/// The note's name, its payoff shape, and how it stands: open until a
/// date, or active, called or matured.
class ProductHeader extends StatelessWidget {
  const ProductHeader({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final azure = KeelColors.azure.of(context);
    final muted = KeelColors.muted.of(context);
    final status = p.status;
    final live = status == null || status == IssuedStatus.active;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                style: TextStyle(
                  color: KeelColors.ink.of(context),
                  fontSize: 26,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    status == null
                        ? CupertinoIcons.lock_open
                        : NoteIcons.status(status),
                    size: 15,
                    color: live ? azure : muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status == null ? Formats.until(p.closes!) : status.title,
                    semanticsLabel: status == null
                        ? 'Open until ${Formats.until(p.closes!)}'
                        : null,
                    style: TextStyle(
                      color: live ? azure : muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: KeelColors.mist.of(context),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: PayoffGlyph(payoff: p.payoff, color: azure, size: 46),
        ),
      ],
    );
  }
}
