import Foundation
import SwiftHaptics

extension AttributesLayer {
    
    func tappedPrimaryButton() {
//        resignFocusOfSearchTextField()
//        if isDeleteButton {
//            actionHandler(.deleteCurrentAttribute)
//        } else {
            actionHandler(.confirmCurrentAttribute)
//        }
    }
}
