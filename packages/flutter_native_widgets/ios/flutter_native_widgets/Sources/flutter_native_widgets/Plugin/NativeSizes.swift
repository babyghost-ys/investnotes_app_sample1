import Flutter
import UIKit

/// Answers one engine's synchronous size questions from Dart.
///
/// Dart calls these through `dart:ffi` while it builds a widget, before the
/// widget's platform view exists, so the widget lays out at UIKit's size in
/// its first frame. Every answer comes from a control built for the
/// measurement and thrown away, or from a value UIKit already reported:
/// nothing here touches a view on screen.
final class NativeSizes: NativeSizesApi {
    /// The view controller whose traits the measured controls will have.
    private let hostProvider: () -> UIViewController?

    init(hostProvider: @escaping () -> UIViewController?) {
        self.hostProvider = hostProvider
    }

    func tabBarHeight(width: Double, labels: [String]) throws -> Double? {
        guard width.isFinite, width > 0 else { return nil }
        let bar = UITabBar(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        adoptHostTraits(bar)
        bar.items = labels.enumerated().map { index, label in
            UITabBarItem(title: label, image: nil, tag: index)
        }
        let height = bar.sizeThatFits(
            CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        return height.isFinite && height > 0 ? Double(height) : nil
    }

    func popupMenuButtonWidth(
        title: String?, iconName: String?, iconSize: Double?, style: String
    ) throws -> Double? {
        let button = UIButton(type: .system)
        adoptHostTraits(button)
        iOS26PopupMenuButtonView.applyStyle(style, round: false, to: button)
        iOS26PopupMenuButtonView.setContent(
            title: title, icon: iconName, iconSize: iconSize.map { CGFloat($0) }, of: button)
        let width = button.intrinsicContentSize.width
        return width.isFinite && width > 0 ? Double(width) : nil
    }

    func searchHeaderLayout() throws -> SearchHeaderLayout? {
        guard let window = hostProvider()?.viewIfLoaded?.window else { return nil }
        return SearchHeaderMemory.layout(in: window)
    }

    /// A control outside a window has no size classes or text size of its
    /// own. Give it the host's, so it measures as it will once shown there.
    private func adoptHostTraits(_ view: UIView) {
        guard #available(iOS 17.0, *), let traits = hostProvider()?.viewIfLoaded?.traitCollection
        else { return }
        view.traitOverrides.userInterfaceIdiom = traits.userInterfaceIdiom
        view.traitOverrides.horizontalSizeClass = traits.horizontalSizeClass
        view.traitOverrides.verticalSizeClass = traits.verticalSizeClass
        view.traitOverrides.preferredContentSizeCategory = traits.preferredContentSizeCategory
        view.traitOverrides.displayScale = traits.displayScale
    }
}

/// Where UIKit last laid out the navigation search header, by window shape.
///
/// The header's height comes from the window's real navigation bar, which
/// exists only once a search page is on screen. A later search page in a
/// window of the same shape starts from this measurement instead of from a
/// guess, and UIKit's report still corrects it.
enum SearchHeaderMemory {
    private struct WindowShape: Hashable {
        let width: CGFloat
        let height: CGFloat
        let safeTop: CGFloat

        init(_ window: UIWindow) {
            width = window.bounds.width
            height = window.bounds.height
            safeTop = window.safeAreaInsets.top
        }
    }

    private static var layouts: [WindowShape: SearchHeaderLayout] = [:]

    static func remember(height: CGFloat, bottom: CGFloat, in window: UIWindow) {
        layouts[WindowShape(window)] = SearchHeaderLayout(
            height: Double(height), bottom: Double(bottom))
    }

    static func layout(in window: UIWindow) -> SearchHeaderLayout? {
        layouts[WindowShape(window)]
    }
}
