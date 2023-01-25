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
                    if extractor.state == .showingKeyboard {
//                        valueTextFieldContents
                    } else {
                        attributeButton
                        valueButton
                    }
                    rightButton
                }
                .transition(.move(edge: .leading))
            }
        }
    }
    
    var attributeButton: some View {
        Button {
//            tappedValueButton()
        } label: {
            Text(extractor.currentAttribute?.description ?? "")
                .matchedGeometryEffect(id: "attributeName", in: namespace)
//                .font(.title3)
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.2)
                .lineLimit(2)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .frame(height: K.topButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundStyle(Color(.quaternarySystemFill))
                        .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                )
                .contentShape(Rectangle())
        }
    }
    
    var valueButton: some View {
        var amountColor: Color {
            Color.primary
        }
        
        var unitColor: Color {
            Color.secondary
        }
        
        var backgroundStyle: some ShapeStyle {
            Color(.secondarySystemFill)
        }
        
        return Button {
//            tappedValueButton()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                if extractor.currentAmountString.isEmpty {
                    Image(systemName: "keyboard")
                } else {
                    Text(extractor.currentAmountString)
                        .foregroundColor(amountColor)
                        .matchedGeometryEffect(id: "textField", in: namespace)
                    Text(extractor.currentUnitString)
                        .foregroundColor(unitColor)
                        .font(.system(size: 18, weight: .medium, design: .default))
                }
            }
            .font(.system(size: 22, weight: .semibold, design: .default))
            .padding(.horizontal)
            .frame(height: K.topButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(backgroundStyle)
                    .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
            )
            .contentShape(Rectangle())
        }
    }
    
    var rightButton: some View {
        var shouldDisablePrimaryButton: Bool {
            guard let currentNutrient = extractor.currentNutrient else { return true }
            if let textFieldDouble = extractor.internalTextfieldDouble {
                if textFieldDouble != currentNutrient.value?.amount {
                    return false
                }
                if extractor.pickedAttributeUnit != currentNutrient.value?.unit {
                    return false
                }
            }
            return currentNutrient.isConfirmed
        }
        
        var imageName: String {
            extractor.shouldShowDeleteForCurrentAttribute ? "trash" : "checkmark"
        }

        var foregroundStyle: some ShapeStyle {
            extractor.shouldShowDeleteForCurrentAttribute ? Color.red.gradient : Color.green.gradient
        }
        
        return Button {
            tappedPrimaryButton()
        } label: {
            Image(systemName: imageName)
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .frame(width: K.topButtonWidth)
                .frame(height: K.topButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: K.topButtonCornerRadius, style: .continuous)
                        .foregroundStyle(foregroundStyle)
                )
                .contentShape(Rectangle())
        }
//        .disabled(shouldDisablePrimaryButton)
//        .grayscale(shouldDisablePrimaryButton ? 1.0 : 0.0)
        .animation(.interactiveSpring(), value: shouldDisablePrimaryButton)
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
