import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/domain/models/article.dart';
import 'package:investnotes_app_sample1/features/downloads/bloc/downloads_bloc.dart';
import 'package:investnotes_app_sample1/features/education/view/article_pdf_page.dart';

/// An article's download control. Tapped, it fills from left to right as
/// the file arrives; tapped again while filling, it stops; full, it opens
/// the PDF on the device.
class DownloadPill extends StatelessWidget {
  const DownloadPill({super.key, required this.article, required this.words});

  final Article article;
  final EducationSemantics words;

  static const radius = 12.0;

  @override
  Widget build(BuildContext context) {
    final id = article.id;
    return BlocBuilder<DownloadsBloc, DownloadsState>(
      buildWhen: (before, now) =>
          before.fill(id) != now.fill(id) ||
          before.isKept(id) != now.isKept(id) ||
          before.progress.containsKey(id) != now.progress.containsKey(id),
      builder: (context, state) {
        final kept = state.isKept(id);
        final arriving = state.progress.containsKey(id);
        final fill = state.fill(id);
        final ink = KeelColors.tideInk.of(context);
        final (icon, size, label) = kept
            ? (CupertinoIcons.checkmark_alt, 22.0, words.openDownload)
            : arriving
            ? (CupertinoIcons.xmark, 15.0, words.cancelDownload)
            : (CupertinoIcons.arrow_down_to_line, 20.0, words.download);
        return Semantics(
          button: true,
          label: label,
          value: arriving ? '${(fill * 100).round()}%' : null,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              final bloc = context.read<DownloadsBloc>();
              if (kept) {
                openArticlePdf(context, article);
              } else if (arriving) {
                bloc.add(DownloadCancelled(id));
              } else {
                bloc.add(DownloadRequested(article));
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: SizedBox(
                height: 44,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: KeelColors.mist.of(context)),
                    // Chunks arrive every few hundred milliseconds; each
                    // glides into the next, so the fill moves steadily.
                    // A stopped download drains the same way.
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: fill),
                      duration: const Duration(milliseconds: 320),
                      builder: (context, value, _) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value.clamp(0, 1),
                        child: ColoredBox(
                          color: KeelColors.mistDeep.of(context),
                        ),
                      ),
                    ),
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                              scale: Tween(
                                begin: 0.6,
                                end: 1.0,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                        child: Icon(
                          icon,
                          key: ValueKey(icon),
                          size: size,
                          color: ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
