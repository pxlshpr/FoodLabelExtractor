import SwiftUI

extension AttributesLayer {
    
    var textFieldContents: some View {
        ZStack {
            textFieldBackground
            HStack {
                textField
                Spacer()
                unitPicker
            }
            .padding(.horizontal, K.textFieldHorizontalPadding)
        }
    }

    var textField: some View {
        let binding = Binding<String>(
            get: { extractor.textFieldAmountString },
            set: { newValue in
                withAnimation {
                    extractor.textFieldAmountString = newValue
                }
            }
        )

        return TextField("Enter a value", text: binding)
            .focused($isFocused)
            .keyboardType(.decimalPad)
            .font(.system(size: 22, weight: .semibold, design: .default))
            .matchedGeometryEffect(id: "textField", in: namespace)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                }
            }
    }
    
    var unitPicker: some View {
//        Menu {
//            Text("g")
//            Text("mg")
//        } label: {
            Text("mg")
//        }
    }

    //MARK: - Helpers
    
    var textFieldBackground: some View {
        var height: CGFloat { K.topButtonHeight }
//        var xOffset: CGFloat { 0 }
        
        var foregroundStyle: some ShapeStyle {
//            Material.thinMaterial
            expandedTextFieldColor
//            Color(.secondarySystemFill)
        }
        var background: some View { Color.clear }
        
        return RoundedRectangle(cornerRadius: K.topButtonCornerRadius, style: .circular)
            .foregroundStyle(foregroundStyle)
            .background(background)
            .frame(height: height)
//            .frame(width: width)
//            .offset(x: xOffset)
    }

    var keyboardColor: Color {
        colorScheme == .light ? Color(hex: K.ColorHex.keyboardLight) : Color(hex: K.ColorHex.keyboardDark)
    }
    
    var expandedTextFieldColor: Color {
        colorScheme == .light ? Color(hex: K.ColorHex.searchTextFieldLight) : Color(hex: K.ColorHex.searchTextFieldDark)
    }
}
