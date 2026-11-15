import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/formatting/formats.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/domain/models/note_event.dart';

/// The note's dated steps down a line: past ones filled, the next one
/// ringed, later ones open.
class EventsSection extends StatelessWidget implements LocalisationConsumer {
  const EventsSection({super.key, required this.events});

  final List<NoteEvent> events;

  static IconData iconOf(NoteEventKind kind) => switch (kind) {
    NoteEventKind.closes => CupertinoIcons.lock,
    NoteEventKind.issued => CupertinoIcons.flag,
    NoteEventKind.callCheck => CupertinoIcons.eye,
    NoteEventKind.called => CupertinoIcons.bell,
    NoteEventKind.matures => CupertinoIcons.flag_circle,
  };

  @override
  List<String> get namespaces => const [Locales.product, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as ProductLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    ProductLocale words,
    GeneralLocale general,
  ) {
    final now = DateTime.now();
    final next = events.indexWhere((e) => e.date.isAfter(now));
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          _Step(
            event: events[i],
            past: !events[i].date.isAfter(now),
            next: i == next,
            first: i == 0,
            last: i == events.length - 1,
            words: words,
            general: general,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.event,
    required this.past,
    required this.next,
    required this.first,
    required this.last,
    required this.words,
    required this.general,
  });

  final NoteEvent event;
  final ProductLocale words;
  final GeneralLocale general;
  final bool past;
  final bool next;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final azure = KeelColors.azure.of(context);
    final hairline = KeelColors.hairline.of(context);
    final muted = KeelColors.muted.of(context);
    // Within the week, the relative day leads; it reads faster than a date.
    final soon = !past && event.date.difference(DateTime.now()).inDays < 7;
    final f = Formats(general);
    final date = soon
        ? '${f.until(event.date)} · ${f.fullDate(event.date)}'
        : f.fullDate(event.date);
    final state = past
        ? words.semantics.done
        : (next ? words.semantics.next : words.semantics.upcoming);
    return Semantics(
      container: true,
      label: words.semantics.event(
        state: state,
        event: event.kind.title(general),
        date: f.fullDate(event.date),
      ),
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Container(
                    width: 2,
                    height: 14,
                    color: first ? null : (past ? azure : hairline),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: past ? azure : KeelColors.raised.of(context),
                      shape: BoxShape.circle,
                      border: past
                          ? null
                          : Border.all(
                              color: next ? azure : hairline,
                              width: 2,
                            ),
                    ),
                    child: Icon(
                      EventsSection.iconOf(event.kind),
                      size: 19,
                      color: past
                          ? CupertinoColors.white
                          : next
                          ? azure
                          : muted,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: last ? null : (past ? azure : hairline),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.kind.title(general),
                      style: TextStyle(
                        color: KeelColors.ink.of(context),
                        fontSize: 17,
                        fontWeight: next ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date,
                      style: TextStyle(
                        color: next ? azure : muted,
                        fontSize: 14,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
