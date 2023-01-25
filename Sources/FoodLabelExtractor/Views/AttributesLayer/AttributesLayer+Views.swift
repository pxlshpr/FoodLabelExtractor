import SwiftUI
import FoodLabelScanner

extension AttributesLayer {

    var pickerView: some View {
        VStack(spacing: K.topButtonsVerticalPadding) {
            topButtonsRow
                .padding(.horizontal, K.topButtonsHorizontalPadding)
            if !extractor.extractedNutrients.isEmpty {
                list
                    .transition(.move(edge: .bottom))
                    .opacity(extractor.state == .showingKeyboard ? 0 : 1)
            }
        }
        .padding(.vertical, K.topButtonsVerticalPadding)
        .frame(maxWidth: UIScreen.main.bounds.width)
    }

    var topButtonsRow: some View {
        Group {
            if extractor.currentAttribute == nil {
                statusMessage
                    .transition(.move(edge: .trailing))
            } else {
                HStack(spacing: K.topButtonsHorizontalPadding) {
                    Color.green
//                    if extractor.state == .showingKeyboard {
//                        valueTextFieldContents
//                    } else {
//                        attributeButton
//                        valueButton
//                    }
//                    rightButton
                }
                .transition(.move(edge: .leading))
            }
        }
    }
    
    var statusMessage: some View {
        var string: String {
            extractor.state == .allConfirmed
            ? "All nutrients confirmed"
            : "Confirm or correct nutrients"
        }
        return Text(string)
        .font(.system(size: 18, weight: .medium, design: .default))
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .frame(height: K.topButtonHeight)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundStyle(Color(.tertiarySystemFill))
        )
        .contentShape(Rectangle())
    }
    
    var list: some View {
        ScrollViewReader { scrollProxy in
            List($extractor.extractedNutrients, id: \.self.hashValue, editActions: .delete) { $nutrient in
                cell(for: nutrient)
                    .frame(maxWidth: .infinity)
                    .id(nutrient.attribute)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 60)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .buttonStyle(.borderless)
            .onReceive(scannerDidChangeAttribute) { notification in
                guard let userInfo = notification.userInfo,
                      let attribute = userInfo[Notification.ScannerKeys.nextAttribute] as? Attribute else {
                    return
                }
                withAnimation {
                    scrollProxy.scrollTo(attribute, anchor: .center)
                }
            }
        }
    }
    
    func cell(for nutrient: ExtractedNutrient) -> some View {
        var isConfirmed: Bool { nutrient.isConfirmed }
        var isCurrentAttribute: Bool { extractor.currentAttribute == nutrient.attribute }
        var imageName: String {
            isConfirmed
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
                    actionHandler(.moveToAttribute(nutrient.attribute))
                } label: {
                    HStack(spacing: 0) {
                        Text(nutrient.attribute.description)
                            .foregroundColor(textColor)
                        Spacer()
                    }
                }
                Button {
//                    tappedCellValue(for: nutrient.attribute)
                } label: {
                    Text(valueDescription)
                        .foregroundColor(valueTextColor)
                }
                Button {
                    actionHandler(.toggleAttributeConfirmation(nutrient.attribute))
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
