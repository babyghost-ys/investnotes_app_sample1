Both file names visible, both videos read frame by frame. The other app's source is not on this machine, so the cause below is inferred from the videos, this project's code and the Flutter engine history.

**What the videos show**
- Video 1: Home is idle, so Flutter draws no frames. Tap Sign On: title clears, then nothing for about 5 s. The tab tap forces one frame and the sheet appears at once.
- Video 2: the Issued skeleton pulses, so frames run continuously. The sheet appears after about 1 s.
- So the sheet is not slow. It is parked waiting for the main engine's **next frame**, and nobody schedules one.

**Most likely cause**
- Between the tap and the native `present` call, the other app waits on a frame: `addPostFrameCallback` or `await endOfFrame` with no `ensureVisualUpdate()` / `scheduleFrame()` after it.
- `endOfFrame` only schedules a frame when the scheduler is idle. Called inside a frame, it waits for a frame someone else must request.

**Your questions**
- **Title disappearing: yes, a clue.** It means the other app changes the page first (title cleared in one frame), then waits for a second frame before presenting. This project does neither: `NativeSheet.show` calls `present` directly, and native presents on the sheet's `bootstrap` call, not on a frame ([NativeWidgetSheet.swift:169](packages/flutter_native_widgets/ios/flutter_native_widgets/Sources/flutter_native_widgets/Overlays/NativeWidgetSheet.swift:169)).
- **Artificial delay: not the hang, but it makes it certain.** A timer fires without frames. After the delay the app is idle, so any frame wait that follows never fires. It also explains the lag in video 2.
- **Parameters to the sheet engine: not the problem.** Entry-point arguments do not touch frame scheduling.
- **3.50.0: not a fix.** 3.47 to 3.50 reworked iOS vsync (flutter/flutter#191444), so timing changes and may hide it. The missing frame request stays.
- **Simulator fine, phone not:** I cannot explain this without their code. A timing race between debug on the simulator and release on a 120 Hz phone is the consistent reading.

**Fix in the other app**
- Search the path from the Sign On tap to `invokeMethod('present')` for `addPostFrameCallback` and `endOfFrame`.
- Either call `present` directly, or add `SchedulerBinding.instance.ensureVisualUpdate()` right after registering the callback, as [toolbar_registry.dart:138](packages/flutter_native_widgets/lib/src/navigation/chrome/toolbar_registry.dart:138) does here.
- On the native side, present when the sheet isolate first calls in, never on its first rendered frame.
- Remove the artificial delay.
