import SwiftUI
import VisionSugar
import SwiftHaptics
import SwiftSugar

extension Extractor {
    
    func cropTextBoxes() {
        guard let image else { return }

        cropTask = Task.detached { [weak self] in
            guard let self else { return }
            
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                self?.croppingStatus = .started
            }
            print("✂️ Starting cropping")
            
            var croppedImages: [RecognizedText : UIImage] = [:]
            for text in await self.allTexts {
                guard !Task.isCancelled else { return }
                guard let croppedImage = await image.cropped(boundingBox: text.boundingBox) else {
                    print("Couldn't get image for box: \(text)")
                    continue
                }
                print("✂️ Cropped: \(text.string)")
                croppedImages[text] = croppedImage
            }

            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self, croppedImages] in
                print("✂️ Cropping completed, setting dict and status")
                self?.allCroppedImages = croppedImages
                self?.croppingStatus = .complete
            }
            
            if await self.dismissState == .waitingForCroppedImages {
                print("✂️ Was waitingToShowCroppedImages, so showing now")
                await self.showCroppedImages()
            }
        }
    }
    
    func showCroppedImages() {
        print("✂️ Showing cropped images")
        showCroppedImagesTask = Task.detached { [weak self] in
            
            guard let self else { return }
            guard !Task.isCancelled else { return }

            for (text, cropped) in await self.allCroppedImages {
                guard !Task.isCancelled else { return }
                guard await self.textsToCrop.contains(where: { $0.id == text.id }) else {
                    print("✂️ Not including: \(text.string) since it's not in textsToCrop")
                    continue
                }
                
                print("✂️ Getting rect for: \(text.string)")
                let correctedRect = await self.rectForText(text)
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    let randomWiggleAngles = self.randomWiggleAngles
                    
                    if !self.croppedImages.contains(where: { $0.2 == text.id }) {
                        self.croppedImages.append((
                            cropped,
                            correctedRect,
                            text.id,
                            Angle.degrees(CGFloat.random(in: -20...20)),
                            randomWiggleAngles
                        ))
                    }
                }
            }
            
            guard !Task.isCancelled else { return }
            Haptics.selectionFeedback()
            
            guard !Task.isCancelled else { return }
            await MainActor.run { [weak self] in
                guard let self else { return }
                withAnimation {
                    self.textBoxes = []
                    self.dismissState = .waitingForCroppedImages
//                    self.scannedTextBoxes = self.getScannedTextBoxes
                }
            }
            
            try await sleepTask(0.1, tolerance: 0.01)

            guard !Task.isCancelled else { return }
//            await self.stackCroppedImagesOnTop()
        }
    }
}

extension Extractor {
    
    var randomWiggleAngles: (Angle, Angle, Angle, Angle) {
        let left1 = Angle.degrees(CGFloat.random(in: (-8)...(-2)))
        let right1 = Angle.degrees(CGFloat.random(in: 2...8))
        let left2 = Angle.degrees(CGFloat.random(in: (-8)...(-2)))
        let right2 = Angle.degrees(CGFloat.random(in: 2...8))
        let leftFirst = Bool.random()
        if leftFirst {
            return (left1, right1, left2, right2)
        } else {
            return (right1, left1, right2, left2)
        }
    }

    func rectForText(_ text: RecognizedText) -> CGRect {
        .zero
//        if let lastContentSize, let lastContentOffset {
//            print("    📐 Have contentSize and contentOffset, so calculating")
//            return getRectForText(text, contentSize: lastContentSize, contentOffset: lastContentOffset)
//        }
//        print("    📐 DON'T Have contentSize and contentOffset, doing it manually")
//
//        //TODO: Try and always have lastContentSize and lastContentOffset and calculate using those
//        let boundingBox = text.boundingBox
//        guard let image else { return .zero }
//
//        let screen = UIScreen.main.bounds
//
//        let correctedRect: CGRect
//        if self.isCamera {
//            let scaledWidth: CGFloat = (image.size.width * screen.height) / image.size.height
//            let scaledSize = CGSize(width: scaledWidth, height: screen.height)
//            let rectForSize = boundingBox.rectForSize(scaledSize)
//
//            correctedRect = CGRect(
//                x: rectForSize.origin.x - ((scaledWidth - screen.width) / 2.0),
//                y: rectForSize.origin.y,
//                width: rectForSize.size.width,
//                height: rectForSize.size.height
//            )
//
//            print("🌱 box.boundingBox: \(boundingBox)")
//            print("🌱 scaledSize: \(scaledSize)")
//            print("🌱 rectForSize: \(rectForSize)")
//            print("🌱 correctedRect: \(correctedRect)")
//            print("🌱 image.boundingBoxForScreenFill: \(image.boundingBoxForScreenFill)")
//
//
//        } else {
//
//            let rectForSize: CGRect
//            let x: CGFloat
//            let y: CGFloat
//
//            if image.size.widthToHeightRatio > screen.size.widthToHeightRatio {
//                /// This means we have empty strips at the top, and image gets width set to screen width
//                let scaledHeight = (image.size.height * screen.width) / image.size.width
//                let scaledSize = CGSize(width: screen.width, height: scaledHeight)
//                rectForSize = boundingBox.rectForSize(scaledSize)
//                x = rectForSize.origin.x
//                y = rectForSize.origin.y + ((screen.height - scaledHeight) / 2.0)
//
//                print("🌱 scaledSize: \(scaledSize)")
//            } else {
//                let scaledWidth = (image.size.width * screen.height) / image.size.height
//                let scaledSize = CGSize(width: scaledWidth, height: screen.height)
//                rectForSize = boundingBox.rectForSize(scaledSize)
//                x = rectForSize.origin.x + ((screen.width - scaledWidth) / 2.0)
//                y = rectForSize.origin.y
//            }
//
//            correctedRect = CGRect(
//                x: x,
//                y: y,
//                width: rectForSize.size.width,
//                height: rectForSize.size.height
//            )
//
//            print("🌱 rectForSize: \(rectForSize)")
//            print("🌱 correctedRect: \(correctedRect), screenHeight: \(screen.height)")
//        }
//        return correctedRect
    }
}
