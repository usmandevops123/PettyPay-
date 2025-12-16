import SwiftUI
import Combine

final class ItemAssignmentStore: ObservableObject {
    @Published var assigned: [String: [Person]] = [:]
}

