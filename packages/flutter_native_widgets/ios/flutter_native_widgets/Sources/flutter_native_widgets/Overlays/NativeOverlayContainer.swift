import Flutter
import UIKit

/// Engines the package starts beside the page's own: native sheets and the
/// overlay container. They spawn from one group, so each after the first
/// shares the group's loaded program instead of starting from nothing.
enum NativeEngines {
    static let group = FlutterEngineGroup(name: "flutter_native_widgets.engines", project: nil)
}

/// A strip of Flutter content laid exactly over the native navigation bar,
/// below the status bar, at the bar's own height; nothing moves for it.
///
/// The page's Flutter view lives under UIKit's bars, so nothing it draws can
/// reach this band. A strip that is only a symbol and a line of text
/// (`content` in the request) is drawn here natively and starts no engine.
/// Any other strip runs its own engine from the app's `commonOverlayMain`
/// entrypoint (see `NativeOverlayContainer.run` in Dart), started on the
/// first such `show` and kept warm afterwards.
///
/// The strip is the topmost view of the window's root view controller, so
/// presented sheets still slide over it. It takes the touches on it, so the
/// bar buttons it covers cannot be pressed blind.
final class NativeOverlayContainer {
    static let shared = NativeOverlayContainer()

    /// The status bar's style while the strip lies behind it: legible on the
    /// strip's colour. Nil while the strip is hidden.
    static var statusBarStyle: UIStatusBarStyle? {
        guard shared.shown, let color = (shared.request?["color"] as? NSNumber)?.intValue else { return nil }
        return NativeBarAppearance.isDark(color) ? .lightContent : .darkContent
    }

    /// Finds the page's window. Set by the plugin of the page's engine.
    var windowProvider: () -> UIWindow? = { nil }

    private var engine: FlutterEngine?
    private var controller: FlutterViewController?
    private var contentChannel: FlutterMethodChannel?
    /// The native symbol and text, for a request with `content`.
    private var label: NativeOverlayLabelView?
    private let strip = NativeOverlayStripView()
    private weak var root: UIViewController?
    /// The strip is on screen.
    private var shown = false
    /// The measured bottom of an inline-title bar, and what it was measured for.
    private var measuredBottom: CGFloat = 0
    private var measuredKey: String?
    /// What `show` last asked for; nil once hidden.
    private var request: [String: Any]?
    /// The overlay engine has drawn its first frame.
    private var ready = false
    private var appeared = false

    private init() {}

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "show":
            show(call.arguments as? [String: Any] ?? [:])
            result(nil)
        case "hide":
            request = nil
            apply(animated: true)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func show(_ arguments: [String: Any]) {
        request = arguments
        if let content = arguments["content"] as? [String: Any] {
            showNative(content)
        } else {
            label?.isHidden = true
            controller?.view.isHidden = false
            if engine == nil {
                // Shown once its engine has drawn, not on the label's readiness.
                ready = false
                start()
            } else {
                contentChannel?.invokeMethod("update", arguments: arguments)
            }
        }
        apply(animated: true)
    }

