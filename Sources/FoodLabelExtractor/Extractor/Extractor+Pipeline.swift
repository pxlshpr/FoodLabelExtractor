import SwiftUI
import SwiftSugar
import SwiftHaptics
import FoodLabelScanner
import VisionSugar

extension Extractor {

    func handleCapturedImage(_ image: UIImage) {
        self.image = image
        
        /// Place the image where we last saw it in the camera view finder
        withAnimation(.interactiveSpring()) {
            transitionState = .setup
            showingCamera = false
        }

        /// Now animate it downwards to where it will bein the extractor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            withAnimation(.easeInOut(duration: 0.7)) {
            withAnimation {
                self.transitionState = .startTransition
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.transitionState = .endTransition
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    withAnimation {
                        self.transitionState = .tearDown
//                    }
                }
            }
        }
    }

    
    func detectTexts() {
        guard let image else { return }
        setState(to: .detecting)

        scanTask = Task.detached(priority: .low) { [weak self] in
            
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

        classifyTask = Task.detached(priority: .low) { [weak self] in
            guard let self else { return }
            let scanResult = textSet.scanResult

            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.scanResult = scanResult
//                self.showingBlackBackground = false
            }
            
            guard !Task.isCancelled else { return }

            print("✂️ About to call cropTextBoxes()")
//            await self.cropTextBoxes()
            print("✂️ Returned from cropTextBoxes()")

            if scanResult.columnCount == 2 {
                try await self.showColumnPicker()
            } else {
                try await self.extractNutrients()
            }
        }
    }

    func extractNutrients() async throws {
        guard let scanResult else { return }
        let extractedNutrients = scanResult.extractedNutrientsForColumn(
            extractedColumns.selectedColumnIndex,
            includeSingleColumnValues: true
        )

//        guard let firstAttribute = extractedNutrients.first?.attribute else {
        guard let _ = extractedNutrients.first?.attribute else {
            //TODO: Handle no attributes being read
            return
        }
        
        Haptics.feedback(style: .soft)
        setState(to: .awaitingConfirmation)

        withAnimation {
            self.extractedNutrients = extractedNutrients
        }
        
//        currentAttribute = firstAttribute
        selectableTextBoxes = []
        textBoxes = []
        showTextBoxesForCurrentAttribute()

        await zoomToNutrients()
    }
    
    func showColumnPicker() async throws {
        guard let scanResult else { return }

        setState(to: .awaitingColumnSelection)

        Haptics.feedback(style: .soft)
//        withAnimation {
//            showingColumnPicker = true
//            showingColumnPickerUI = true
//        }

        extractedColumns = scanResult.extractedColumns
        showColumnTextBoxes()
//        selectedImageTexts = columns.selectedImageTexts

        await zoomToNutrients()
    }
}
