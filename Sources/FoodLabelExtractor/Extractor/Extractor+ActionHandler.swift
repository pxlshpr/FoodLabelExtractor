import SwiftUI
import SwiftHaptics
import PrepDataTypes
import FoodLabelScanner

extension Extractor {
    
    func handleAttributesLayerAction(_ action: AttributesLayerAction) {
        switch action {
//        case .dismiss:
//            viewModel.dismissHandler?()
        case .confirmCurrentAttribute:
            confirmCurrentAttribute()
//        case .deleteCurrentAttribute:
//            deleteCurrentAttribute()
//        case .moveToAttribute(let attribute):
//            moveToAttribute(attribute)
//        case .moveToAttributeAndShowKeyboard(let attribute):
//            moveToAttributeAndShowKeyboard(attribute)
//        case .toggleAttributeConfirmation(let attribute):
//            toggleAttributeConfirmation(attribute)
        default:
            break
        }
    }

    func confirmCurrentAttribute() {
        confirmCurrentAttributeAndMoveToNext()
        showFocusedTextBox()
    }

    func confirmCurrentAttributeAndMoveToNext() {
        guard let currentAttribute else { return }
        guard let index = extractedNutrients.firstIndex(where: { $0.attribute == currentAttribute })
        else { return }

        if !extractedNutrients[index].isConfirmed {
            Haptics.feedback(style: .soft)
            withAnimation {
                extractedNutrients[index].isConfirmed = true
            }
        } else {
            Haptics.selectionFeedback()
        }
        
        if let internalTextfieldDouble {
            extractedNutrients[index].value = FoodLabelValue(
                amount: internalTextfieldDouble,
                unit: pickedAttributeUnit
            )
        }

        checkIfAllNutrientsAreConfirmed()
        
        guard let nextUnconfirmedAttribute else { return }
        moveToAttribute(nextUnconfirmedAttribute)
    }
    
    func moveToAttribute(_ attribute: Attribute) {
        withAnimation {
            self.currentAttribute = attribute
            textFieldAmountString = currentAmountString
        }
        
        NotificationCenter.default.post(
            name: .scannerDidChangeAttribute,
            object: nil,
            userInfo: [Notification.ScannerKeys.nextAttribute: attribute]
        )
    }
    
    
}
