/// Where a page's loading stands. Every page switches on this: a spinner
/// while [loading], its content once [loaded], a way to try again if
/// [failed].
enum LoadingPhase { loading, loaded, failed }
