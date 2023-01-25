import SwiftUI
import VisionSugar
import FoodLabelScanner
import PrepDataTypes

public class ExtractedNutrient: ObservableObject, Identifiable {
    
    var attribute: Attribute
    var attributeText: RecognizedText? = nil
    @Published var isConfirmed: Bool = false
    @Published var value: FoodLabelValue? = nil
    @Published var valueText: RecognizedText? = nil
    
    var scannerValue: FoodLabelValue? = nil
    var scannerValueText: RecognizedText? = nil

    init(
        attribute: Attribute,
        attributeText: RecognizedText? = nil,
        isConfirmed: Bool = false,
        value: FoodLabelValue? = nil,
        valueText: RecognizedText? = nil
    ) {
        self.attribute = attribute
        self.attributeText = attributeText
        self.isConfirmed = isConfirmed
        self.value = value
        self.valueText = valueText
        self.scannerValue = value
        self.scannerValueText = valueText
    }
    
    public var id: Attribute {
        self.attribute
    }
}
extension ExtractedNutrient: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(attribute)
        hasher.combine(attributeText)
        hasher.combine(isConfirmed)
        hasher.combine(value)
        hasher.combine(valueText)
        hasher.combine(scannerValue)
        hasher.combine(scannerValueText)
    }
}

extension ExtractedNutrient: Equatable {
    public static func ==(lhs: ExtractedNutrient, rhs: ExtractedNutrient) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
