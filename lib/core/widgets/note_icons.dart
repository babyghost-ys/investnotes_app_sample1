import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/data/models/note_enums.dart';

/// Flutter-drawn icons for values shown in Flutter widgets. Native controls
/// use the SF Symbol names kept on the enums.
abstract final class NoteIcons {
  /// Every region reads as a place on the globe.
  static IconData region(Region region) => CupertinoIcons.globe;

  static IconData assetClass(AssetClass value) => switch (value) {
    AssetClass.equity => CupertinoIcons.graph_square,
    AssetClass.commodity => CupertinoIcons.cube_box,
    AssetClass.rates => CupertinoIcons.percent,
    AssetClass.multiAsset => CupertinoIcons.square_stack_3d_up,
  };

  static IconData status(IssuedStatus value) => switch (value) {
    IssuedStatus.active => CupertinoIcons.waveform_path_ecg,
    IssuedStatus.called => CupertinoIcons.bell,
    IssuedStatus.matured => CupertinoIcons.checkmark_seal,
  };
}
