//
//  ContentView.swift
//  studentReminder
//
//  Created by Michał Talaga on 29/08/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var isAddingItem = false
    @State private var newItemDate = Date()
    @State private var newTaskCount = ""

    // Computed property to calculate total tasks
    private var totalTasksCompleted: Int {
        items.reduce(0) { $0 + $1.mathTasksCompleted }
    }
    
    var body: some View {
        NavigationSplitView {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Czas pozostały do 12 maja:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(timeRemainingFormatted())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    
                    Text("Łączna liczba wykonanych zadań: \(totalTasksCompleted)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(10)
                .padding()
                
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Data: \(formatDate(item.timestamp))")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Zadania: \(item.mathTasksCompleted)")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Data: \(formatDate(item.timestamp))")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Zadania: \(item.mathTasksCompleted)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.insetGrouped)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isAddingItem = true }) {
                        Label("Dodaj Sesję", systemImage: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Przypomnienie Zadań")
            .navigationBarTitleDisplayMode(.inline)
        } detail: {
            Text("Wybierz element")
        }
        .sheet(isPresented: $isAddingItem) {
            VStack(spacing: 20) {
                Text("Dodaj Nową Sesję")
                    .font(.headline)
                DatePicker("Data", selection: $newItemDate, displayedComponents: .date)
                    .padding()
                TextField("Wprowadź liczbę zadań", text: $newTaskCount)
                    .keyboardType(.numberPad)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Dodaj Sesję") {
                    addItem()
                    isAddingItem = false
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
        }
    }

    private func addItem() {
        withAnimation {
            let taskCount = Int(newTaskCount) ?? 0
            let newItem = Item(timestamp: newItemDate, mathTasksCompleted: taskCount)
            modelContext.insert(newItem)
            // Reset input fields
            newTaskCount = ""
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func timeRemainingUntilMay12() -> DateComponents {
        let calendar = Calendar.current
        let currentDate = Date()
        let may12 = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentDate), month: 5, day: 12)) ?? Date()
        
        let nextMay12 = may12 > currentDate ? may12 : calendar.date(byAdding: .year, value: 1, to: may12) ?? may12
        
        return calendar.dateComponents([.day, .hour], from: currentDate, to: nextMay12)
    }
    
    private func timeRemainingFormatted() -> String {
        let remainingTime = timeRemainingUntilMay12()
        let days = remainingTime.day ?? 0
        let hours = remainingTime.hour ?? 0
        
        return "\(days) dni, \(hours) godzin"
    }
    
    // Helper function to format date with month names in Polish
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "d MMMM yyyy"  // Example format: "12 maja 2024"
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
