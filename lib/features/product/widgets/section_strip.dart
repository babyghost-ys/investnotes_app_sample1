import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/domain/models/product_section.dart';

/// The row of a note's sections: a disc and a word each, scrolled sideways
/// when they outrun the screen. The chosen one fills with the bar's blue
/// and slides into view.
class SectionStrip extends StatefulWidget {
  const SectionStrip({
    super.key,
    required this.sections,
    required this.selected,
    required this.onSelected,
    required this.inset,
  });

  /// Height of the strip, the same for every page.
  static const height = 112.0;

  final List<ProductSection> sections;
  final ProductSection selected;
  final ValueChanged<ProductSection> onSelected;

  /// Room kept clear at each end, matching the page's side margins.
  final EdgeInsets inset;

  static IconData iconOf(ProductSection section) => switch (section) {
    ProductSection.overview => CupertinoIcons.eye,
    ProductSection.payoff => CupertinoIcons.graph_circle,
    ProductSection.scenarios => CupertinoIcons.slider_horizontal_3,
    ProductSection.history => CupertinoIcons.clock,
    ProductSection.value => CupertinoIcons.gauge,
    ProductSection.events => CupertinoIcons.calendar,
  };

  @override
  State<SectionStrip> createState() => _SectionStripState();
}

class _SectionStripState extends State<SectionStrip> {
  final _keys = <ProductSection, GlobalKey>{};

  GlobalKey _keyOf(ProductSection s) => _keys.putIfAbsent(s, GlobalKey.new);

  @override
  void didUpdateWidget(SectionStrip old) {
    super.didUpdateWidget(old);
    if (old.selected == widget.selected) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _keyOf(widget.selected).currentContext;
      if (target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.5,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: SectionStrip.height,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(
        12 + widget.inset.left,
        14,
        12 + widget.inset.right,
        10,
      ),
      children: [
        for (final s in widget.sections)
          _Item(
            key: _keyOf(s),
            section: s,
            selected: s == widget.selected,
            onTap: () {
              if (s == widget.selected) return;
              HapticFeedback.selectionClick();
              widget.onSelected(s);
            },
          ),
      ],
    ),
  );
}

class _Item extends StatelessWidget implements LocalisationConsumer {
  const _Item({
    super.key,
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final ProductSection section;
  final bool selected;
  final VoidCallback onTap;

  /// The chosen disc: the bar's blue by day; at night that blue sinks into
  /// the page, so the brighter accent takes its place.
  static const _chosen = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0B3D91),
    darkColor: Color(0xFF2F6FD6),
  );

  @override
  List<String> get namespaces => const [Locales.product];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as ProductLocale),
  );

  Widget _build(BuildContext context, ProductLocale product) {
    final tide = _chosen.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: section.title(product),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 84,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: selected ? tide : KeelColors.mist.of(context),
                  shape: BoxShape.circle,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: tide.withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : const [],
                ),
                child: Icon(
                  SectionStrip.iconOf(section),
                  size: 24,
                  color: selected
                      ? CupertinoColors.white
                      : KeelColors.azure.of(context),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                style: TextStyle(
                  color: selected
                      ? KeelColors.ink.of(context)
                      : KeelColors.muted.of(context),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(section.title(product), maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
