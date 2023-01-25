import SwiftUI

public extension ImageViewer {
    class ViewModel: ObservableObject {
        
        let id: UUID
        let image: UIImage
        
        @Published public var textBoxes: [TextBox] = []
        
        //TODO: Revisit these
        @Published public var zoomBox: ZoomBox? = nil
        @Published public var scannedTextBoxes: [TextBox] = []
        @Published public var showingBoxes: Bool = false
        @Published public var showingCutouts: Bool = false
        @Published public var isShimmering: Bool = false
        @Published public var isFocused: Bool = true
        @Published public var textPickerHasAppeared: Bool = true

        public init(image: UIImage) {
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
