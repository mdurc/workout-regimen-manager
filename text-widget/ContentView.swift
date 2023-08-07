//
//  ContentView.swift
//  text-widget
//
//  Created by Matthew Durcan on 8/6/23.
//

import SwiftUI
import Alamofire
import AlamofireImage


struct ContentView: View {

    @State private var imageUrl: URL?

    @State private var timer: Timer? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var isRunning = false
    @State private var isShowingSettingsPopup = false // Added for custom popup
    @State private var isEditing = false
    @State private var hasEdits = false
    @State private var isImageVisible = false
    @State private var motivationText = "Show Motivation"

    @State private var submissionString: String = ""
    @State private var searchQuery="kittens"

    
    @State private var day = "";



    @AppStorage("pullDay") private var pullDay = "3 SETS OF EACH\nScapula Pull ups - 10-12 REPS\nDead Hangs - 15-20 SECONDS\nOne Arm Rows - 12-15 REPS\nFL Raises - 4-6 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPull Ups - 8-10 REPS\nBicep Curls - 8 REPS\nChin Ups - 8-10 REPS\nWall Handstand - 30 SECONDS\nHollow Body Hold - MAX ~45-60s"
    @AppStorage("pushDay") private var pushDay = "3 SETS OF EACH\nScapula Push-ups - 12-15 REPS\nPlanche Lean - 15-20 SECONDS\nPseudo Planche Pushups - 12-15 REPS\nArcher Pushups - 10-12 REPS\nParallel Bar Dips - 8-10 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPike Push-Ups - 12-15 REPS\nDiamond Push Up - 12-15 REPS\nSide Plank - 45 SECONDS\nWall Handstand - 30 SECONDS\nHollow Body Hold - MAX ~45-60s"
    @AppStorage("legDay") private var legDay = "3 SETS OF EACH\nBodyweight Squats - 10 REPS\nBridge Ups - 25 REPS\nLunges - 10 REPS\nArcher Squats - 10 REPS\nHorse Stance - 45 SECONDS\nCalf Raises - 25 REPS\nBulgarian Split Squats - 10-12 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPistol Squats - 5 REPS\nSingle Leg Planks - 30 SECONDS\nHollow Body Holds - MAX ~45-60s"
    @AppStorage("restDay") private var restDay=""
    @AppStorage("originalRestDay") private var originalRestDay=""
    

    @AppStorage("originalPullDay") private var originalPullDay = "3 SETS OF EACH\nScapula Pull ups - 10-12 REPS\nDead Hangs - 15-20 SECONDS\nOne Arm Rows - 12-15 REPS\nFL Raises - 4-6 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPull Ups - 8-10 REPS\nBicep Curls - 8 REPS\nChin Ups - 8-10 REPS\nWall Handstand - 30 SECONDS\nHollow Body Hold - MAX ~45-60s"
    @AppStorage("originalPushDay") private var originalPushDay = "3 SETS OF EACH\nScapula Push-ups - 12-15 REPS\nPlanche Lean - 15-20 SECONDS\nPseudo Planche Pushups - 12-15 REPS\nArcher Pushups - 10-12 REPS\nParallel Bar Dips - 8-10 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPike Push-Ups - 12-15 REPS\nDiamond Push Up - 12-15 REPS\nSide Plank - 45 SECONDS\nWall Handstand - 30 SECONDS\nHollow Body Hold - MAX ~45-60s"
    @AppStorage("originalLegDay") private var originalLegDay = "3 SETS OF EACH\nBodyweight Squats - 10 REPS\nBridge Ups - 25 REPS\nLunges - 10 REPS\nArcher Squats - 10 REPS\nHorse Stance - 45 SECONDS\nCalf Raises - 25 REPS\nBulgarian Split Squats - 10-12 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPistol Squats - 5 REPS\nSingle Leg Planks - 30 SECONDS\nHollow Body Holds - MAX ~45-60s"

    

