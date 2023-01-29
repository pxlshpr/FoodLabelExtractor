import UIKit
import VisionSugar
import FoodLabelScanner

public struct ExtractorOutput {
    let scanResult: ScanResult?
    let extractedNutrients: [ExtractedNutrient]
    let image: UIImage
    let croppedImages: [RecognizedText : UIImage]
}
