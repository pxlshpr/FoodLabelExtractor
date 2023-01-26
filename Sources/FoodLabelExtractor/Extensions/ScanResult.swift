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

extension ScanResult {
    
    func extractedNutrientsForColumn(_ column: Int) -> [ExtractedNutrient] {
        var extractedNutrients = nutrients.rows.map({ row in
            var value = column == 1 ? row.valueText1?.value : row.valueText2?.value
            value?.correctUnit(for: row.attribute)
            return ExtractedNutrient(
                attribute: row.attribute,
                attributeText: row.attributeText.text,
                isConfirmed: false,
                value: value,
                valueText: column == 1 ? row.valueText1?.text : row.valueText2?.text
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
