import SwiftUI

struct K {
    
    static let keyboardHeight: CGFloat = UIScreen.main.bounds.height < 850 ? 291 : 301

    static let topBarHeight: CGFloat = 59

    static let suggestionsBarHeight: CGFloat = 40

    static let topButtonHeight: CGFloat = 50.0
    static let topButtonWidth: CGFloat = 70.0

    static let topButtonCornerRadius: CGFloat = 12.0

    static let topButtonsVerticalPadding: CGFloat = 10.0
    static let topButtonsHorizontalPadding: CGFloat = 10.0

    static let topButtonPaddedHeight = topButtonHeight + (topButtonsVerticalPadding * 2.0)

    static let attributesLayerHeight = keyboardHeight + topButtonPaddedHeight + suggestionsBarHeight
    
    struct Pipeline {
        static let tolerance: Double = 0.005
        static let minimumClassifySeconds: Double = 1.0
        static let appearanceTransitionDelay: Double = 0.2
    }
    
    struct Animations {
        static let bounce: Animation = .interactiveSpring(
            response: 0.35,
            dampingFraction: 0.66,
            blendDuration: 0.35
        )
    }
}
