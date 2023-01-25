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

extension ScanResult {
    
    func extractedNutrientsForColumn(_ column: Int) -> [ExtractedNutrient] {
        nutrients.rows.map({ row in
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
//        var nutrients: [ExtractedNutrient] = []
//        fieldValues.append(energyFieldValue(at: column))
//        for macro in Macro.allCases {
//            fieldValues.append(macroFieldValue(for: macro, at: column))
//        }
//        for nutrientType in NutrientType.allCases {
//            fieldValues.append(microFieldValue(for: nutrientType, at: column))
//        }
//        return fieldValues.compactMap({ $0?.fill.imageText })
//        return []
    }
}

