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
            .onChange(of: extractor.selectableTextBoxes, perform: selectableTextBoxesChanged)
            .onChange(of: extractor.state, perform: stateChanged)
            .onChange(of: extractor.transitionState, perform: transitionStateChanged)
    }
    var contents: some View {
        ZStack {
            if extractor.showingBackground {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
            }
            imageViewerLayer
            attributesLayer
            cameraLayer
            cameraTransitionLayer
//            if !viewModel.animatingCollapse {
//                buttonsLayer
//                    .transition(.scale)
//            }
        }
    }
    
    var attributesLayer: some View {
        AttributesLayer(
            extractor: extractor
//            actionHandler: extractor.handleAttributesLayerAction
        )
    }
    
    @ViewBuilder
    var cameraLayer: some View {
        if extractor.isUsingCamera {
            foodLabelCamera
                .opacity(extractor.showingCamera ? 1 : 0)
        }
    }
    
    var cameraTransitionLayer: some View {
        
        var topHeight: CGFloat {
            extractor.transitionState.showFullScreenImage
            ? 0
            : K.topBarHeight
        }
        
        var imageHeight: CGFloat {
            extractor.transitionState.showFullScreenImage
            ? UIScreen.main.bounds.height
            : imageViewerHeight
        }
        
        var aspectRatio: ContentMode {
            extractor.transitionState.showFullScreenImage
            ? .fill
            : .fit
        }
        
        return Group {
            if extractor.transitionState.isTransitioning, let image = extractor.image {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: topHeight)
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: aspectRatio)
                        Spacer()
                    }
                    .transition(.opacity)
                    .frame(height: imageHeight)
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    var foodLabelCamera: some View {
        LabelCamera(imageHandler: handleCapturedImage)
    }

    //MARK: Events

    func handleCapturedImage(_ image: UIImage) {
        extractor.handleCapturedImage(image)
    }
    
    func showingBoxesChanged(_ newValue: Bool) {
        withAnimation {
            imageViewerViewModel.showingBoxes = newValue
        }
    }
    
    func textBoxesChanged(_ newValue: [TextBox]) {
        withAnimation(.interactiveSpring()) {
            imageViewerViewModel.textBoxes = newValue
        }
    }

    func selectableTextBoxesChanged(_ newValue: [TextBox]) {
        withAnimation(.interactiveSpring()) {
            imageViewerViewModel.selectableTextBoxes = newValue
        }
    }

    func stateChanged(_ state: ExtractorState) {
        withAnimation {
            imageViewerViewModel.isShimmering = state == .classifying
            imageViewerViewModel.showingBoxes = state.shouldShowTextBoxes
            imageViewerViewModel.isFocused = state.shouldShowTextBoxes
        }
    }

    func transitionStateChanged(_ state: ExtractorCaptureTransitionState) {
        guard let image = extractor.image else { return }
        if state == .setup {
            imageViewerViewModel.image = image
        }
        
        if state == .endTransition {
            NotificationCenter.default.post(name: .scannerDidSetImage, object: nil, userInfo: [
                Notification.ZoomableScrollViewKeys.imageSize: image.size
            ])

        }
        if state == .startTransition {
            startExtracting(image: image)
        }
    }

}
