import SwiftUI

extension ExtractorView {
    
    @ViewBuilder
    var imageViewerLayer: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Color.clear.frame(height: K.topBarHeight)
                ZStack {
                    imageViewer
//                    croppedImagesLayer
//                        .scaleEffect(viewModel.animatingCollapseOfCroppedImages ? 0 : 1)
//                        .padding(.top, viewModel.animatingCollapseOfCroppedImages ? 0 : 0)
//                        .padding(.trailing, viewModel.animatingCollapseOfCroppedImages ? 300 : 0)
                }
                Spacer()
            }
            .transition(.opacity)
            .frame(height: imageViewerHeight)
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .opacity(extractor.transitionState.isTransitioning ? 0 : 1)
    }
    
    var imageViewer: some View {
        ImageViewer(viewModel: imageViewerViewModel)
//            .scaleEffect(viewModel.animatingCollapse ? 0 : 1)
//            .opacity(viewModel.shimmeringImage ? 0.4 : 1)

//        let isFocused = Binding<Bool>(
//            get: { viewModel.showingColumnPicker || viewModel.showingValuePicker },
//            set: { _ in }
//        )
//
//        return ImageViewer(
//            id: UUID(),
//            image: image,
//            textBoxes: $viewModel.textBoxes,
//            scannedTextBoxes: $viewModel.scannedTextBoxes,
//            contentMode: .fit,
//            zoomBox: $viewModel.zoomBox,
//            showingBoxes: $viewModel.showingBoxes,
//            showingCutouts: $viewModel.showingCutouts,
//            shimmering: $viewModel.shimmering,
//            isFocused: isFocused
//        )
//        .scaleEffect(viewModel.animatingCollapse ? 0 : 1)
//        .opacity(viewModel.shimmeringImage ? 0.4 : 1)
    }
    
    var imageViewerHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        /// 🪄 Magic Number, no idea why but this works on iPhone 13 Pro Max, iPhone 14 Pro Max and iPhone X (there's a gap without it)
        let correctivePadding = 8.0
        return screenHeight - (K.keyboardHeight + K.topButtonPaddedHeight + K.suggestionsBarHeight) + correctivePadding
    }

    func imageChanged(_ image: UIImage?) {
        guard let image else { return }
        guard !extractor.isUsingCamera else { return }
        setImageInImageViewer(image)
        startExtracting(image: image)
    }
    
    func setImageInImageViewer(_ image: UIImage) {
        withAnimation(.easeInOut(duration: 0.7)) {
            imageViewerViewModel.image = image
        }
    }
    
    func startExtracting(image: UIImage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            extractor.begin()
        }
    }
}
