import SwiftUI

extension Extractor {
    
    func setState(to newState: ExtractorState) {
        withAnimation {
            self.state = newState
        }
    }
    
    var textBoxesForAllRecognizedTexts: [TextBox] {
        guard let textSet else { return [] }
        return textSet.texts.map {
            TextBox(
                id: $0.id,
                boundingBox: $0.boundingBox,
                color: .accentColor,
                opacity: 0.8,
                tapHandler: {}
            )
        }
    }
    
    func checkIfAllNutrientsAreConfirmed(unsettingCurrentAttribute: Bool = true) {
        if extractedNutrients.allSatisfy({ $0.isConfirmed }) {
            withAnimation {
                state = .allConfirmed
                if unsettingCurrentAttribute {
                    currentAttribute = nil
                }
            }
        } else {
            withAnimation {
                state = .awaitingConfirmation
            }
        }
    }

}

import PrepDataTypes
import FoodLabelScanner

extension FoodLabelValue {
    mutating func correctUnit(for attribute: Attribute) {
        guard let unit else {
            self.unit = attribute.defaultUnit
            return
        }
        
        if !attribute.supportsUnit(unit) {
            self.unit = attribute.defaultUnit
        }
        return
    }
}
