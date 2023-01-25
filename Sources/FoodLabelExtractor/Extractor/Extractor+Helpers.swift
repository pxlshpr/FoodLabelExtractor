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
}
