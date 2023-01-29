import SwiftUI
import VisionSugar
import FoodLabelScanner
import PrepDataTypes

@MainActor
public class Extractor: ObservableObject {

    var isUsingCamera: Bool

    @Published var state: ExtractorState = .loadingImage
    @Published var transitionState: ExtractorCaptureTransitionState = .notStarted
    @Published var dismissState: DismissTransitionState = .notStarted
    @Published var presentationState: PresentationState = .offScreen
    var croppingStatus: CroppingStatus = .idle

    var lastContentOffset: CGPoint? = nil
    var lastContentSize: CGSize? = nil
    var allCroppedImages: [RecognizedText : UIImage] = [:]
    @Published var croppedImages: [(UIImage, CGRect, UUID, Angle, (Angle, Angle, Angle, Angle))] = []

    @Published public var image: UIImage? = nil

    @Published var textSet: RecognizedTextSet? = nil
    
    @Published var textBoxes: [TextBox] = []
    @Published var selectableTextBoxes: [TextBox] = []
    @Published var cutoutTextBoxes: [TextBox] = []

    @Published var scanResult: ScanResult? = nil
    @Published var extractedNutrients: [ExtractedNutrient] = [] {
        didSet {
            /// If we've deleted a nutrient
            if oldValue.count > extractedNutrients.count {
                handleDeletedNutrient(oldValue: oldValue)
            }
        }
    }

//    @Published var showingBoxes = false
    @Published var showingCamera = false
    @Published var showingBackground: Bool = true
    @Published var extractedColumns: ExtractedColumns = ExtractedColumns()

    @Published var currentAttribute: Attribute? = nil {
        didSet {
            pickedAttributeUnit = currentUnit
            textFieldAmountString = currentAmountString
        }
    }
    @Published var pickedAttributeUnit: FoodLabelUnit = .g {
        didSet {
            if currentNutrientIsConfirmed, pickedAttributeUnit != currentNutrient?.value?.unit {
                toggleAttributeConfirmationForCurrentAttribute()
            }
            currentNutrient?.value?.unit = pickedAttributeUnit
        }
    }
    
    @Published var internalTextfieldDouble: Double? = nil {
        didSet {
            if currentNutrientIsConfirmed, internalTextfieldDouble != currentNutrient?.value?.amount {
                toggleAttributeConfirmationForCurrentAttribute()
            }
            removeTextForCurrentAttributeIfDifferentValue()

            if let internalTextfieldDouble {
                currentNutrient?.value?.amount = internalTextfieldDouble
            } else {
                currentNutrient?.value = nil
            }
        }
    }
    @Published var internalTextfieldString: String = ""

    var didDismiss: ((ExtractorOutput?) -> Void)? = nil
    
    /// This flag is used to keep the association with the value's `RecognizedText` when its changed
    /// by tapping a suggestion.
    var ignoreNextValueChange: Bool = false
    
    //MARK: Tasks
    var scanTask: Task<(), Error>? = nil
    var classifyTask: Task<(), Error>? = nil
    var cropTask: Task<(), Error>? = nil
    var showCroppedImagesTask: Task<(), Error>? = nil
    var stackingCroppedImagesOnTopTask: Task<(), Error>? = nil

    //MARK: Init
    public init(isUsingCamera: Bool = false) {
        self.isUsingCamera = isUsingCamera
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(imageViewerViewportChanged),
            name: .zoomScrollViewViewportChanged,
            object: nil
        )        
    }
}

extension Extractor {
    public func setup(
        forCamera: Bool = false,
        didDismiss: @escaping ((ExtractorOutput?) -> Void)
    ) {
        
        isUsingCamera = forCamera

        state = .loadingImage
        transitionState = .notStarted
        dismissState = .notStarted
        croppingStatus = .idle
        presentationState = .offScreen
        
        lastContentOffset = nil
        lastContentSize = nil
        allCroppedImages = [:]
        croppedImages = []

        image = nil
        
        textSet = nil

        textBoxes = []
        selectableTextBoxes = []
        cutoutTextBoxes = []

        scanResult = nil
        extractedNutrients = []

        showingCamera = forCamera
        showingBackground = true
        extractedColumns = ExtractedColumns()
        
        currentAttribute = nil
        pickedAttributeUnit = .g
        internalTextfieldDouble = nil
        internalTextfieldString = ""
        
        self.didDismiss = didDismiss

        ignoreNextValueChange = false
        
        cancelAllTasks()
        scanTask = nil
        classifyTask = nil
        cropTask = nil
        showCroppedImagesTask = nil
        stackingCroppedImagesOnTopTask = nil
    }
    
