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
                    Button(action: { isAddingItem = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Tasks Reminder")
            .navigationBarTitleDisplayMode(.inline)
        } detail: {
            Text("Select an item")
        }
        .sheet(isPresented: $isAddingItem) {
            VStack {
                Text("Add New Session")
                    .font(.headline)
                DatePicker("Date", selection: $newItemDate, displayedComponents: .date)
                    .padding()
                TextField("Enter math tasks completed", text: $newTaskCount)
                    .keyboardType(.numberPad)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add Session") {
                    addItem()
                    isAddingItem = false
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
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
        
        return "\(days) days, \(hours) hours"
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
