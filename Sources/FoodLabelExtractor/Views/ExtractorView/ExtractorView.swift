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
            .onChange(of: extractor.textBoxes, perform: textBoxesChanged)
            .onChange(of: extractor.selectableTextBoxes, perform: selectableTextBoxesChanged)
            .onChange(of: extractor.cutoutTextBoxes, perform: cutoutTextBoxesChanged)
            .onChange(of: extractor.state, perform: stateChanged)
            .onChange(of: extractor.transitionState, perform: transitionStateChanged)
            .onAppear(perform: appeared)
    }
    
    func appeared() {
        withAnimation {
            extractor.presentationState = .onScreen
        }
    }
    
    var contents: some View {
        ZStack {
            if !extractor.dismissState.shouldShrinkImage {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
            }
            imageViewerLayer
//                .opacity(extractor.dismissState == .startedCancelDismissal ? 0 : 1)
            attributesLayer
            cameraLayer
            cameraTransitionLayer
//            if !viewModel.animatingCollapse {
//                buttonsLayer
//                    .transition(.scale)
//            }
        }
        .offset(y: extractor.presentationState == .offScreen
                ? UIScreen.main.bounds.height * 2
                : 0
        )
    }
    
    @ViewBuilder
    var attributesLayer: some View {
        if extractor.shouldShowAttributesLayer {
            AttributesLayer(extractor: extractor)
            .zIndex(9)
            .transition(.move(edge: .bottom))
        }
    }
    
    @ViewBuilder
    var cameraLayer: some View {
        if extractor.isUsingCamera {
            foodLabelCamera
                .opacity(extractor.showingCamera ? 1 : 0)
                .zIndex(20)
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
                .zIndex(21)
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
    
    func cutoutTextBoxesChanged(_ newValue: [TextBox]) {
        withAnimation(.interactiveSpring()) {
            imageViewerViewModel.cutoutTextBoxes = newValue
            imageViewerViewModel.showingCutouts = true
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
