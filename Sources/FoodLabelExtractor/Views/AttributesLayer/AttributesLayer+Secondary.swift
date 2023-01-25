import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar

extension AttributesLayer {
    
    var supplementaryContentLayer: some View {
        @ViewBuilder
        var attributeLayer: some View {
            if let currentAttribute = extractor.currentAttribute {
                VStack {
                    HStack {
                        Text(currentAttribute.description)
                            .matchedGeometryEffect(id: "attributeName", in: namespace)
//                            .textCase(.uppercase)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .offset(y: -3)
                            .foregroundColor(Color(.secondaryLabel))
                            .padding(.horizontal, 15)
                            .background(
                                Capsule(style: .continuous)
                                    .foregroundColor(keyboardColor)
//                                    .foregroundColor(.blue)
                                    .frame(height: 35)
                                    .transition(.scale)
                            )
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 20)
                    .offset(y: -10)
                    Spacer()
                }
            }
        }
        
        return VStack(spacing: 0) {
            Spacer()
            if extractor.state == .showingKeyboard {
                ZStack(alignment: .bottom) {
                    keyboardColor
                    attributeLayer
                    suggestionsLayer
                }
                .frame(maxWidth: .infinity)
                .frame(height: K.attributesLayerHeight)
                .transition(.opacity)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var suggestionsLayer: some View {
        
        var valueSuggestions: [FoodLabelValue] {
//            [.init(amount: 320, unit: .kcal), .init(amount: 320, unit: .kj), .init(amount: 320), .init(amount: 3200, unit: .kcal), .init(amount: 3200, unit: .kj)]
            guard let text = extractor.currentValueText, let attribute = extractor.currentAttribute else {
                return []
            }
            return text.allDetectedFoodLabelValues(for: attribute)
        }
        
        var backgroundColor: Color {
//                Color(.tertiarySystemFill)
            colorScheme == .dark ? Color(hex: "737373") : Color(hex: "EBEDF0")
        }
        
        var textColor: Color {
//                .primary
            .secondary
        }
        
        var scrollView: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(valueSuggestions, id: \.self) { value in
                        Text(value.description)
    //                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(textColor)
                            .padding(.horizontal, 15)
                            .frame(height: K.suggestionsBarHeight)
                            .background(
    //                                Capsule(style: .continuous)
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .foregroundColor(backgroundColor)
                            )
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        
        var noTextBoxPrompt: String {
            "Select a text from the image to autofill its value."
//            viewModel.textFieldAmountString.isEmpty
//            ? "or select a detected text from the image."
//            : "Select a detected text from the image."
        }
        
        return Group {
            if valueSuggestions.isEmpty {
                Text(noTextBoxPrompt)
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            } else {
                scrollView
            }
        }
        .frame(height: K.suggestionsBarHeight)
//        .background(.green)
        .padding(.bottom, K.keyboardHeight + 2)
    }

}

extension AttributesLayer {
    
    var topButtonsLayer: some View {
        var bottomPadding: CGFloat {
            K.topButtonPaddedHeight + K.suggestionsBarHeight + 8.0
        }
        
        var keyboardButton: some View {
            Button {
                Haptics.feedback(style: .soft)
                resignFocusOfSearchTextField()
                withAnimation {
                    if extractor.containsUnconfirmedAttributes {
                        extractor.state = .awaitingConfirmation
                    } else {
                        extractor.state = .allConfirmed
                    }
                    hideBackground = false
                }
            } label: {
                DismissButtonLabel(forKeyboard: true)
            }
        }
        
        var sideButtonsLayer: some View {
            HStack {
//                dismissButton
                Spacer()
                keyboardButton
            }
            .transition(.opacity)
        }
        
        @ViewBuilder
        var centerButtonLayer: some View {
            if let currentAttribute = extractor.currentAttribute {
                HStack {
                    Spacer()
                    Text(currentAttribute.description)
    //                    .matchedGeometryEffect(id: "attributeName", in: namespace)
    //                    .textCase(.uppercase)
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundColor(Color(.secondaryLabel))
    //                    .frame(height: 38)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .foregroundStyle(.ultraThinMaterial)
                                .shadow(color: Color(.black).opacity(0.2), radius: 3, x: 0, y: 3)
                        )
                    Spacer()
                }
                .padding(.horizontal, 38)
            }
        }
        
        var shouldShow: Bool {
            extractor.state == .showingKeyboard
        }
        
        return Group {
            if shouldShow {
                VStack {
                    Spacer()
                    ZStack(alignment: .bottom) {
//                        centerButtonLayer
                        sideButtonsLayer
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, bottomPadding)
                    .frame(width: UIScreen.main.bounds.width)
                }
            }
        }
    }

}
