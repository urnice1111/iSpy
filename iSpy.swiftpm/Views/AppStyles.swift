//import SwiftUI
//
//// MARK: - App Typography
//
///// Consistent typography using SF Rounded for a friendly, approachable feel
//enum AppFont {
//    /// Large titles - 34pt bold rounded
//    static func largeTitle() -> Font {
//        .system(size: 34, weight: .bold, design: .rounded)
//    }
//    
//    /// Title - 28pt bold rounded
//    static func title() -> Font {
//        .system(size: 28, weight: .bold, design: .rounded)
//    }
//    
//    /// Title 2 - 22pt bold rounded
//    static func title2() -> Font {
//        .system(size: 22, weight: .bold, design: .rounded)
//    }
//    
//    /// Title 3 - 20pt semibold rounded
//    static func title3() -> Font {
//        .system(size: 20, weight: .semibold, design: .rounded)
//    }
//    
//    /// Headline - 17pt semibold rounded
//    static func headline() -> Font {
//        .system(size: 17, weight: .semibold, design: .rounded)
//    }
//    
//    /// Body - 17pt regular rounded
//    static func body() -> Font {
//        .system(size: 17, weight: .regular, design: .rounded)
//    }
//    
//    /// Callout - 16pt regular rounded
//    static func callout() -> Font {
//        .system(size: 16, weight: .regular, design: .rounded)
//    }
//    
//    /// Subheadline - 15pt regular rounded
//    static func subheadline() -> Font {
//        .system(size: 15, weight: .regular, design: .rounded)
//    }
//    
//    /// Footnote - 13pt regular rounded
//    static func footnote() -> Font {
//        .system(size: 13, weight: .regular, design: .rounded)
//    }
//    
//    /// Caption - 12pt regular rounded
//    static func caption() -> Font {
//        .system(size: 12, weight: .regular, design: .rounded)
//    }
//    
//    /// Caption 2 - 11pt regular rounded
//    static func caption2() -> Font {
//        .system(size: 11, weight: .regular, design: .rounded)
//    }
//    
//    /// Points display - 50pt bold rounded
//    static func points() -> Font {
//        .system(size: 50, weight: .bold, design: .rounded)
//    }
//    
//    /// Points label - 35pt medium rounded
//    static func pointsLabel() -> Font {
//        .system(size: 35, weight: .medium, design: .rounded)
//    }
//}
//
//// MARK: - Primary Button Style
//
///// Main action button with accent color background
//struct PrimaryButtonStyle: ButtonStyle {
//    var isLoading: Bool = false
//    var isDisabled: Bool = false
//    
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(AppFont.headline())
//            .foregroundStyle(.white)
//            .frame(maxWidth: .infinity)
//            .frame(height: 54)
//            .background(
//                Capsule()
//                    .fill(isDisabled ? Color("ButtonColor").opacity(0.5) : Color("ButtonColor"))
//            )
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .opacity(configuration.isPressed ? 0.9 : 1.0)
//            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
//    }
//}
//
//extension ButtonStyle where Self == PrimaryButtonStyle {
//    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
//    
//    static func primary(isLoading: Bool = false, isDisabled: Bool = false) -> PrimaryButtonStyle {
//        PrimaryButtonStyle(isLoading: isLoading, isDisabled: isDisabled)
//    }
//}
//
//// MARK: - Secondary Button Style
//
///// Secondary action button with subtle background
//struct SecondaryButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(AppFont.headline())
//            .foregroundStyle(Color("ButtonColor"))
//            .frame(maxWidth: .infinity)
//            .frame(height: 54)
//            .background(
//                Capsule()
//                    .fill(Color("ButtonColor").opacity(0.12))
//            )
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .opacity(configuration.isPressed ? 0.8 : 1.0)
//            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
//    }
//}
//
//extension ButtonStyle where Self == SecondaryButtonStyle {
//    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
//}
//
//// MARK: - Destructive Button Style
//
///// Destructive action button (for reset, delete, etc.)
//struct DestructiveButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(AppFont.body())
//            .foregroundStyle(.red)
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 14)
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.red.opacity(0.1))
//            )
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .opacity(configuration.isPressed ? 0.8 : 1.0)
//            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
//    }
//}
//
//extension ButtonStyle where Self == DestructiveButtonStyle {
//    static var destructive: DestructiveButtonStyle { DestructiveButtonStyle() }
//}
//
//// MARK: - Difficulty Badge
//
///// Consistent difficulty indicator across the app
//struct DifficultyBadge: View {
//    let difficulty: Difficulty
//    
//    var difficultyColor: Color {
//        switch difficulty {
//        case .easy: return .green
//        case .medium: return .orange
//        case .hard: return .red
//        }
//    }
//    
//    var body: some View {
//        Text(difficulty.rawValue.capitalized)
//            .font(AppFont.caption())
//            .fontWeight(.semibold)
//            .foregroundStyle(difficultyColor)
//            .padding(.horizontal, 10)
//            .padding(.vertical, 4)
//            .background(
//                Capsule()
//                    .fill(difficultyColor.opacity(0.15))
//            )
//    }
//}
//
//// MARK: - Points Badge
//
///// Consistent points display
//struct PointsBadge: View {
//    let points: Int
//    
//    var body: some View {
//        Text("\(points) pts")
//            .font(AppFont.caption())
//            .foregroundStyle(.secondary)
//    }
//}
//
//// MARK: - Empty State View
//
///// Reusable empty state component
//struct EmptyStateView: View {
//    let icon: String
//    let title: String
//    let message: String?
//    
//    init(icon: String, title: String, message: String? = nil) {
//        self.icon = icon
//        self.title = title
//        self.message = message
//    }
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Image(systemName: icon)
//                .font(.system(size: 60))
//                .foregroundStyle(.secondary)
//            
//            Text(title)
//                .font(AppFont.title3())
//                .foregroundStyle(.primary)
//            
//            if let message = message {
//                Text(message)
//                    .font(AppFont.body())
//                    .foregroundStyle(.secondary)
//                    .multilineTextAlignment(.center)
//            }
//        }
//        .padding(40)
//    }
//}
//
//// MARK: - Section Header
//
///// Consistent section header styling
//struct SectionHeader: View {
//    let title: String
//    
//    var body: some View {
//        HStack {
//            Text(title)
//                .font(AppFont.title3())
//                .foregroundStyle(.primary)
//            Spacer()
//        }
//    }
//}
//
