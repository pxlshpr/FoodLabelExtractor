import SwiftUI
import FoodLabelScanner

extension AttributesLayer {

    var primaryView: some View {
        VStack(spacing: K.topButtonsVerticalPadding) {
            currentAttributeRow
                .padding(.horizontal, K.topButtonsHorizontalPadding)
            if !extractor.extractedNutrients.isEmpty {
                attributesList
                    .transition(.move(edge: .bottom))
                    .opacity(extractor.state == .showingKeyboard ? 0 : 1)
            } else if extractor.state == .awaitingColumnSelection {
                columnPicker
            }
        }
        .padding(.vertical, K.topButtonsVerticalPadding)
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
    
    var attributesList: some View {
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
}
