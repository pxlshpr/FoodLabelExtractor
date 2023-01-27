import SwiftUI
import PrepDataTypes
import SwiftHaptics

extension AttributesLayer {
    
    var suggestionsLayer: some View {
        
        var valueSuggestions: [FoodLabelValue] {
            guard let text = extractor.currentValueText, let attribute = extractor.currentAttribute else {
                return []
            }
            let values = text.allDetectedFoodLabelValues(for: attribute)
            /// Filter out values that are currently being displayed
            return values.filter {
                $0.amount != extractor.internalTextfieldDouble
            }
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
                        Button {
                            tappedSuggestedValue(value)
                        } label: {
                            Text(value.descriptionWithoutRounding)
                                .foregroundColor(textColor)
                                .padding(.horizontal, 15)
                                .frame(height: K.suggestionsBarHeight)
                                .background(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .foregroundColor(backgroundColor)
                                )
                        }
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
