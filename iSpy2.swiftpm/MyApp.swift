import SwiftUI
import CoreText
import CoreGraphics

@available(iOS 18.0, *)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .landscape
    }
}

@available(iOS 18.0, *)
@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        Self.registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    forceLandscape()
                }
        }
    }

    private func forceLandscape() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
        scene.requestGeometryUpdate(geometryPreferences) { _ in }
        for window in scene.windows {
            window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    private static func registerCustomFonts() {
        let fileName = "FredokaOne-Regular"
        let fileExtension = "ttf"

        let candidates = [Bundle.module, Bundle.main] + Bundle.allBundles
        for bundle in candidates {
            if let url = bundle.url(forResource: fileName, withExtension: fileExtension),
               let data = try? Data(contentsOf: url) as CFData,
               let provider = CGDataProvider(data: data),
               let font = CGFont(provider)
            {
                CTFontManagerRegisterGraphicsFont(font, nil)
                return
            }
        }
    }
}
