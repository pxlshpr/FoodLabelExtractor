import SwiftUI

extension AttributesLayer {
    
    func cell(for nutrient: ExtractedNutrient) -> some View {
        var isConfirmed: Bool { nutrient.isConfirmed }
        var isCurrentAttribute: Bool { extractor.currentAttribute == nutrient.attribute }
        var imageName: String {
            isConfirmed
//            ? "circle.inset.filled"
//            : "circle"
            ? "checkmark.square.fill"
            : "square"
        }

        var listRowBackground: some View {
            isCurrentAttribute
            ? (colorScheme == .dark
               ? Color(.tertiarySystemFill)
               : Color(.systemFill)
            )
            : .clear
        }
        
        var hstack: some View {
            var valueDescription: String {
                nutrient.value?.description ?? "Enter a value"
            }
            
            var textColor: Color {
                isConfirmed ? .secondary : .primary
            }
            
            var valueTextColor: Color {
                guard nutrient.value != nil else {
                    return Color(.tertiaryLabel)
                }
                return textColor
            }
            
            return HStack(spacing: 0) {
                Button {
                    tappedCell(for: nutrient.attribute)
                } label: {
                    HStack(spacing: 0) {
                        Text(nutrient.attribute.description)
                            .foregroundColor(textColor)
                        Spacer()
                    }
                }
                Button {
                    tappedCellValue(for: nutrient.attribute)
                } label: {
                    Text(valueDescription)
                        .foregroundColor(valueTextColor)
                }
                Button {
//                    actionHandler(.toggleAttributeConfirmation(nutrient.attribute))
                    extractor.toggleAttributeConfirmation(nutrient.attribute)
                } label: {
                    Image(systemName: imageName)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 15)
                        .frame(maxHeight: .infinity)
                }
            }
            .foregroundColor(textColor)
            .foregroundColor(.primary)
        }
        
        return hstack
        .listRowBackground(listRowBackground)
        .listRowInsets(.init(top: 0, leading: 25, bottom: 0, trailing: 0))
    }

}
