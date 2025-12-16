import SwiftUI
import Combine

struct HomeView: View {
    
    @EnvironmentObject var bill: BillStore
    @EnvironmentObject var people: PeopleStore
    @EnvironmentObject var model: ReceiptModel
    @EnvironmentObject var assignments: ItemAssignmentStore
    
    @State private var showingScanner = false
    @State private var showPeoplePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // MARK: - Header
                    Text("Split Bill")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: - Bill Section
                    billSection
                    
                    // MARK: - People Section
                    peopleSection
                    
                    // MARK: - Items Section (OCR Results)
                    itemsSection
                    
                    // MARK: - Total
                    totalSection
                    
                    // MARK: - Scan Button
                    scanButton
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingScanner) {
            ScannerView { scannedImage in
                showingScanner = false
                if let image = scannedImage {
                    model.process(image: image)
                }
            }
        }
        .sheet(isPresented: $showPeoplePicker) {
            PeoplePickerSheet()
                .environmentObject(people)
        }
    }
}

//
// MARK: - Bill Section
//
extension HomeView {
    
    var billSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bill")
                .font(.headline)
            
            HStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .foregroundColor(.gray)
                
                TextField("Enter bill name", text: $bill.billName)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

//
// MARK: - People Section
//
extension HomeView {
    
    var peopleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text("Who's joining?")
                    .font(.headline)
                Spacer()
                
                Button {
                    showPeoplePicker = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
            }
            
            if people.people.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.2")
                        .font(.system(size: 38))
                        .foregroundColor(.gray)
                    
                    Text("No one selected")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(people.people) { person in
                            Text(person.name)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.15))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
}

//
// MARK: - ITEMS SECTION
//
extension HomeView {
    
    var itemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Items")
                .font(.headline)
            
            if model.parsedLines.isEmpty {
                Text("No items scanned yet")
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                
            } else {
                ForEach(model.parsedLines, id: \.text) { line in
                    itemRow(line)
                }
            }
        }
    }
    
    func itemRow(_ line: ParsedLine) -> some View {
        HStack {
            
            // LEFT COLUMN — ITEM NAME
            Text(cleanItemName(line.text, price: line.price))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // RIGHT COLUMN — PRICE
            if let price = line.price {
                Text(String(format: "€ %.2f", price))
                    .bold()
                    .foregroundColor(.blue)
            } else {
                Text("--")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

//
// MARK: - TOTAL SECTION
//
extension HomeView {
    
    var totalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Total")
                .font(.headline)
            
            HStack {
                Text("Grand Total:")
                    .font(.headline)
                
                Spacer()
                
                Text("€ \(String(format: "%.2f", model.total))")
                    .font(.title3.bold())
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

//
// MARK: - Scan Button
//
extension HomeView {
    
    var scanButton: some View {
        Button {
            showingScanner = true
        } label: {
            HStack {
                Image(systemName: "camera.viewfinder")
                Text("Scan Receipt")
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding(.top)
    }
}

//
// MARK: - Helper
//
extension HomeView {
    func cleanItemName(_ text: String, price: Double?) -> String {
        guard let price = price else { return text }
        
        let dot = String(format: "%.2f", price)
        let comma = dot.replacingOccurrences(of: ".", with: ",")
        
        return text
            .replacingOccurrences(of: dot, with: "")
            .replacingOccurrences(of: comma, with: "")
            .replacingOccurrences(of: "€", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

