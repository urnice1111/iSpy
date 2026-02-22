import SwiftUI
import CoreText
import CoreGraphics

@available(iOS 18.0, *)
@main
struct MyApp: App {

    init() {
        Self.registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
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
