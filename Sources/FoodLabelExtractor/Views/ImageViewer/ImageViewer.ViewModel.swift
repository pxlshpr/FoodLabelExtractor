import SwiftUI

public extension ImageViewer {
    class ViewModel: ObservableObject {
        
        let id: UUID
        @Published public var image: UIImage?
        
        /// Text boxes meant to be highlighted are placed here. Ideally with no tap handlers so that changes are animated (they'll move to the new positions)
        @Published public var textBoxes: [TextBox] = []
        
        /// Text boxes intended for users to select are placed here.
        @Published public var selectableTextBoxes: [TextBox] = []

        //TODO: Revisit these
        @Published public var zoomBox: ZoomBox? = nil
        @Published public var scannedTextBoxes: [TextBox] = []
        @Published public var showingBoxes: Bool = false
        @Published public var showingCutouts: Bool = false
        @Published public var isShimmering: Bool = false
        @Published public var isFocused: Bool = true
        @Published public var textPickerHasAppeared: Bool = true

        public init(image: UIImage? = nil) {
            self.id = UUID()
            self.image = image
        }
    }
}

extension ImageViewer.ViewModel {
    
    var imageOverlayOpacity: CGFloat {
        (showingBoxes && isFocused) ? 0.7 : 1
    }
    
    var shouldShowTextBoxes: Bool {
        textPickerHasAppeared
        && showingBoxes
        && scannedTextBoxes.isEmpty
    }
    
    var textBoxesOpacity: CGFloat {
        guard shouldShowTextBoxes else { return 0 }
        if isShimmering || isFocused { return 1 }
        return 0.3
    }
    
    var shouldShowScannedTextBoxes: Bool {
        textPickerHasAppeared
        && showingBoxes
        && showingCutouts
    }
    
    var scannedTextBoxesOpacity: CGFloat {
        shouldShowScannedTextBoxes ? 1 : 0
    }
}