    func cancelAllTasks() {
        scanTask?.cancel()
        classifyTask?.cancel()
        cropTask?.cancel()
        showCroppedImagesTask?.cancel()
        stackingCroppedImagesOnTopTask?.cancel()
    }
}

extension Extractor {
    func begin() {
        self.detectTexts()
    }
}

extension Extractor {
    
    @objc func imageViewerViewportChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let contentOffset = userInfo[Notification.ZoomableScrollViewKeys.contentOffset] as? CGPoint,
              let contentSize = userInfo[Notification.ZoomableScrollViewKeys.contentSize] as? CGSize
        else { return }
        
        lastContentOffset = contentOffset
        lastContentSize = contentSize
    }

    func setSuggestedValue(_ value: FoodLabelValue) {
        ignoreNextValueChange = true
        print("⭐️ currentUnitString before: \(currentUnitString)")
        textFieldAmountString = value.amount.cleanWithoutRounding
        print("⭐️ currentUnitString after: \(currentUnitString)")
    }
    
    func removeConfirmationStatusForCurrentAttribute() {
        guard currentNutrientIsConfirmed,
              internalTextfieldDouble != currentNutrient?.value?.amount
        else { return }
        
        toggleAttributeConfirmationForCurrentAttribute()
    }
    
    func removeTextForCurrentAttributeIfDifferentValue() {
        guard !ignoreNextValueChange else {
            ignoreNextValueChange = false
            return
        }
        
        guard internalTextfieldDouble != currentNutrient?.value?.amount else {
            return
        }
        withAnimation {
            currentNutrient?.valueText = nil
            showTextBoxesForCurrentAttribute()
        }
    }
    
    func removeTextForCurrentAttributeIfDifferentUnit() {
        guard pickedAttributeUnit != currentNutrient?.value?.unit else {
            return
        }
        withAnimation {
            currentNutrient?.valueText = nil
            showTextBoxesForCurrentAttribute()
        }
    }

    func handleDeletedNutrient(oldValue: [ExtractedNutrient]) {
        //TODO: Uncomment all this code
//        Haptics.warningFeedback()
//        /// get the index of the deleted attribute
//        var deletedIndex: Int? = nil
//        for index in oldValue.indices {
//            if !scannerNutrients.contains(where: { $0.attribute == oldValue[index].attribute }) {
//                deletedIndex = index
//            }
//        }
//        guard let deletedIndex else { return }
//
//        let shouldUnsetCurrentAttributeUponCompletion: Bool
//        if self.currentAttribute == oldValue[deletedIndex].attribute {
//            self.currentAttribute = nil
//            shouldUnsetCurrentAttributeUponCompletion = true
//        } else {
//            shouldUnsetCurrentAttributeUponCompletion = false
//        }
//        checkIfAllNutrientsAreConfirmed(unsettingCurrentAttribute: shouldUnsetCurrentAttributeUponCompletion)
//
////        /// now if the deleted nutrient was the current one, select the next unconfirmed or next-inline attribute to it
////        func moveToNextAttributeIfCurrentWasDeleted() {
////            guard let currentAttribute else { return }
////            guard oldValue[deletedIndex].attribute == currentAttribute else {
////                return
////            }
////            if deletedIndex - 1 < scannerNutrients.count, deletedIndex - 1 >= 0 {
////                if let nextAttributeToDeletedOne = nextUnconfirmedAttribute(to: scannerNutrients[deletedIndex - 1].attribute) {
////                    /// first see if an unconfirmed item exists before the (old, deleted) one, and if so, move to that
////                    moveToAttribute(nextAttributeToDeletedOne)
////                } else {
////                    /// otherwise move to the
////                    moveToAttribute(scannerNutrients[deletedIndex - 1].attribute)
////                }
////            } else {
////                guard !scannerNutrients.isEmpty else {
////                    return
////                }
////                if !scannerNutrients[0].isConfirmed {
////                    moveToAttribute(scannerNutrients[0].attribute)
////                } else if let nextAttributeToFirstOne = nextUnconfirmedAttribute(to: scannerNutrients[0].attribute) {
////                    /// otherwise, we either deleted the first item or have none remaining, so move to the first one if it exists
////                    moveToAttribute(nextAttributeToFirstOne)
////                } else if !scannerNutrients.isEmpty {
////                    moveToAttribute(scannerNutrients[0].attribute)
////                }
////            }
////        }
////
////        moveToNextAttributeIfCurrentWasDeleted()
    }
}
