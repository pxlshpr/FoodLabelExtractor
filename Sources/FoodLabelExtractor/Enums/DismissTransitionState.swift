import Foundation

enum DismissTransitionState {
    
    case notStarted
    case waitingForCroppedImages
    
    case showCroppedImages
    case firstWiggle
    case secondWiggle
    case thirdWiggle
    case fourthWiggle
    case liftingUp
    case stackedOnTop
    

    var shouldShowCroppedImages: Bool {
        switch self {
        case .notStarted, .waitingForCroppedImages:
            return false
        default:
            return true
        }
    }
}
