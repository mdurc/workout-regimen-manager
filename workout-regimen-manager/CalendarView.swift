//
//  CalendarView.swift
//  workout-regimen-manager
//
//  Created by Matthew Durcan on 9/3/23.
//

import SwiftUI
func didCompleteWorkout(date: Date) -> Bool{
    if let storedBool = SharedDataManager.shared.getData(forKey: "\(Calendar.current.dateComponents([.year, .month, .day], from: date))completedWorkout") as? Bool {
        return storedBool
    }
    return false
}

struct CalendarView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentDate = Date()
    @State private var displayDate = Date()
    @State private var completedWorkout = didCompleteWorkout(date: Date())
    var body: some View {
        ZStack(alignment: .top) {
            Color.gruvboxBackground
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack{
                    VStack(alignment: .leading){
                        Text("Current date: \(Calendar.current.component(.month, from: currentDate))/\(Calendar.current.component(.day, from: currentDate))/\(Calendar.current.component(.year, from: currentDate)%100)")
                            .foregroundColor(.gruvBlue)
                            .fontWeight(.heavy)
                            .offset(y: 15)
                        Button(action: {
                            displayDate = currentDate
                        }) {
                            Text("Today")
                        }
                        .foregroundColor(.gruvboxForeground)
                        .padding(5)
                        .background(Color.buttonBlue)
                        .cornerRadius(10)
                        .offset(y: 15)
                    }
                    Button(action: {
                        completedWorkout.toggle()
                        SharedDataManager.shared.saveData(completedWorkout, forKey: "\(Calendar.current.dateComponents([.year, .month, .day], from: displayDate))completedWorkout")
                    }) {
                        if completedWorkout{
                            Text("Completed")
                                .foregroundColor(.gruvboxBackground)
                                .padding()
                                .background(Color.successColor)
                                .cornerRadius(10)
                        }else{
                            Text("Incomplete")
                                .foregroundColor(.gruvboxForeground)
                                .padding()
                                .background(Color.buttonBlue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.leading, 40)
                }
                
                CalendarHeaderView(currentDate: $currentDate, displayDate: $displayDate)
                    .padding(.top, 20)
                
                CalendarMonthView(currentDate: $currentDate, displayDate: $displayDate, completedWorkout: $completedWorkout)
                
                Text("Journal Entry: \(Calendar.current.component(.month, from: displayDate))/\(Calendar.current.component(.day, from: displayDate))/\(Calendar.current.component(.year, from: displayDate)%100)")
                    .foregroundColor(.gruvboxForeground)
                    .fontWeight(.heavy)
                EditableTextArea(textDataManager: TextDataManager(displayDate: displayDate))
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left").font(Font.system(size: 12).weight(.bold)).foregroundColor(.redMenu)
                    Text("Back").padding(.leading, -5).font(Font.system(size: 15).weight(.bold)).foregroundColor(.redMenu)
                }
        })
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            (displayDate, displayDate) = (Date(), displayDate)
        }
        
    }
}

struct CalendarHeaderView: View {
    @Binding var currentDate: Date
    @Binding var displayDate: Date
    
    var body: some View {
        HStack {
            Button(action: {
                self.displayDate = Calendar.current.date(byAdding: .month, value: -1, to: self.displayDate)!
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gruvBlue)
                    .fontWeight(.heavy)
            }
            
            Text(getFormattedDate())
                .font(.title)
                .frame(width: 240)
                .foregroundColor(.gruvBlue)
            
            
            Button(action: {
                self.displayDate = Calendar.current.date(byAdding: .month, value: 1, to: self.displayDate)!
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gruvBlue)
                    .fontWeight(.heavy)
            }
        }
        .padding()
    }
    
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: displayDate)
    }
}

struct CalendarMonthView: View {
    @Binding var currentDate: Date
    @Binding var displayDate: Date
    @Binding var completedWorkout: Bool
    
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 10) {
                ForEach(monthDates(), id: \.self) { date in
                    CalendarDayView(date: date, currentDate: $currentDate, displayDate: $displayDate, completedWorkout: $completedWorkout)
                }
            }
            .padding()
        }
    }
    
    func monthDates() -> [Date] {
        var startDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: displayDate))!
        
        let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
        
        var dates: [Date] = []
        
        while startDate <= endDate {
            dates.append(startDate)
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }
        
        return dates
    }
}

struct CalendarDayView: View {
    let date: Date
    @Binding var currentDate: Date
    @Binding var displayDate: Date
    @Binding var completedWorkout: Bool
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .frame(width: 30, height: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isDisplayDate(date: date) ? .gruvboxForeground : Color.clear, lineWidth: isDisplayDate(date: date) ? 4 : 0)
            )
            .background(
                Group {
                    if didCompleteWorkout(date: date){
                        Color.successColor.opacity(0.8)
                    }else if isCurrentDate(date: date) {
                        Color.cyanMenu.opacity(0.5)
                    } else if hasNotes(date: date) {
                        Color.calTextColor.opacity(0.1)
                    } else {
                        Color.clear
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundColor(.gruvboxForeground)
            .onTapGesture {
                displayDate = date
                completedWorkout = didCompleteWorkout(date: displayDate)
            }
    }
    
    func didCompleteWorkout(date: Date) -> Bool{
        if let storedBool = SharedDataManager.shared.getData(forKey: "\(Calendar.current.dateComponents([.year, .month, .day], from: date))completedWorkout") as? Bool {
            return storedBool
        }
        return false
    }
    
    func hasNotes(date: Date) -> Bool {
        if let storedText = SharedDataManager.shared.getData(forKey: "\(Calendar.current.dateComponents([.year, .month, .day], from: date))") as? String {
            if storedText != ""{
                return true
            }
        }
        return false
    }
    
    func isCurrentDate(date: Date) -> Bool {
        let specificDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: date)
        let targetDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: currentDate)
        
        return specificDateComponents == targetDateComponents
    }
    func isDisplayDate(date: Date) -> Bool {
        let specificDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: date)
        let targetDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: displayDate)
        
        return specificDateComponents == targetDateComponents
    }
}


private struct EditableTextArea: View {
    @ObservedObject var textDataManager: TextDataManager

    var body: some View {
        VStack {
            TextEditor(text: $textDataManager.text)
                .scrollContentBackground(.hidden)
                .foregroundColor(.gruvboxForeground)
                .background(Color.gruvboxBackground)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(rgb: (235,219,178)), lineWidth: 1)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                )
                .onChange(of: textDataManager.text) { _ in
                    textDataManager.saveText()
                }
        }
    }
}


class TextDataManager: ObservableObject, Equatable {
    static func == (lhs: TextDataManager, rhs: TextDataManager) -> Bool {
        return lhs.text == rhs.text
    }

    @Published var text: String = ""
    var displayDate: Date

    init(displayDate: Date) {
        self.displayDate = displayDate
        if let storedText = SharedDataManager.shared.getData(forKey: "\(Calendar.current.dateComponents([.year, .month, .day], from: displayDate))") as? String {
            self.text = storedText
        }else{
            self.text = ""
        }
    }

    func saveText() {
        SharedDataManager.shared.saveData(text, forKey: "\(Calendar.current.dateComponents([.year, .month, .day], from: displayDate))")
    }
}
