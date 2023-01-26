import SwiftUI

extension Extractor {
    
    func setState(to newState: ExtractorState) {
        withAnimation {
            self.state = newState
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
        extractedColumns.selectedColumnIndex = index
        showColumnTextBoxes()
    }
}
