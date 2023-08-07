//
//  MessageWidgetBundle.swift
//  MessageWidget
//
//  Created by Matthew Durcan on 8/6/23.
//

import WidgetKit
import SwiftUI

struct MessageWidget: Widget {
    let kind: String = "MessageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MessageWidgetProvider()) { entry in
            MessageWidgetView(message: entry.message)
        }
        .configurationDisplayName("Message Widget")
        .description("Displays a different message based on the day of the week.")
    }
}

@main
struct MessageWidgetBundle: WidgetBundle {
    var body: some Widget {
        MessageWidget()
    }
}