    /// Draws [content]'s symbol and text natively: nothing to wait for.
    private func showNative(_ content: [String: Any]) {
        let label = self.label ?? {
            let view = NativeOverlayLabelView()
            strip.panel.addSubview(view)
            self.label = view
            return view
        }()
        label.configure(content)
        label.isHidden = false
        controller?.view.isHidden = true
        ready = true
        strip.setNeedsLayout()
        // Said once as it arrives, as a live region would be.
        if let text = content["text"] as? String, !shown {
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }

    private func start() {
        let options = FlutterEngineGroupOptions()
        options.entrypoint = "commonOverlayMain"
        let engine = NativeEngines.group.makeEngine(with: options)
        self.engine = engine
        let channel = FlutterMethodChannel(name: "flutter_native_widgets/overlay_content",
                                           binaryMessenger: engine.binaryMessenger)
        contentChannel = channel
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { result(nil); return }
            switch call.method {
            case "bootstrap":
                result(self.request ?? [:])
            case "ready":
                result(nil)
                guard !self.ready else { return }
                self.ready = true
                self.apply(animated: true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        let controller = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        controller.loadViewIfNeeded()
        controller.view.isUserInteractionEnabled = false
        controller.view.backgroundColor = .clear
        self.controller = controller
        strip.panel.addSubview(controller.view)
    }

    /// The window's root view controller changed (the native navigation took
    /// over from the page's Flutter controller): move the strip onto it.
    func rootChanged() {
        apply(animated: false)
    }

    /// A navigation controller laid out: keep the strip on top and over the bar.
    func relayout() {
        guard shown else { return }
        // The window's root can change under it (the search tabs take over).
        if let root = windowProvider()?.rootViewController, root !== self.root {
            apply(animated: false)
        }
        guard let parent = strip.superview else { return }
        if parent.subviews.last !== strip { parent.bringSubviewToFront(strip) }
        strip.setNeedsLayout()
    }

    private func apply(animated: Bool) {
        guard let window = windowProvider(), let root = window.rootViewController else { return }
        if self.root !== root { attach(to: root) }
        if let color = (request?["color"] as? NSNumber)?.intValue {
            strip.panel.backgroundColor = UIColor(argb: color)
        }
        root.view.bringSubviewToFront(strip)
        let visible = ready && request != nil
        guard visible != shown else { return }
        shown = visible
        // The strip lies behind the status bar while it shows.
        NativeNavigationHost.installed?.content.setNeedsStatusBarAppearanceUpdate()
        root.setNeedsStatusBarAppearanceUpdate()
        if visible {
            strip.isHidden = false
            strip.setNeedsLayout()
            strip.layoutIfNeeded()
            appear()
            // Slides down from the top edge, across the status bar, until it
            // lies over the navigation bar.
            strip.panel.transform = animated ? strip.raised : .identity
            if animated {
                UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1,
                               initialSpringVelocity: 0, options: [.beginFromCurrentState]) {
                    self.strip.panel.transform = .identity
                }
            }
        } else {
            let close = { [self] in
                // A show that arrived while the strip faded keeps it.
                guard !shown else { strip.panel.transform = .identity; return }
                strip.isHidden = true
            }
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0,
                               options: [.curveEaseIn, .beginFromCurrentState],
                               animations: { self.strip.panel.transform = self.strip.raised },
                               completion: { _ in close() })
            } else {
                close()
            }
        }
    }

    /// The navigation bar's frame in `strip`'s coordinates: the band the
    /// strip's content sits in (its colour runs up to the top edge). The bar
    /// on screen when one runs across the top. Otherwise (no native bar, or the iPhone Duo's in
    /// the vertical strip) the band UIKit lays out for an inline title in this
    /// window, measured, never assumed.
    fileprivate func band(in strip: UIView) -> CGRect {
        let insets = strip.safeAreaInsets
        let top = insets.top
        if let root, let bar = Self.visibleBar(in: root.view, excluding: strip) {
            let frame = bar.convert(bar.bounds, to: strip)
            if frame.height > 0 { return frame }
        }
        let width = max(0, strip.bounds.width - insets.left - insets.right)
        let key = "\(strip.bounds.size)|\(insets)|\(strip.traitCollection.verticalSizeClass.rawValue)"
        if measuredKey != key || measuredBottom <= top, let root,
           let contentTop = DuoTitleBand.inlineContentTop(in: root) {
            measuredKey = key
            measuredBottom = root.view.convert(CGPoint(x: 0, y: contentTop), to: strip).y
        }
        return CGRect(x: insets.left, y: top, width: width, height: max(0, measuredBottom - top))
    }

    /// The navigation bar on screen that runs across the top, whichever
    /// controller owns it (the root's, a tab's, search's): the visible
    /// horizontal bar highest in `view`.
    private static func visibleBar(in view: UIView, excluding strip: UIView) -> UINavigationBar? {
        var best: (bar: UINavigationBar, top: CGFloat)?
        func visit(_ node: UIView) {
            guard node !== strip, !node.isHidden, node.alpha > 0.01 else { return }
            if let bar = node as? UINavigationBar {
                let frame = bar.convert(bar.bounds, to: view)
                if frame.width > frame.height, frame.intersects(view.bounds),
                   best.map({ frame.minY < $0.top }) ?? true {
                    best = (bar, frame.minY)
                }
                return
            }
            node.subviews.forEach(visit)
        }
        visit(view)
        return best?.bar
    }

