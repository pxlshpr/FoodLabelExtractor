import SwiftUI
import PrepDataTypes
import PrepViews

extension AttributesLayer {
    
    var nutrientsPicker: some View {
        let shouldShowEnergy = !extractor.extractedNutrients.contains(where: { $0.attribute == .energy })
        
        func hasUnusedMicros(in group: NutrientTypeGroup, matching searchString: String = "") -> Bool {
            group.nutrients.contains(where: {
                if searchString.isEmpty {
                    return !hasMicronutrient(for: $0)
                } else {
                    return !hasMicronutrient(for: $0) && $0.matchesSearchString(searchString)
                }
            })
        }
        
        func hasMicronutrient(for nutrientType: NutrientType) -> Bool {
            extractor.extractedNutrients.contains(where: { $0.attribute.nutrientType == nutrientType })
        }

        func shouldShowMacro(_ macro: Macro) -> Bool {
            !extractor.extractedNutrients.contains(where: { $0.attribute.macro == macro })
        }
        
        func didAddNutrients(energy: Bool, macros: [Macro], micros: [NutrientType]) {
            withAnimation {
                if energy {
                    extractor.extractedNutrients.insert(.init(attribute: .energy), at: 0)
                }
                for macro in macros {
                    extractor.extractedNutrients.append(.init(attribute: macro.attribute))
                }
                for nutrientType in micros {
                    guard let attribute = nutrientType.attribute else { continue }
                    extractor.extractedNutrients.append(.init(attribute: attribute))
                }
            }
        }

        return NutrientsPicker(
            supportsEnergyAndMacros: true,
            shouldShowEnergy: shouldShowEnergy,
            shouldShowMacro: shouldShowMacro,
            hasUnusedMicros: hasUnusedMicros,
            hasMicronutrient: hasMicronutrient,
            didAddNutrients: didAddNutrients
        )
    }
}
