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
//            Color.primary
            Color.accentColor
        }
        
        var unitColor: Color {
//            Color.secondary
            Color.accentColor.opacity(0.7)
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
            extractor.shouldShowDeleteForCurrentAttribute
            ? "checkmark.square.fill" /// "trash"
            : "square.dashed"
        }

        var background: some View {
            
            var roundedRectangle: some View {
                RoundedRectangle(cornerRadius: K.topButtonCornerRadius, style: .continuous)
            }
            
            return Group {
                if extractor.shouldShowDeleteForCurrentAttribute {
                    roundedRectangle
                        .foregroundStyle(Color(.secondarySystemFill))
                } else {
                    roundedRectangle
                        .foregroundStyle(Color(.secondarySystemFill))
//                        .foregroundStyle(Color.green.gradient)
                }
            }
        }
        
        var foregroundColor: Color {
            extractor.shouldShowDeleteForCurrentAttribute
            ? Color.white /// Color.red
            : Color.white
        }
        
        return Button {
            tappedActionButton()
        } label: {
            Image(systemName: imageName)
                .font(.system(size: 22, weight: .semibold, design: .default))
                .foregroundColor(foregroundColor)
                .frame(width: K.topButtonWidth)
                .frame(height: K.topButtonHeight)
                .background(background)
                .contentShape(Rectangle())
        }
//        .disabled(shouldDisablePrimaryButton)
//        .grayscale(shouldDisablePrimaryButton ? 1.0 : 0.0)
        .animation(.interactiveSpring(), value: shouldDisablePrimaryButton)
    }

    var statusMessage: some View {
        var string: String {
            switch extractor.state {
            case .awaitingColumnSelection:
                return "Select a Column"
            case .allConfirmed:
                return "All Marked as Correct"
            default:
                return "Confirm Detected Nutrients"
            }
        }
        
        var foregroundColor: Color {
            switch extractor.state {
            case .allConfirmed:
                return .secondary
            default:
                return .primary
            }
        }
        
        var showInfoButton: Bool {
            switch extractor.state {
            case .awaitingColumnSelection, .allConfirmed:
                return false
            default:
                return true
            }
        }
        
        var label: some View {
            HStack {
                Text(string)
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(foregroundColor)
                if showInfoButton {
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
                showTutorial()
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
