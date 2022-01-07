//
//  ContentView.swift
//  SHornCoreDataBudget
//
//  Created by Sam Horn on 11/3/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: UserTransaction.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \UserTransaction.tid, ascending: true)],
        animation: .default)
    private var transactions: FetchedResults<UserTransaction>
    @State private var isPresented: Bool = false
    @State private var name: String = ""
    @FocusState private var nameFieldIsFocused: Bool
    @State private var merchant: String = ""
    @FocusState private var merchantFieldIsFocused: Bool

    var body: some View {
        NavigationView {
            List {
                ForEach(transactions) { transaction in
                    NavigationLink {
                        HStack {
                            VStack {
                                Text(transaction.name ?? "")
                                Text(transaction.merchant ?? "")
                            }
                            Text("\(transaction.date!, formatter: itemFormatter)")
                        }
                        //Text("Item at \(transaction.date!, formatter: itemFormatter)")
                    } label: {
                        Text(transaction.date!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {isPresented=true}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
        .sheet(isPresented: $isPresented, onDismiss: {
            addTransaction(name: name, merchant: merchant)
        }) {
            Form {
                Section(header: Text("Name")) {
                    TextField(
                        "Transaction Name",
                        text: $name
                    )
                        .focused($nameFieldIsFocused)
                }
                Section(header: Text("Merchant")) {
                    TextField(
                        "Merchant",
                        text: $merchant
                    )
                        .focused($merchantFieldIsFocused)
                }
            }
        }
    }

    private func addTransaction(name: String, merchant: String) {
        withAnimation {
            let newItem = UserTransaction(context: viewContext)
            newItem.name = name
            newItem.merchant = merchant
            newItem.date = Date()
            newItem.tid = UUID()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { transactions[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
