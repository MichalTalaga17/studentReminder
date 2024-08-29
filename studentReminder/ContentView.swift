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
    
    var body: some View {
        NavigationSplitView {
            VStack {
                Text("Time remaining until May 12:")
                    .font(.headline)
                Text(timeRemainingFormatted())
                    .font(.largeTitle)
                    .padding()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            .padding()
            List {
                ForEach(items) { item in
                    NavigationLink {
                        VStack {
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            Text("Math tasks completed: \(item.mathTasksCompleted)")
                                .font(.headline)
                            Stepper("Add Math Tasks", value: Binding(
                                get: { item.mathTasksCompleted },
                                set: { newValue in
                                    withAnimation {
                                        item.mathTasksCompleted = newValue
                                    }
                                }
                            ), in: 0...100)
                        }
                        .padding()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                            Text("Math tasks completed: \(item.mathTasksCompleted)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Tasks Reminder")
            .navigationBarTitleDisplayMode(.inline)
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
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
        
        return calendar.dateComponents([.day, .hour, .minute], from: currentDate, to: nextMay12)
    }
    
    private func timeRemainingFormatted() -> String {
        let remainingTime = timeRemainingUntilMay12()
        let days = remainingTime.day ?? 0
        let hours = remainingTime.hour ?? 0
        let minutes = remainingTime.minute ?? 0
        
        return "\(days) days, \(hours) hours"
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
