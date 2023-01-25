import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar

extension AttributesLayer {
    
    func tappedActionButton() {
        resignFocusOfSearchTextField()
        if extractor.shouldShowDeleteForCurrentAttribute {
            actionHandler(.deleteCurrentAttribute)
        } else {
            actionHandler(.confirmCurrentAttribute)
        }
    }
    
    func tappedValueButton() {
        Haptics.feedback(style: .soft)
        isFocused = true
        withAnimation {
            showKeyboardForCurrentAttribute()
        }
        extractor.showTappableTextBoxesForCurrentAttribute()
    }
    
    func tappedCellValue(for attribute: Attribute) {
        actionHandler(.moveToAttribute(attribute))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            tappedValueButton()
        }
    }
    
    //MARK: - Helpers Actions
    
    func showKeyboardForCurrentAttribute() {
        extractor.state = .showingKeyboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                hideBackground = true
            }
        }
    }
    
    func resignFocusOfSearchTextField() {
        isFocused = false
        withAnimation {
            extractor.hideTappableTextBoxesForCurrentAttribute()
        }
    }
}
