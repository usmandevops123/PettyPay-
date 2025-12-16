import SwiftUI

struct ContentView: View {

    @EnvironmentObject var model: ReceiptModel
    @State private var showingScanner = false

    var body: some View {
        VStack(spacing: 20) {
            
            Button("Scan Receipt") {
                showingScanner = true
            }
            .font(.title2)
            .padding()
            
            List(model.parsedLines, id: \.text) { line in
                HStack {
                    Text(clean(line.text, price: line.price))
                    Spacer()
                    Text(line.price != nil ? String(format: "€ %.2f", line.price!) : "--")
                        .foregroundColor(.blue)
                }
            }
            
            Text("Total: € \(String(format: "%.2f", model.total))")
                .font(.title2)
                .bold()
        }
        .sheet(isPresented: $showingScanner) {
            ScannerView { img in
                if let img = img {
                    model.process(image: img)
                }
            }
        }
    }

    func clean(_ text: String, price: Double?) -> String {
        guard let p = price else { return text }
        return text.replacingOccurrences(of: String(format: "%.2f", p), with: "")
                   .replacingOccurrences(of: ",", with: ".")
                   .trimmingCharacters(in: .whitespaces)
    }
}

