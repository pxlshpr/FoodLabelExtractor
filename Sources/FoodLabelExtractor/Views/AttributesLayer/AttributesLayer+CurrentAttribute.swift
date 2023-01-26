import SwiftUI

extension AttributesLayer {
    var currentAttributeRow: some View {
        Group {
            if extractor.currentAttribute == nil {
                statusMessage
                    .transition(
                        .move(edge: .trailing)
                        .combined(with: .opacity)
                    )
            } else {
                HStack(spacing: K.topButtonsHorizontalPadding) {
                    if extractor.state == .showingKeyboard {
                        textFieldContents
                    } else {
                        attributeButton
                        valueButton
                    }
                    actionButton
                }
                .transition(.move(edge: .leading))
            }
        }
    }

    var attributeButton: some View {
        Button {
            tappedValueButton()
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
            tappedValueButton()
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
    
    var actionButton: some View {
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
            tappedActionButton()
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
            ? "All Marked as Correct"
            : "Edit Nutrients"
        }
        
        var foregroundColor: Color {
            extractor.state == .allConfirmed
            ? .secondary
            : .primary
        }
        
        var label: some View {
            HStack {
                Text(string)
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(foregroundColor)
                if extractor.state != .allConfirmed {
                    Image(systemName: "info.circle")
                }
            }
            .padding(.horizontal)
            .frame(height: K.topButtonHeight)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundStyle(Color(.tertiarySystemFill))
            )
            .contentShape(Rectangle())
        }
        var button: some View {
            Button {
                
            } label: {
                label
            }
        }
        
        return Group {
            if extractor.state == .allConfirmed {
                label
            } else {
                button
            }
        }
    }
}
