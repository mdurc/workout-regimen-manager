//
//  MessageWidget.swift
//  MessageWidget
//
//  Created by Matthew Durcan on 8/6/23.
//

import WidgetKit
import SwiftUI

struct MessageEntry: TimelineEntry {
    let date: Date
    let message: String
}

struct MessageWidgetProvider: TimelineProvider {
    typealias Entry=MessageEntry
    func placeholder(in context: Context) -> MessageEntry {
        MessageEntry(date: Date(), message: "Workout")
    }

    func getSnapshot(in context: Context, completion: @escaping (MessageEntry) -> ()) {
        let entry = MessageEntry(date: Date(), message: "Workout")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [MessageEntry] = []

        let currentDate = Date()
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        var dayString = ""
        switch dayOfWeek {
            case 1: dayString = "Sunday"
            case 2: dayString = "Monday"
            case 3: dayString = "Tuesday"
            case 4: dayString = "Wednesday"
            case 5: dayString = "Thursday"
            case 6: dayString = "Friday"
            case 7: dayString = "Saturday"
            default: dayString = "Sunday"
        }


        let entry = MessageEntry(date: currentDate, message: searchForWorkoutDay(using: dayString))
        entries.append(entry)

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
    
    func searchForWorkoutDay(using inputData: String) -> String {
        if let sharedData = SharedDataManager.shared.getData(forKey: inputData) as? String {
            return sharedData
        } else {
            return "N/A"
        }
    }
}
