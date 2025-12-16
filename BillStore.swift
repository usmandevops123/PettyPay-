import SwiftUI
import Combine
final class BillStore: ObservableObject {
    @Published var billName: String = ""
}

