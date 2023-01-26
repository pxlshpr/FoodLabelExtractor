import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar

extension AttributesLayer {
    
    func tappedActionButton() {
        resignFocusOfSearchTextField()
        if extractor.shouldShowDeleteForCurrentAttribute {
            withAnimation {
                actionHandler(.deleteCurrentAttribute)
            }
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
        if extractor.currentAttribute == attribute {
            tappedValueButton()
        } else {
            actionHandler(.moveToAttribute(attribute))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                tappedValueButton()
            }
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
