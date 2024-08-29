//
//  Item.swift
//  studentReminder
//
//  Created by Michał Talaga on 29/08/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var mathTasksCompleted: Int
    
    init(timestamp: Date, mathTasksCompleted: Int = 0) {
        self.timestamp = timestamp
        self.mathTasksCompleted = mathTasksCompleted
    }
}
