import SwiftUI
import VisionSugar
import FoodLabelScanner

@MainActor
public class Extractor: ObservableObject {

    @Published var state: ExtractorState = .loadingImage

    @Published public var image: UIImage? = nil

    @Published var textSet: RecognizedTextSet? = nil
    @Published var textBoxes: [TextBox] = []
    @Published var scanResult: ScanResult? = nil

//    @Published var showingBoxes = false
    @Published var showingBackground: Bool = true

    var scanTask: Task<(), Error>? = nil
    var classifyTask: Task<(), Error>? = nil

    public init() {
    }
}

extension Extractor {
    func begin() {
        self.detectTexts()
    }
}

extension Extractor {
    func reset() {
        state = .loadingImage
        image = nil
        
        textSet = nil
        textBoxes = []
        scanResult = nil
        
//        showingBoxes = false
        showingBackground = true

        cancelAllTasks()
        scanTask = nil
        classifyTask = nil
    }
    
    func cancelAllTasks() {
        scanTask?.cancel()
        classifyTask?.cancel()
    }
}
