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
        MessageEntry(date: Date(), message: "Placeholder Message")
    }

    func getSnapshot(in context: Context, completion: @escaping (MessageEntry) -> ()) {
        let entry = MessageEntry(date: Date(), message: "Placeholder Message")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [MessageEntry] = []

        let currentDate = Date()
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: currentDate)

        let messages = [
            "Sunday": "Rest Day",
            "Monday": "Pull Day",
            "Tuesday": "Push Day",
            "Wednesday": "Leg Day",
            "Thursday": "Pull Day",
            "Friday": "Push Day",
            "Saturday": "Leg Day"
        ]

        if let message = messages[calendar.weekdaySymbols[dayOfWeek - 1]] {
            let entry = MessageEntry(date: currentDate, message: message)
            entries.append(entry)
        }

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}
