import SwiftUI
import VisionSugar

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
