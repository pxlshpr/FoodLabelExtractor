import Foundation
import PrepDataTypes
import VisionSugar
import FoodLabelScanner

extension Extractor {
    var textFieldAmountString: String {
        get { internalTextfieldString }
        set {
            guard !newValue.isEmpty else {
                internalTextfieldDouble = nil
                internalTextfieldString = newValue
                return
            }
            guard let double = Double(newValue) else {
                return
            }
            self.internalTextfieldDouble = double
            self.internalTextfieldString = newValue
        }
    }
    
    var currentUnit: FoodLabelUnit {
        currentNutrient?.value?.unit ?? .g
    }

    var currentAmountString: String {
        guard let amount = currentNutrient?.value?.amount else { return "" }
        return amount.cleanAmount
    }
    
    var currentNutrient: ExtractedNutrient? {
        guard let currentAttribute else { return nil }
        return extractedNutrients.first(where: { $0.attribute == currentAttribute })
    }
    
    var currentAttributeText: RecognizedText? {
        guard let currentNutrient else { return nil }
        return currentNutrient.attributeText
    }
    
    var currentValueText: RecognizedText? {
        guard let currentNutrient else { return nil }
        return currentNutrient.valueText
    }
    
    var currentUnitString: String {
        guard let unit = currentNutrient?.value?.unit else { return "" }
        return unit.description
    }
    
    var shouldShowDeleteForCurrentAttribute: Bool {
        currentNutrient?.isConfirmed == true
        && state != .showingKeyboard
    }
    
    var nextUnconfirmedAttribute: Attribute? {
        nextUnconfirmedAttribute(to: currentAttribute)
    }

    /// Returns the next element to `attribute` in `nutrients`,
    /// cycling back to the first once the end is reached.
    func nextUnconfirmedAttribute(to attribute: Attribute? = nil) -> Attribute? {
        let index: Int
        if let currentAttributeIndex = extractedNutrients.firstIndex(where: { $0.attribute == attribute }) {
            index = currentAttributeIndex
        } else {
            index = 0
        }
        
        /// Make sure we only loop once around the nutrients
        let maxNumberOfHops = extractedNutrients.count
        var numberOfHops = 0
        var indexToCheck = index >= extractedNutrients.count - 1 ? 0 : index + 1
        while numberOfHops < maxNumberOfHops {
            if !extractedNutrients[indexToCheck].isConfirmed {
                return extractedNutrients[indexToCheck].attribute
            }
            indexToCheck += 1
            if indexToCheck >= extractedNutrients.count - 1 {
                indexToCheck = 0
            }
            numberOfHops += 1
        }
        return nil
    }    
}
