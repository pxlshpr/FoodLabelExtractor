import SwiftUI
import SwiftSugar
import SwiftHaptics
import FoodLabelScanner

extension Extractor {

    func detectTexts() {
        guard let image else { return }
        setState(to: .detecting)

        scanTask = Task.detached { [weak self] in
            
            guard let self else { return }
            
            Haptics.selectionFeedback()
            
            guard !Task.isCancelled else { return }
            //TODO: Bring back camera
//            if await self.isCamera {
//                await MainActor.run { [weak self] in
//                    withAnimation {
//                        self?.hideCamera = true
//                    }
//                }
//            } else {
                /// Ensure the sliding up animation is complete first
                try await sleepTask(K.Pipeline.appearanceTransitionDelay, tolerance: K.Pipeline.tolerance)
//            }
            
            /// Now capture recognized texts
            /// - captures all the RecognizedTexts
            guard !Task.isCancelled else { return }
            let textSet = try await image.recognizedTextSet(for: .accurate, includeBarcodes: true)
            await MainActor.run { [weak self] in
                withAnimation {
                    self?.textSet = textSet
                }
            }
            
            guard !Task.isCancelled else { return }
            let textBoxes = await self.textBoxesForAllRecognizedTexts
            
            Haptics.selectionFeedback()

            guard !Task.isCancelled else { return }
            await MainActor.run {  [weak self] in
                guard let self else { return }
                self.setState(to: .classifying)
                withAnimation {
                    self.textBoxes = textBoxes
                }
            }

            /// Ensure the shimmer effect displays for a minimum duration
            try await sleepTask(K.Pipeline.minimumClassifySeconds, tolerance: K.Pipeline.tolerance)
            
            guard !Task.isCancelled else { return }
            
            try await self.classify()
        }
    }
    
    func classify() async throws {
        
        guard let textSet else { return }

        classifyTask = Task.detached { [weak self] in
            guard let self else { return }
            let scanResult = textSet.scanResult

            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.scanResult = scanResult
//                self.showingBlackBackground = false
            }
            
            guard !Task.isCancelled else { return }

//            await self.startCroppingImages()

            if scanResult.columnCount == 2 {
//                try await self.showColumnPicker()
            } else {
                try await self.showValuesPicker()
            }
        }
    }
    
    func showValuesPicker() async throws {
        
        setState(to: .awaitingConfirmation)
        extractNutrients()
        Haptics.feedback(style: .soft)

        await zoomToColumns()
    }
    
    func extractNutrients() {
        guard let scanResult,
              let firstAttribute = scanResult.nutrientAttributes.first
        else { return }
        
        withAnimation {
            extractedNutrients = scanResult.extractedNutrientsForColumn(extractedColumns.selectedColumnIndex)
        }
        
        currentAttribute = firstAttribute
        textBoxes = []
        showFocusedTextBox()
    }

    func zoomToColumns() async {
        guard let imageSize = image?.size,
              let boundingBox = scanResult?.columnsWithAttributesBoundingBox
        else { return }
        
        let columnZoomBox = ZoomBox(
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
                userInfo: [Notification.ZoomableScrollViewKeys.zoomBox: columnZoomBox]
            )
        }
    }
}
