import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import 'package:investnotes_app_sample1/app/sheet_arguments.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/domain/models/article.dart';
import 'package:investnotes_app_sample1/features/downloads/bloc/downloads_bloc.dart';

/// Opens a downloaded [article]'s PDF full screen: on iOS a native sheet
/// with UIKit's own bar, elsewhere a full-screen dialog page.
Future<void> openArticlePdf(BuildContext context, Article article) async {
  final path = context.read<DownloadsBloc>().state.files[article.id];
  if (path == null) return;
  if (NativeStyle.of(context) != NativeStyle.native) {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => NativeScaffold(
          appBar: NativeAppBar(title: article.title),
          body: ArticlePdfPage(path: path, title: article.title),
        ),
      ),
    );
    return;
  }
  await NativeSheet.show<void>(
    context: context,
    route: 'pdf',
    arguments: SheetArguments.wrap(context, {
      'path': path,
      'title': article.title,
    }),
    fullScreen: true,
    backgroundColor: KeelColors.page.of(context),
    navigationBar: true,
    barColor: KeelColors.tide.of(context),
    barForeground: CupertinoColors.white,
    barShadow: NativeTheme.of(context).barStyle.shadow,
    plainBarButtons: true,
    barTitleStyle: NativeTheme.of(context).barStyle.titleStyle,
    // The sheet runs its own engine; see the native sheet app.
    builder: (_) => const SizedBox.shrink(),
  );
}

/// A downloaded article's PDF, page after page, to scroll and pinch.
class ArticlePdfPage extends StatefulWidget {
  const ArticlePdfPage({super.key, required this.path, required this.title});

  final String path;
  final String title;

  @override
  State<ArticlePdfPage> createState() => _ArticlePdfPageState();
}

class _ArticlePdfPageState extends State<ArticlePdfPage> {
  @override
  void initState() {
    super.initState();
    // In a native sheet, UIKit's bar carries the title and the close.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NativeSheet.setBar(
        title: widget.title,
        onClose: () => NativeSheet.pop<Object?>(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final page = KeelColors.page.of(context);
    return ColoredBox(
      color: page,
      // Starts below the bar; scrolls past the home indicator.
      child: Padding(
        padding: EdgeInsets.only(top: insets.top),
        child: PdfViewer.file(
          widget.path,
          params: PdfViewerParams(
            backgroundColor: page,
            margin: 14,
            boundaryMargin: EdgeInsets.fromLTRB(
              insets.left,
              0,
              insets.right,
              insets.bottom,
            ),
            pageDropShadow: const BoxShadow(
              color: Color(0x26000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
            loadingBannerBuilder: (context, _, _) =>
                const Center(child: CupertinoActivityIndicator(radius: 14)),
            errorBannerBuilder: (context, _, _, _) => Center(
              child: Icon(
                CupertinoIcons.doc_text,
                size: 44,
                color: KeelColors.muted.of(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
