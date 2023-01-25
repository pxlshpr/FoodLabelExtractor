import SwiftUI
import Shimmer

public struct ImageViewer: View {
    
    @ObservedObject var viewModel: ImageViewer.ViewModel
    
    public init(viewModel: ImageViewer.ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color(.systemBackground)
            zoomableScrollView
        }
    }
    
    var zoomableScrollView: some View {
        ZoomScrollView {
            VStack(spacing: 0) {
                imageView(viewModel.image)
                    .overlay(textBoxesLayer)
                    .overlay(scannedTextBoxesLayer)
            }
        }
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(.black)
            .opacity(viewModel.imageOverlayOpacity)
            .animation(.default, value: viewModel.showingBoxes)
    }
    
    var textBoxesLayer: some View {
        TextBoxesLayer(
            textBoxes: $viewModel.textBoxes,
            shimmering: $viewModel.isShimmering
        )
        .opacity(viewModel.textBoxesOpacity)
        .animation(.default, value: viewModel.textPickerHasAppeared)
        .animation(.default, value: viewModel.textBoxes)
        .animation(.default, value: viewModel.showingBoxes)
        .animation(.default, value: viewModel.isShimmering)
        .animation(.default, value: viewModel.scannedTextBoxes.count)
        .shimmering(active: viewModel.isShimmering)
    }
    
    var scannedTextBoxesLayer: some View {
        TextBoxesLayer(textBoxes: $viewModel.scannedTextBoxes, isCutOut: true)
            .opacity(viewModel.scannedTextBoxesOpacity)
            .animation(.default, value: viewModel.textPickerHasAppeared)
            .animation(.default, value: viewModel.showingBoxes)
            .animation(.default, value: viewModel.showingCutouts)
    }
}
