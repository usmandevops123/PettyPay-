import SwiftUI

@main
struct pettypay1App: App {

    @StateObject var bill = BillStore()
    @StateObject var people = PeopleStore()
    @StateObject var model = ReceiptModel()
    @StateObject var assignments = ItemAssignmentStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(bill)
                .environmentObject(people)
                .environmentObject(model)
                .environmentObject(assignments)
        }
    }
}