    private func attach(to root: UIViewController) {
        strip.removeFromSuperview()
        strip.frame = root.view.bounds
        strip.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        root.view.addSubview(strip)
        self.root = root
        // The new root's bars are laid out after this; measure again then.
        strip.setNeedsLayout()
        DispatchQueue.main.async { [weak self] in self?.strip.setNeedsLayout() }
    }

    /// The overlay controller has no parent controller, so UIKit sends it no
    /// appearance; without one its engine never reports the view as shown.
    private func appear() {
        guard !appeared, let controller, controller.view.window != nil else { return }
        appeared = true
        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()
    }
}

/// Covers the root view and draws the overlay content over the navigation
/// bar's band. Touches outside the band pass through.
final class NativeOverlayStripView: UIView {
    /// From the top edge to the bottom of the navigation bar: the status
    /// bar area and the bar's band.
    let content = UIView()
    /// The strip's colour and Flutter content, moved as one.
    let panel = UIView()

    /// The panel's place just above the top edge, out of sight.
    var raised: CGAffineTransform {
        CGAffineTransform(translationX: 0, y: -max(content.frame.maxY, 1))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        content.clipsToBounds = true
        addSubview(content)
        content.addSubview(panel)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, content.frame.contains(point) else { return nil }
        return content
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isHidden else { return }
        // The colour runs from the top edge; the content stays in the band.
        let band = NativeOverlayContainer.shared.band(in: self)
        content.frame = CGRect(x: band.minX, y: 0, width: band.width, height: band.maxY)
        panel.bounds = content.bounds
        panel.center = CGPoint(x: content.bounds.midX, y: content.bounds.midY)
        for view in panel.subviews {
            view.frame = CGRect(x: 0, y: band.minY, width: band.width, height: band.height)
        }
    }
}

/// A symbol and a line of text, centred in the strip's band: the whole
/// content of a strip that needs no engine.
final class NativeOverlayLabelView: UIView {
    private let stack = UIStackView()
    private let symbol = UIImageView()
    private let text = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        symbol.contentMode = .scaleAspectFit
        symbol.setContentHuggingPriority(.required, for: .horizontal)
        text.numberOfLines = 1
        text.lineBreakMode = .byTruncatingTail
        // A fixed size, like the bar it covers: it must fit the band.
        text.adjustsFontForContentSizeCategory = false
        stack.addArrangedSubview(symbol)
        stack.addArrangedSubview(text)
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
        ])
        isAccessibilityElement = true
        accessibilityTraits = .staticText
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    /// `symbol` (an SF Symbol name), `text`, `foreground` (ARGB), and
    /// optional `fontSize` and `symbolSize` in points.
    func configure(_ content: [String: Any]) {
        let foreground = (content["foreground"] as? NSNumber)
            .map { UIColor(argb: $0.intValue) } ?? .white
        let fontSize = (content["fontSize"] as? NSNumber).map { CGFloat($0.doubleValue) } ?? 15
        let symbolSize = (content["symbolSize"] as? NSNumber).map { CGFloat($0.doubleValue) } ?? fontSize
        let value = content["text"] as? String ?? ""
        text.attributedText = NSAttributedString(string: value, attributes: [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: foreground,
            .kern: -0.2,
        ])
        if let name = content["symbol"] as? String {
            let configuration = UIImage.SymbolConfiguration(pointSize: symbolSize, weight: .semibold)
            symbol.image = UIImage(systemName: name, withConfiguration: configuration)
            symbol.tintColor = foreground
            symbol.isHidden = symbol.image == nil
        } else {
            symbol.isHidden = true
        }
        accessibilityLabel = value
    }
}
