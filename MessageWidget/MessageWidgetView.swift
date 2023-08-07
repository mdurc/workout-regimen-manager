//
//  MessageWidgetView.swift
//  text-widget
//
//  Created by Matthew Durcan on 8/6/23.
//

import Foundation
import SwiftUI
import WidgetKit


struct GruvboxStyle {
    static let backgroundColor = Color(red: 40/255, green: 40/255, blue: 40/255)
    static let primaryTextColor = Color(red: 235/255, green: 219/255, blue: 178/255)
    static let secondaryTextColor = Color(red: 180/255, green: 98/255, blue: 99/255)
    static let accentColor = Color(red: 146/255, green: 131/255, blue: 116/255)
    static let fontFamily = "Courier"
}

struct MessageWidgetView: View {
    let message: String
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            GruvboxStyle.backgroundColor.edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                switch widgetFamily {
                        case .systemLarge:
                            HStack {
                                Text("Date:")
                                    .font(.headline)
                                    .foregroundColor(GruvboxStyle.primaryTextColor)
                                Text(getFormattedDate(mode: "EEEE, MMMM d"))
                                    .font(.headline)
                                    .foregroundColor(GruvboxStyle.accentColor)
                            }

                            HStack {
                                Text("Workout:")
                                    .font(.headline)
                                    .foregroundColor(GruvboxStyle.primaryTextColor)
                                Text(message)
                                    .font(.headline)
                                    .foregroundColor(GruvboxStyle.accentColor)
                            }
                            
                            Spacer()
                            Text("mattd")
                                .font(.custom(GruvboxStyle.fontFamily, size: 20))
                                .foregroundColor(GruvboxStyle.secondaryTextColor)
                        case .systemMedium:
                            // For medium widget, display only the "Date:" title
                            HStack {
                                Text("Date:")
                                    .font(.headline)
                                    .foregroundColor(GruvboxStyle.primaryTextColor)
                                Text(getFormattedDate(mode: "EEEE, MMMM d"))
                                    .font(.headline)
                                    .foregroundColor(GruvboxStyle.accentColor)
                            }

                            HStack {
                                Text("Workout:")
                                    .font(.headline)
                                    .foregroundColor(GruvboxStyle.primaryTextColor)
                                Text(message)
                                    .font(.headline)
                                    .foregroundColor(GruvboxStyle.accentColor)
                            }
                            Spacer()
                            Text("mattd")
                                .font(.custom(GruvboxStyle.fontFamily, size: 20))
                                .foregroundColor(GruvboxStyle.secondaryTextColor)
                        case .systemSmall:
                            // For small widget, display only the day of the week and the workout message
                            Text(getFormattedDate(mode: "EEEE"))
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(GruvboxStyle.primaryTextColor)
                            Text(message)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(GruvboxStyle.primaryTextColor)
                        case .accessoryInline:
                            Text(message)
                                .font(.system(size: 22, weight: .bold))
                        default:
                            Text("Some other WidgetFamily in the future.")
                }
                
            }
            .padding()
        }
    }

    private func getFormattedDate(mode: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = mode
        return formatter.string(from: Date())
    }
}

