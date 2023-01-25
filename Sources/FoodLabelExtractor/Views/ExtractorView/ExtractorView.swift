import SwiftUI

public struct ExtractorView: View {
    
    @ObservedObject var extractor: Extractor
    @StateObject var imageViewerViewModel = ImageViewer.ViewModel()
    
    public init(extractor: Extractor) {
        self.extractor = extractor
    }
    
    public var body: some View {
        contents
            .onChange(of: extractor.image, perform: imageChanged)
//            .onChange(of: extractor.showingBoxes, perform: showingBoxesChanged)
            .onChange(of: extractor.textBoxes, perform: textBoxesChanged)
            .onChange(of: extractor.state, perform: stateChanged)
    }
    
    func showingBoxesChanged(_ newValue: Bool) {
        withAnimation {
            imageViewerViewModel.showingBoxes = newValue
        }
    }

    
    func textBoxesChanged(_ newValue: [TextBox]) {
        print("▪️ textBoxesChanged to \(newValue.count) items, while current value is: \(extractor.textBoxes.count)")
        withAnimation {
            print("▪️ Setting imageViewerViewModel.textBoxes with \(newValue.count) items")
            imageViewerViewModel.textBoxes = newValue
        }
    }

    func stateChanged(_ state: ExtractorState) {
        print("▫️ State changed to \(state.rawValue)")
        withAnimation {
            imageViewerViewModel.isShimmering = state == .classifying
            imageViewerViewModel.showingBoxes = state.shouldShowTextBoxes
            imageViewerViewModel.isFocused = state.shouldShowTextBoxes
        }
    }

    var contents: some View {
        ZStack {
            if extractor.showingBackground {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
            }
            imageViewerLayer
//            cameraLayer
            attributesLayer
//            columnPickerLayer
//            if !viewModel.animatingCollapse {
//                buttonsLayer
//                    .transition(.scale)
//            }
        }
    }
    
    var attributesLayer: some View {
        AttributesLayer(
            extractor: extractor,
            actionHandler: extractor.handleAttributesLayerAction
        )
    }
}
