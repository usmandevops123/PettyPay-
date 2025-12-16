import UIKit
import Vision
import CoreImage

public struct ParsedLine {
    public let text: String
    public let price: Double?
}

public final class ReceiptOCRHelper {

    private lazy var textRequest: VNRecognizeTextRequest = {
        let r = VNRecognizeTextRequest()
        r.recognitionLevel = .accurate
        r.usesLanguageCorrection = true
        r.recognitionLanguages = ["en-US", "it-IT", "de-DE", "fr-FR"]
        return r
    }()

    public init() {}

    public func processAndParse(image: UIImage, completion: @escaping ([ParsedLine]) -> Void) {

        guard let cg = image.cgImage else {
            completion([])
            return
        }

        let handler = VNImageRequestHandler(cgImage: cg, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([self.textRequest])
                guard let observations = self.textRequest.results else {
                    completion([]); return
                }


                var tokens: [(String, CGRect)] = []

                for obs in observations {
                    if let top = obs.topCandidates(1).first {
                        tokens.append((top.string, obs.boundingBox))
                    }
                }

                var parsed: [ParsedLine] = []
                for (text, _) in tokens {
                    if let price = Self.extractPrice(text) {
                        parsed.append(ParsedLine(text: text, price: price))
                    } else {
                        parsed.append(ParsedLine(text: text, price: nil))
                    }
                }

                completion(parsed)

            } catch {
                completion([])
            }
        }
    }

    private static func extractPrice(_ text: String) -> Double? {
        let regex = try! NSRegularExpression(pattern: #"[0-9]+([.,][0-9]{2})"#)
        let ns = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: ns.length))

        guard let m = matches.last else { return nil }

        var val = ns.substring(with: m.range)

        if val.contains(",") { val = val.replacingOccurrences(of: ",", with: ".") }

        return Double(val)
    }
}

