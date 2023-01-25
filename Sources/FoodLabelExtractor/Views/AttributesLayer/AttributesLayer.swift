import SwiftUI
import FoodLabelScanner

public enum AttributesLayerAction {
    case dismiss
    case confirmCurrentAttribute
    case deleteCurrentAttribute
    case moveToAttribute(Attribute)
    case moveToAttributeAndShowKeyboard(Attribute)
    case toggleAttributeConfirmation(Attribute)
}

public struct AttributesLayer: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var actionHandler: (AttributesLayerAction) -> ()
    
    @Namespace var namespace
    @State var showingAttributePicker = false
    @State var hideBackground: Bool = false
    @State var showingNutrientsPicker = false
    
    let attributesListAnimation: Animation = K.Animations.bounce
    
    @ObservedObject var extractor: Extractor
    
    let scannerDidChangeAttribute = NotificationCenter.default.publisher(for: .scannerDidChangeAttribute)
    
    public init(
        extractor: Extractor,
        actionHandler: @escaping (AttributesLayerAction) -> ()
    ) {
        self.extractor = extractor
        self.actionHandler = actionHandler
    }
    
    public var body: some View {
        ZStack {
            Color.blue
//            topButtonsLayer
//            supplementaryContentLayer
//            primaryContentLayer
//            buttonsLayer
        }
    }
}