    var body: some View {
        
        ZStack {
            Color.gruvboxBackground
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                // Settings button
                HStack {
                    if isImageVisible {
                        if let imageUrl = imageUrl {
                            RemoteImageView(url: imageUrl)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                                .cornerRadius(10)
                                .onTapGesture {
                                    fetchRandomImage()
                                }
                                .offset(y: -50)
                                .offset(x: 100)
                                .padding(-85)
                            
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gruvboxForeground)
                                .padding(.top, -85)
                                .onTapGesture {
                                    fetchRandomImage()
                                }
                                .offset(x: 70)
                        }
                    }
                    Spacer()
                    Button(action: {
                        isShowingSettingsPopup = true // Show the custom popup
                        isEditing=true
                    }) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.gruvboxForeground)
                    }
                    .offset(y: -50)
                    .offset(x:-60)
                }
                
                
                Text("\(formattedElapsedTime)")
                    .font(.system(size: 70, design: .monospaced)) // Use monospaced font
                    .foregroundColor(.gruvboxForeground)
                    .frame(width: 400) // Adjust width to make it fixed

                HStack(spacing: 20) {
                    
                    Button(action: resetTimer) {
                        Text("Reset")
                            .foregroundColor(.gruvboxForeground)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .background(Color.gruvboxAccent)
                            .cornerRadius(10)
                    }
                    .font(.system(size:22))
                    
                    Button(action: {
                        if isRunning {
                            stopTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Text(isRunning ? "Stop" : "Start")
                            .foregroundColor(.gruvboxForeground)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .background(Color.gruvboxAccent)
                            .cornerRadius(10)
                    }
                    .font(.system(size:22))

                    
                }
                

                // Workout List
                VStack(spacing: 10) {
                    switch getDayOfWeek() {
                        case .sunday: // Sunday
                            Text("REST DAY")
                                .foregroundColor(.gruvboxForeground)
                                .font(.headline)
                            workoutListRestDay()
                        case .monday, .thursday: // Monday and Thursday (Pull Day)
                            Text("PULL DAY")
                                .foregroundColor(.gruvboxForeground)
                                .font(.headline)
                            workoutListPullDay()
                        case .tuesday, .friday: // Tuesday and Friday (Push Day)
                            Text("PUSH DAY")
                                .foregroundColor(.gruvboxForeground)
                                .font(.headline)
                            workoutListPushDay()
                        case .wednesday, .saturday: // Wednesday and Saturday (Leg Day)
                            Text("LEG DAY")
                                .foregroundColor(.gruvboxForeground)
                                .font(.headline)
                            workoutListLegDay()
                        }
                    }
                
        
                
                Spacer()
                
            }
            .padding(.top,100)
            if isShowingSettingsPopup{
                settingsPopup()
            }
        }
    }
    
    func fetchRandomImage() {
        let accessKey = "rlyN2iwO7k6KjZvNdahWPhSNoOzF2XVKJkUfdLkFvr4"
        
        let endpoint = "https://api.unsplash.com/photos/random"
        let headers: HTTPHeaders = ["Authorization": "Client-ID \(accessKey)"]
        let parameters: Parameters = ["query": searchQuery]
        
        AF.request(endpoint, method: .get, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: UnsplashResponse.self) { response in
                switch response.result {
                case .success(let unsplashResponse):
                    if let imageUrlString = unsplashResponse.urls["regular"],
                       let imageUrl = URL(string: imageUrlString) {
                        self.imageUrl = imageUrl
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }

    
    private func settingsPopup() -> some View {
        ZStack {
            Color.black.opacity(0.5) // Semi-transparent background
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack{
                    
                    
                    Text("Search:")
                        .font(.headline)
                        .foregroundColor(.gruvboxForeground)
                        .offset(x:-5)
                    
                    TextEditor(text: $submissionString)
                        .border(Color.gray, width: 1)
                        .frame(width:120, height: 35)
                        .offset(x:-5)
                        .autocapitalization(.none)
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.gruvboxAccent)
                        .background(Color.gruvboxBackground)
                        .onChange(of: submissionString) { newValue in
                            if newValue.hasSuffix("\n") {
                                searchQuery = submissionString
                                submissionString = "" // Clear the text
                            }
                        }
                    Button(action: {
                        isImageVisible.toggle()
                        fetchRandomImage()
                        motivationText = isImageVisible ? "Hide Motivation" : "Show Motivation"
                    }) {
                        if isImageVisible{
                            Text(motivationText)
                                .foregroundColor(.gruvboxBackground)
                                .padding()
                                .background(Color.gruvboxSecondary)
                                .cornerRadius(10)
                        }else{
                            Text(motivationText)
                                .foregroundColor(.gruvboxForeground)
                                .padding()
                                .background(Color.gruvboxAccent)
                                .cornerRadius(10)
                        }
                        
                    }
                }
                
                Text("Edit Workout:")
                    .font(.headline)
                    .foregroundColor(.gruvboxForeground)
                    .padding()
                
                let currentDay = getDayOfWeek()
                
                if currentDay == .monday || currentDay == .thursday{
                    EditableTextArea(text: $pullDay, isEditing: $isEditing, hasEdits: $hasEdits)
                }else if currentDay == .tuesday || currentDay == .friday {
                    EditableTextArea(text: $pushDay, isEditing: $isEditing, hasEdits: $hasEdits)
                } else if currentDay == .wednesday || currentDay == .saturday{
                    EditableTextArea(text: $legDay, isEditing: $isEditing, hasEdits: $hasEdits)
                } else { // rest Sunday
                    EditableTextArea(text: $restDay, isEditing: $isEditing, hasEdits: $hasEdits)
                }
                
                HStack(spacing: 20) {
                    Button("Save") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            switch currentDay {
                                case .monday, .thursday:
                                    pullDay = $pullDay.wrappedValue
                                case .tuesday, .friday:
                                    pushDay = $pushDay.wrappedValue
                                case .wednesday, .saturday:
                                    legDay = $legDay.wrappedValue
                                case .sunday:
                                    restDay = $restDay.wrappedValue
                            }
                            isEditing = false
                            hasEdits = false
                        }
                    }
                    .foregroundColor(.gruvboxForeground)
                    .padding()
                    .background(Color.gruvboxAccent)
                    .cornerRadius(10)
                    
                    Button("Close" + (hasEdits ? " and discard changes" : "")) {
                        isShowingSettingsPopup = false
                        if !hasEdits {
                            switch currentDay {
                                case .monday, .thursday:
                                    pullDay = $pullDay.wrappedValue
                                    originalPullDay = pullDay
                                case .tuesday, .friday:
                                    pushDay = $pushDay.wrappedValue
                                    originalPushDay = pushDay
                                case .wednesday, .saturday:
                                    legDay = $legDay.wrappedValue
                                    originalLegDay = legDay
                                case .sunday:
                                    restDay = $restDay.wrappedValue
                                    originalRestDay = restDay
                            }
                        }else{
                            switch currentDay {
                                case .monday, .thursday:
                                    pullDay=originalPullDay
                                case .tuesday, .friday:
                                    pushDay=originalPushDay
                                case .wednesday, .saturday:
                                    legDay=originalLegDay
                                case .sunday:
                                    restDay=originalRestDay
                            }
                        }
                        isEditing = false
                        hasEdits = false
                        
                    }
                    .foregroundColor(.gruvboxForeground)
                    .padding()
                    .background(Color.gruvboxAccent)
                    .cornerRadius(10)
                    
                }
                .padding(.top, 20)
            }
            .padding()
            .background(Color.gruvboxBackground)
            .cornerRadius(10)
        }
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
    
    private func workoutListPushDay() -> some View {
                Text(pushDay)
                    .foregroundColor(.gruvboxForeground)
        }
    private func workoutListRestDay() -> some View {
                Text(restDay)
                    .foregroundColor(.gruvboxForeground)
        }
    
    private func workoutListPullDay() -> some View {
                Text(pullDay)
                    .foregroundColor(.gruvboxForeground)
        }
    
    private func workoutListLegDay() -> some View {
            Text(legDay)
                .foregroundColor(.gruvboxForeground)
                .font(.headline)
        
        }
    
    private struct EditableTextArea: View {
        @Binding var text: String
        @Binding var isEditing: Bool
        @Binding var hasEdits: Bool
        
        
        

        var body: some View {
            VStack {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.gruvboxForeground)
                    .background(Color.gruvboxBackground)
                    .padding()
                    .onChange(of: text) { _ in
                        isEditing = true
                        hasEdits = true
                    }

                Divider()
            }
        }
    }
    
    
    
    private func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                elapsedTime += 0.01
            }
            RunLoop.current.add(timer!, forMode: .common)
            isRunning = true
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func resetTimer() {
        stopTimer()
        elapsedTime = 0
    }

    private var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime - Double(Int(elapsedTime))) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}


extension Color {
    static let gruvboxBackground = Color(red: 40/255, green: 40/255, blue: 40/255)
    static let gruvboxForeground = Color(red: 235/255, green: 219/255, blue: 178/255)
    static let gruvboxAccent = Color(red: 146/255, green: 131/255, blue: 116/255)
    static let gruvboxSecondary = Color(red: 180/255, green: 98/255, blue: 99/255)
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct RemoteImageView: View {
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .empty:
                ProgressView()
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct UnsplashResponse: Codable {
    let urls: [String: String]
}
