//
//  ContentView.swift
//  workout-regimen-manager
//
//  Created by Matthew Durcan on 8/6/23.
//

import SwiftUI
import Alamofire
import AlamofireImage
import WidgetKit

@main
struct text_widgetApp: App {
    init(){
        
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            @State var manager = [
                "Sunday": "Rest Day",
                "Monday": "Pull Day",
                "Tuesday": "Push Day",
                "Wednesday": "Leg Day",
                "Thursday": "Pull Day",
                "Friday": "Push Day",
                "Saturday": "Leg Day"
            ]
            
            
            for (managerKey, managerValue) in manager {
                let dataToShare = managerValue
                SharedDataManager.shared.saveData(dataToShare, forKey: managerKey)
            }
            
            let pullDay = "3 SETS OF EACH\nScapula Pull ups - 10-12 REPS\nDead Hangs - 15-20 SECONDS\nOne Arm Rows - 12-15 REPS\nFL Raises - 4-6 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPull Ups - 8-10 REPS\nBicep Curls - 8 REPS\nChin Ups - 8-10 REPS\nWall Handstand - 30 SECONDS\nHollow Body Hold - MAX ~45-60s"
            let pushDay = "3 SETS OF EACH\nScapula Push-ups - 12-15 REPS\nPlanche Lean - 15-20 SECONDS\nPseudo Planche Pushups - 12-15 REPS\nArcher Pushups - 10-12 REPS\nParallel Bar Dips - 8-10 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPike Push-Ups - 12-15 REPS\nDiamond Push Up - 12-15 REPS\nSide Plank - 45 SECONDS\nWall Handstand - 30 SECONDS\nHollow Body Hold - MAX ~45-60s"
            let legDay = "3 SETS OF EACH\nBodyweight Squats - 10 REPS\nBridge Ups - 25 REPS\nLunges - 10 REPS\nArcher Squats - 10 REPS\nHorse Stance - 45 SECONDS\nCalf Raises - 25 REPS\nBulgarian Split Squats - 10-12 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPistol Squats - 5 REPS\nSingle Leg Planks - 30 SECONDS\nHollow Body Holds - MAX ~45-60s"
            let restDay=""
            
            
            SharedDataManager.shared.saveData(pullDay, forKey: "pulldayText")
            SharedDataManager.shared.saveData(pushDay, forKey: "pushdayText")
            SharedDataManager.shared.saveData(legDay, forKey: "legdayText")
            SharedDataManager.shared.saveData(restDay, forKey: "restdayText")
            
            SharedDataManager.shared.saveData(pullDay, forKey: "originalpulldayText")
            SharedDataManager.shared.saveData(pushDay, forKey: "originalpushdayText")
            SharedDataManager.shared.saveData(legDay, forKey: "originallegdayText")
            SharedDataManager.shared.saveData(restDay, forKey: "originalrestdayText")
            
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {

    @State private var imageUrl: URL?

    @State private var timer: Timer? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var isRunning = false
    @State private var isShowingSettingsPopup = false
    @State private var customizingPlan = false
    @State private var hasEdits = false
    
    @State private var isImageVisible = false
    @State private var motivationText = "Show Motivation"

    @State private var submissionString: String = ""
    @State private var searchQuery="kittens"
    
    @State private var setCount = 0
    @AppStorage("showSets") private var showSets = false
    
    @State private var day = ""
    
    @State private var bindTextDay = ""

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
                    if showSets{
                        Text("\(setCount)")
                            .onTapGesture {
                                setCount+=1
                            }
                            .foregroundColor(.gruvboxForeground)
                            .font(.system(size: 40))
                            .offset(x:-70)
                            .offset(y: -75)
                            .padding(.bottom, -90)
                            .bold()
                    }
                    Button(action: {
                        isShowingSettingsPopup = true
                        bindTextDay = getTextFromWeekDay(using: getDayOfWeekString())
                    }) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.gruvboxForeground)
                    }
                    .offset(y: -50)
                    .offset(x:-40)
                    
                    
                }
                
                
                Text("\(formattedElapsedTime)")
                    .font(.system(size: 70, design: .monospaced))
                    .foregroundColor(.gruvboxForeground)
                    .frame(width: 400)

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
                    Text(getSharedDataFromKey(using: getDayOfWeekString()).uppercased())
                            .foregroundColor(.gruvboxForeground)
                            .font(.system(size: 18, weight: .heavy))
                    workoutPrint(using: getTextFromWeekDay(using: getDayOfWeekString()))
                }
                .padding(.bottom,-70)
                
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
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack{
                    
                    
                    Text("Search:")
                        .font(.headline)
                        .foregroundColor(.gruvboxForeground)
                        .offset(x:-5)
                    
                    TextEditor(text: $submissionString)
                        .border(Color(rgb: (235,219,178)), width: 1)
                        .cornerRadius(1)
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
                
                HStack{
                    Text("Edit "+getDayOfWeekString()+" (+other days with same workout):")
                        .font(.headline)
                        .foregroundColor(.gruvboxForeground)
                        .padding()
                    Button("Sets") {
                        setCount = 0
                        showSets.toggle()
                    }
                    .foregroundColor(.gruvboxForeground)
                    .padding(5)
                    .controlSize(.large)
                    .background(Color.gruvboxAccent)
                    .cornerRadius(5)
                }
                    EditableTextArea(text: $bindTextDay, hasEdits: $hasEdits)
                
                
                HStack(spacing: 20) {
                    Button("Save") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            setSharedDataValueOfKey(using: $bindTextDay.wrappedValue, and: workoutDayToTextName(using: getSharedDataFromKey(using: getDayOfWeekString())))
                            setSharedDataValueOfKey(using: getTextFromWeekDay(using: getDayOfWeekString()), and: weekDayToOriginalTextName(using: getDayOfWeekString()))
                            
                            hasEdits = false
                        }
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    .foregroundColor(.gruvboxForeground)
                    .padding()
                    .background(Color.gruvboxAccent)
                    .cornerRadius(10)
                    
                    
                    Button(action: {
                        isShowingSettingsPopup = false
                        setSharedDataValueOfKey(using: getSharedDataFromKey(using: weekDayToOriginalTextName(using: getDayOfWeekString())), and: workoutDayToTextName(using: getSharedDataFromKey(using: getDayOfWeekString())))
                        WidgetCenter.shared.reloadAllTimelines()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                            hasEdits = false
                        }
                    }){
                        Text("Close" + (hasEdits ? " and discard" : ""))
                    }
                    .foregroundColor(.gruvboxForeground)
                    .padding()
                    .background(Color.gruvboxAccent)
                    .cornerRadius(10)
                    
                    Button("Customize Plan") {
                        customizingPlan = true
                        
                        setSharedDataValueOfKey(using: $bindTextDay.wrappedValue, and: workoutDayToTextName(using: getSharedDataFromKey(using: getDayOfWeekString())))
                        setSharedDataValueOfKey(using: getTextFromWeekDay(using: getDayOfWeekString()), and: weekDayToOriginalTextName(using: getDayOfWeekString()))
                        
                        hasEdits = false
                        WidgetCenter.shared.reloadAllTimelines()
                        
                        
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
            if customizingPlan {
                CustomPlanPopup(customizingPlan: $customizingPlan, isShowingSettingsPopup: $isShowingSettingsPopup)
            }
        }
    }
    
    
    private func workoutDayToTextName(using string: String) -> String {
        return string.lowercased().replacingOccurrences(of: " ", with: "") + "Text"
    }
    
    private func weekDayToOriginalTextName(using string: String) -> String {
        return "original"+string.lowercased().replacingOccurrences(of: " ", with: "") + "Text"
    }
    
    
    private func workoutPrint(using text: String) -> some View {
        Text(text)
            .foregroundColor(.gruvboxForeground)
            .bold()
    }
    
    private func getDayOfWeekString() -> String{
        let date = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
            case 1: return "Sunday"
            case 2: return "Monday"
            case 3: return "Tuesday"
            case 4: return "Wednesday"
            case 5: return "Thursday"
            case 6: return "Friday"
            case 7: return "Saturday"
            default: return "Sunday"
        }
    }
    
    private func getTextFromWeekDay(using day: String) -> String {
        let textkey = workoutDayToTextName(using: getSharedDataFromKey(using: day))
        
        return getSharedDataFromKey(using: textkey)
    }
    
    private func getSharedDataFromKey(using inputData: String) -> String {
        if let sharedData = SharedDataManager.shared.getData(forKey: inputData) as? String {
            return sharedData
        } else {
            return "unknown"
        }
    }
    
    private func setSharedDataValueOfKey(using inputData: String, and key: String ){
        SharedDataManager.shared.saveData(inputData, forKey: key)
    }
    
    private struct EditableTextArea: View {
        @Binding var text: String
        @Binding var hasEdits: Bool
        
        
        

        var body: some View {
            VStack {
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.gruvboxForeground)
                    .background(Color.gruvboxBackground)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(rgb: (235,219,178)), lineWidth: 1)
                    )
                    .onChange(of: text) { _ in
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
    
    init(rgb: (Int, Int, Int)) {
            let red = Double(rgb.0) / 255.0
            let green = Double(rgb.1) / 255.0
            let blue = Double(rgb.2) / 255.0
            self.init(red: red, green: green, blue: blue)
        }
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


private struct CustomPlanPopup: View {
    @Binding var customizingPlan: Bool
    @Binding var isShowingSettingsPopup: Bool
    
    let daysOfWeek = ["Monday", "Thursday", "Tuesday", "Friday", "Wednesday", "Saturday", "Sunday"]
    @State private var editableDays: [String: String] = [:]
    @State private var originalEditableDays: [String: String] = [:]
    

    @FocusState private var focusedField: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                    .frame(height: 30)
                Text("Edit Plan")
                    .font(.headline)
                    .foregroundColor(.gruvboxForeground)
                    .padding([.top, .leading])

                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        VStack {
                            Text(day + ":")
                                .foregroundColor(.gruvboxForeground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if let editableText = editableDays[day] {
                                TextField("", text: Binding(
                                    get: { editableText },
                                    set: { newValue in
                                        editableDays[day] = newValue
                                    }
                                ))
                                .foregroundColor(.gruvboxForeground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing)
                                .focused($focusedField, equals: true)
                                .onAppear {
                                    self.focusedField = true
                                }
                            } else {
                                Text(getWorkoutDay(day: day))
                                    .foregroundColor(.gruvboxForeground)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.trailing)
                                    .onTapGesture {
                                        editableDays[day] = getWorkoutDay(day: day)
                                    }
                            }
                        }
                        .padding()
                        .background(Color.gruvboxBackground)
                        .border(Color.gruvboxAccent, width: 1)
                        .cornerRadius(1)
                    }
                }
                
                Spacer()
                    .frame(height: 30)
                
                HStack{
                    Button("Save") {
                        for (day, editableText) in editableDays {
                            SharedDataManager.shared.saveData(editableText, forKey: day)
                        }
                        WidgetCenter.shared.reloadAllTimelines()
                        customizingPlan = false
                        isShowingSettingsPopup = false
                    }
                    .foregroundColor(.gruvboxForeground)
                    .padding()
                    .background(Color.gruvboxAccent)
                    .cornerRadius(10)
                    .offset(y: 10)
                    
                    Button("Cancel") {
                        editableDays = originalEditableDays
                        WidgetCenter.shared.reloadAllTimelines()
                        customizingPlan = false
                        isShowingSettingsPopup = false
                    }
                    .foregroundColor(.gruvboxForeground)
                    .padding()
                    .background(Color.gruvboxAccent)
                    .cornerRadius(10)
                    .offset(y: 10)
                    
                }

                Spacer()
                    .frame(height: 40)
            }
            .padding()
            .background(Color.gruvboxBackground)
            .cornerRadius(10)
            .frame(width: 370)
        }
        .onAppear {
            originalEditableDays = editableDays
        }
    }
    
    private func getWorkoutDay(day: String) -> String {
        if let sharedData = SharedDataManager.shared.getData(forKey: day) as? String {
            return sharedData
        } else {
            return "unknown"
        }
    }
}

