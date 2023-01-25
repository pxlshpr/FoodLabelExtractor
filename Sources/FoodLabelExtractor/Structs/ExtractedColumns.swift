import SwiftUI
import FoodLabelScanner
import VisionSugar

class ExtractedColumns: ObservableObject {
    
    let id = UUID()
    var column1: ExtractedColumn
    var column2: ExtractedColumn
    @Published var selectedColumnIndex: Int
    
    init() {
        self.column1 = .init(column: 1)
        self.column2 = .init(column: 2)
        self.selectedColumnIndex = 1
    }
    
    init(column1: ExtractedColumn, column2: ExtractedColumn, selectedColumnIndex: Int) {
        self.column1 = column1
        self.column2 = column2
        self.selectedColumnIndex = selectedColumnIndex
    }
    
    var selectedColumn: ExtractedColumn {
        selectedColumnIndex == 1 ? column1 : column2
    }
    
    var selectedColumnNutrients: [ExtractedNutrient] {
        selectedColumnIndex == 1 ? column1.extractedNutrients : column2.extractedNutrients
    }
    
    var texts: [RecognizedText] {
        var texts: [RecognizedText] = []
        for column in [column1, column2] {
            texts.append(
                contentsOf: column.extractedNutrients
                    .compactMap { $0.valueText }
                )
        }
        return texts
    }
    
    var boundingBox: CGRect {
        var boundingBoxes: [CGRect] = []
        for column in [column1, column2] {
            boundingBoxes.append(
                contentsOf: column.extractedNutrients
                    .compactMap { $0.boundingBoxWithAttribute }
            )
        }
        return boundingBoxes.union
    }
    
    func toggleSelectedColumnIndex() {
        selectedColumnIndex = selectedColumnIndex == 1 ? 2 : 1
    }
}

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


struct ExtractedColumn {
    let column: Int
    let name: String
    let extractedNutrients: [ExtractedNutrient]
    
    init(column: Int, name: String = "", extractedNutrients: [ExtractedNutrient] = []) {
        self.column = column
        self.name = name
        self.extractedNutrients = extractedNutrients
    }
    
//    func containsTexts(from imageViewModel: ImageViewModel) -> Bool {
//        imageTexts.contains {
//            $0.imageId == imageViewModel.id
//        }
//    }
//
//    func contains(_ text: RecognizedText) -> Bool {
//        imageTexts.contains {
//            $0.text.id == text.id
//        }
//    }
}
