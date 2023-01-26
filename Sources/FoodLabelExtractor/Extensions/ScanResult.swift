import Foundation
import FoodLabelScanner

extension ScanResult {
    var extractedColumns: ExtractedColumns {
        let column1 = ExtractedColumn(
            column: 1,
            name: headerTitle1,
            extractedNutrients: extractedNutrientsForColumn(1)
        )
        let column2 = ExtractedColumn(
            column: 2,
            name: headerTitle2,
            extractedNutrients: extractedNutrientsForColumn(2)
        )
        return ExtractedColumns(
            column1: column1,
            column2: column2,
            selectedColumnIndex: bestColumn
        )
    }
}

import PrepDataTypes
import VisionSugar

extension ScanResult {
    
    func extractedNutrientsForColumn(_ column: Int, includeSingleColumnValues singles: Bool = false) -> [ExtractedNutrient] {
        var extractedNutrients = nutrients.rows.map({ row in
            
            var value: FoodLabelValue? = nil
            let valueText: RecognizedText?
            /// If the column doesn't have a value, pick the opposite one if it exists,
            /// so that we're always returning nutrients with a value in 1 column
            if column == 1 {
                value = row.value1 ?? (singles ? row.value2 : nil)
                valueText = row.valueText1?.text ?? (singles ? row.valueText2?.text : nil)
            } else {
                value = row.value2 ?? (singles ? row.value1 : nil)
                valueText = row.valueText2?.text ?? (singles ? row.valueText1?.text : nil)
            }
            
            value?.correctUnit(for: row.attribute)
            return ExtractedNutrient(
                attribute: row.attribute,
                attributeText: row.attributeText.text,
                isConfirmed: false,
                value: value,
                valueText: valueText
            )
        })
        
        /// Ensure that energy is always at the top
        let energy: ExtractedNutrient
        if let energyIndex = extractedNutrients.firstIndex(where: { $0.attribute == .energy }) {
            energy = extractedNutrients.remove(at: energyIndex)
        } else {
            energy = ExtractedNutrient(attribute: .energy)
        }
        extractedNutrients.insert(energy, at: 0)
        
        for macro in Macro.allCases {
            guard !extractedNutrients.contains(where: { $0.attribute.macro == macro }) else {
                continue
            }
            extractedNutrients.append(.init(attribute: macro.attribute))
        }

        return extractedNutrients
    }
}

extension Macro {
    var attribute: Attribute {
        switch self {
        case .carb:
            return .carbohydrate
        case .fat:
            return .fat
        case .protein:
            return .protein
        }
    }
}

extension Attribute {
    var macro: Macro? {
        switch self {
        case .carbohydrate:
            return .carb
        case .fat:
            return .fat
        case .protein:
            return .protein
        default:
            return nil
        }
    }
}
