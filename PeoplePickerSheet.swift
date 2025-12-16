import SwiftUI

struct PeoplePickerSheet: View {
    @EnvironmentObject var people: PeopleStore
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                TextField("Enter person name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button("Add Person") {
                    if !name.isEmpty {
                        $people.add(name: name)
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .navigationTitle("Add Person")
            .padding()
        }
    }
}

