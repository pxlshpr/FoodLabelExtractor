import SwiftUI
import VisionSugar
import SwiftHaptics

extension Extractor {
    
    func showFocusedTextBox() {
        setTextBoxes(
            attributeText: currentAttributeText,
            valueText: currentValueText
        )
    }
    
    func setTextBoxes(
        attributeText: RecognizedText?,
        valueText: RecognizedText?,
        includeTappableTexts: Bool = false
    ) {
        var textBoxes: [TextBox] = []
        var texts: [RecognizedText] = []
        if let attributeText {
            textBoxes.append(TextBox(
                boundingBox: attributeText.boundingBox,
                color: .accentColor,
                tapHandler: nil
            ))
            texts.append(attributeText)
        }
        if let valueText, valueText.boundingBox != attributeText?.boundingBox {
            textBoxes.append(TextBox(
                boundingBox: valueText.boundingBox,
                color: .accentColor,
                tapHandler: nil
            ))
            texts.append(valueText)
        }

        withAnimation {
            self.textBoxes = textBoxes
        }
        
//        if includeTappableTexts {
//            showTappableTextBoxesForCurrentAttribute()
//        }
    }
    
    func showTappableTextBoxesForCurrentAttribute() {
        guard currentAttribute != nil, let scanResult else { return }
        let texts = scanResult.textsWithFoodLabelValues.filter { text in
            !self.textBoxes.contains(where: { $0.boundingBox == text.boundingBox })
        }
        let textBoxes = texts.map { text in
            TextBox(
                id: text.id,
                boundingBox: text.boundingBox,
                color: .yellow,
                opacity: 0.3,
                tapHandler: { self.tappedText(text) }
            )
        }
        withAnimation {
            self.textBoxes.append(contentsOf: textBoxes)
        }
    }
    
    func hideTappableTextBoxesForCurrentAttribute() {
        /// All we need to do is remove the text boxes that don't have a tap handler assigned to them
        textBoxes = textBoxes.filter { $0.tapHandler == nil }
    }

    func tappedText(_ text: RecognizedText) {
        guard let firstValue = text.firstFoodLabelValue else {
            return
        }
        Haptics.feedback(style: .rigid)
        self.textFieldAmountString = firstValue.amount.cleanAmount
        if let unit = firstValue.unit {
            self.pickedAttributeUnit = unit
        }
        
        //TODO: Now re-generate textboxes so that the selected text is shown
        guard let currentNutrientIndex else { return }
        extractedNutrients[currentNutrientIndex].valueText = text
        extractedNutrients[currentNutrientIndex].value = firstValue
        
        setTextBoxes(
            attributeText: currentAttributeText,
            valueText: text,
            includeTappableTexts: true
        )
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
}
