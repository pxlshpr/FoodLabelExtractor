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
        case .deleteCurrentAttribute:
            deleteCurrentAttribute()
        case .moveToAttribute(let attribute):
            moveToAttribute(attribute)
        case .toggleAttributeConfirmation(let attribute):
            toggleAttributeConfirmation(attribute)
        default:
            break
        }
    }

    func deselectCurrentAttribute() {
        withAnimation(.interactiveSpring()) {
            currentAttribute = nil
            showTextBoxesForCurrentAttribute()
        }
    }
    
    func confirmCurrentAttribute() {
        confirmCurrentAttributeAndMoveToNext()
        showTextBoxesForCurrentAttribute()
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
    
    func moveToAttribute(_ attribute: Attribute, animation: Animation = .interactiveSpring()) {
        Haptics.selectionFeedback()

        withAnimation(animation) {
            self.currentAttribute = attribute
            textFieldAmountString = currentAmountString
        }
        
        NotificationCenter.default.post(
            name: .scannerDidChangeAttribute,
            object: nil,
            userInfo: [Notification.ScannerKeys.nextAttribute: attribute]
        )
        
        withAnimation(animation) {
            showTextBoxes(for: attribute)
        }
    }
    
    func deleteCurrentAttribute() {
        guard let currentAttribute else { return }
        guard let index = extractedNutrients.firstIndex(where: { $0.attribute == currentAttribute })
        else { return }
        
        extractedNutrients.remove(at: index)
    }
    
    func toggleAttributeConfirmation(_ attribute: Attribute) {
        guard let index = extractedNutrients.firstIndex(where: { $0.attribute == attribute }) else {
            return
        }
        Haptics.feedback(style: .soft)
        withAnimation {
            extractedNutrients[index].isConfirmed.toggle()
        }
        
        checkIfAllNutrientsAreConfirmed()

//        /// If we've confirmed it and there are unconfirmed ones left, move to the next one, otherwise move to the toggled attribute
//        let attributeMovedTo: Attribute
//        if scannerNutrients[index].isConfirmed, containsUnconfirmedAttributes,
//           let nextAttributeToToggled = nextUnconfirmedAttribute(to: attribute)
//        {
//            attributeMovedTo = nextAttributeToToggled
//        } else {
//            attributeMovedTo = attribute
//        }
//        moveToAttribute(attributeMovedTo)
//        return attributeMovedTo
    }
}
