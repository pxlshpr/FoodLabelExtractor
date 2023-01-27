import SwiftUI
import VisionSugar
import FoodLabelScanner
import PrepDataTypes

@MainActor
public class Extractor: ObservableObject {

    @Published var state: ExtractorState = .loadingImage

    @Published public var image: UIImage? = nil

    @Published var textSet: RecognizedTextSet? = nil
    
    @Published var textBoxes: [TextBox] = []
    @Published var selectableTextBoxes: [TextBox] = []

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
    @Published var showingBackground: Bool = true
    @Published var extractedColumns: ExtractedColumns = ExtractedColumns()

    @Published var currentAttribute: Attribute? = nil {
        didSet {
            pickedAttributeUnit = currentUnit
            textFieldAmountString = currentAmountString
        }
    }
    @Published var pickedAttributeUnit: FoodLabelUnit = .g
    @Published var internalTextfieldDouble: Double? = nil {
        didSet {
            removeValueTextForCurrentAttributeIfDifferent()
            removeConfirmationStatusForCurrentAttribute()
        }
    }
    @Published var internalTextfieldString: String = ""

    /// This flag is used to keep the association with the value's `RecognizedText` when its changed
    /// by tapping a suggestion.
    var ignoreNextValueChange: Bool = false
    
    //MARK: Tasks
    var scanTask: Task<(), Error>? = nil
    var classifyTask: Task<(), Error>? = nil

    //MARK: Init
    public init() {
    }
}

extension Extractor {
    func begin() {
        self.detectTexts()
    }
}

extension Extractor {
    func setSuggestedValue(_ value: FoodLabelValue) {
        ignoreNextValueChange = true
        textFieldAmountString = value.amount.cleanWithoutRounding
    }
    
    func removeConfirmationStatusForCurrentAttribute() {
        guard currentNutrientIsConfirmed,
            internalTextfieldDouble != currentNutrient?.value?.amount
        else { return }
        
        toggleAttributeConfirmationForCurrentAttribute()
    }
    
    func removeValueTextForCurrentAttributeIfDifferent() {
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

extension Extractor {
    public func reset() {
        state = .loadingImage
        image = nil
        
        textSet = nil
        textBoxes = []
        scanResult = nil
        
//        showingBoxes = false
        showingBackground = true

        cancelAllTasks()
        scanTask = nil
        classifyTask = nil
    }
    
    func cancelAllTasks() {
        scanTask?.cancel()
        classifyTask?.cancel()
    }
}
