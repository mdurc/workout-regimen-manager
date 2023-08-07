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
    
    var plan: String
    
    init(message: String) {
        self.message = message
        self.plan = ""
        switch  getDayOfWeek(){
            case .monday, .thursday:
                self.plan = getPlan(using: "pullDay")
            case .tuesday, .friday:
                self.plan = getPlan(using: "pushDay")
            case .wednesday, .saturday:
                self.plan = getPlan(using: "legDay")
            case .sunday:
                self.plan = getPlan(using: "restDay")
        }
        
    }


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
                            .offset(y:-10)
                            Text(plan)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(GruvboxStyle.primaryTextColor)
                                .padding(.bottom,-50)
                                .padding(.top,-10)
                                .padding(.leading,16)
                                .offset(y:-10)
                                .offset(x:-14)
                            
                            Spacer()
                            Text("mattd")
                                .font(.custom(GruvboxStyle.fontFamily, size: 20))
                                .foregroundColor(GruvboxStyle.secondaryTextColor)
                                .padding(.top,-30)
                                .offset(y:20)
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
                            Text("unsupported widget size")
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
    
    enum DayOfWeek {
        case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    }

    
    private func getDayOfWeek() -> DayOfWeek {
            let date = Date()
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date)
            switch weekday {
                case 1: return .sunday
                case 2: return .monday
                case 3: return .tuesday
                case 4: return .wednesday
                case 5: return .thursday
                case 6: return .friday
                case 7: return .saturday
                default: return .sunday
            }
        }
    
    private func getPlan(using inputData: String) -> String {
        if let sharedData = SharedDataManager.shared.getData(forKey: inputData) as? String {
            //print("Widget received data: \(sharedData)")
            return sharedData
        } else {
            //print("No shared data available")
        }
        return "none"
    }
}


