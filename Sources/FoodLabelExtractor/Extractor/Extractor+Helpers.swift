import SwiftUI

extension Extractor {
    
    func setState(to newState: ExtractorState) {
        withAnimation {
            self.state = newState
        }
    }
    
    var allNutrientsConfirmed: Bool {
        extractedNutrients.allSatisfy({ $0.isConfirmed })
    }
    
    func setAsAllConfirmed(unsettingCurrentAttribute: Bool = true) {
        withAnimation {
            state = .allConfirmed
            if unsettingCurrentAttribute {
                currentAttribute = nil
            }
        }
    }
    
    func checkIfAllNutrientsAreConfirmed(unsettingCurrentAttribute: Bool = true) {
        if allNutrientsConfirmed {
            setAsAllConfirmed(unsettingCurrentAttribute: unsettingCurrentAttribute)
        } else {
            withAnimation {
                state = state == .showingKeyboard ? .showingKeyboard : .awaitingConfirmation
            }
        }
    }
    
    func zoomToNutrients() async {
        guard let imageSize = image?.size,
              let boundingBox = scanResult?.nutrientsBoundingBox(includeAttributes: true)
        else { return }
        
        let zoomBox = ZoomBox(
            boundingBox: boundingBox,
            animated: true,
            padded: true,
            imageSize: imageSize
        )

        await MainActor.run { [weak self] in
            guard let _ = self else { return }
            NotificationCenter.default.post(
                name: .zoomZoomableScrollView,
                object: nil,
                userInfo: [Notification.ZoomableScrollViewKeys.zoomBox: zoomBox]
            )
        }
    }
    
    func selectColumn(_ index: Int) {
        withAnimation {
            extractedColumns.selectedColumnIndex = index
        }
        showColumnTextBoxes()
    }
}
