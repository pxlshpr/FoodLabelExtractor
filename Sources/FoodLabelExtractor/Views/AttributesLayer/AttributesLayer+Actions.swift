import SwiftUI
import SwiftHaptics
import FoodLabelScanner
import VisionSugar

extension AttributesLayer {
    
    func tappedActionButton() {
        resignFocusOfSearchTextField()
        if extractor.shouldShowDeleteForCurrentAttribute {
            withAnimation {
//                actionHandler(.deleteCurrentAttribute)
                extractor.deleteCurrentAttribute()
            }
        } else {
//            actionHandler(.confirmCurrentAttribute)
            extractor.confirmCurrentAttribute()
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
    
    func tappedCell(for attribute: Attribute) {
        if attribute != extractor.currentAttribute {
//            actionHandler(.moveToAttribute(attribute))
            extractor.moveToAttribute(attribute)
        } else {
            extractor.deselectCurrentAttribute()
        }
    }
    
    func tappedCellValue(for attribute: Attribute) {
        if extractor.currentAttribute == attribute {
            tappedValueButton()
        } else {
//            actionHandler(.moveToAttribute(attribute))
            extractor.moveToAttribute(attribute)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
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
