import SwiftUI
import Combine
struct Person: Identifiable {
    let id = UUID()
    let name: String
}

final class PeopleStore: ObservableObject {
    @Published var people: [Person] = []

    // ✅ RENAMED FUNCTION
    func addPerson(name: String) {
        people.append(Person(name: name))
    }
}

