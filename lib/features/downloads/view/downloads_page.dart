import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/features/downloads/bloc/downloads_bloc.dart';
import 'package:investnotes_app_sample1/features/education/view/article_page.dart';
import 'package:investnotes_app_sample1/features/education/widgets/article_row.dart';

/// The articles on this device, most recently downloaded first. Swiping
/// one away deletes it.
class DownloadsPage extends StatelessWidget implements LocalisationConsumer {
  const DownloadsPage({super.key});

  @override
  List<String> get namespaces => const [Locales.downloads];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as DownloadsLocale),
  );

  Widget _build(BuildContext context, DownloadsLocale words) {
    final kept = context.watch<DownloadsBloc>().state.kept;
    final insets = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20 + insets.left,
            insets.top + 8,
            20 + insets.right,
            insets.bottom + 40,
          ),
          children: [
            for (final a in kept)
              Dismissible(
                key: ValueKey(a.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) =>
                    context.read<DownloadsBloc>().add(DownloadRemoved(a.id)),
                background: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.trash_fill,
                      color: KeelColors.loss.of(context),
                      size: 24,
                    ),
                  ),
                ),
                child: Semantics(
                  customSemanticsActions: {
                    CustomSemanticsAction(label: words.semantics.remove): () =>
                        context.read<DownloadsBloc>().add(
                          DownloadRemoved(a.id),
                        ),
                  },
                  child: ArticleRow(
                    article: a,
                    onTap: () => openArticle(context, a),
                  ),
                ),
              ),
            if (kept.isEmpty)
              EmptyState(
                icon: CupertinoIcons.arrow_down_to_line,
                semanticLabel: words.semantics.nothingDownloaded,
              ),
          ],
        ),
      ),
    );
  }
}
