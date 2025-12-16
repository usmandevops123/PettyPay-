import SwiftUI
import Combine

final class ReceiptModel: ObservableObject {

    @Published var parsedLines: [ParsedLine] = []
    @Published var lastScannedImage: UIImage? = nil

    private let ocr = ReceiptOCRHelper()

    func process(image: UIImage) {
        self.lastScannedImage = image
        
        ocr.processAndParse(image: image) { [weak self] lines in
            DispatchQueue.main.async {
                self?.parsedLines = lines
            }
        }
    }

    var total: Double {
        parsedLines.compactMap { $0.price }.reduce(0, +)
    }
}

