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
import UserNotifications

func checkForPermission() {
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .authorized:
            dispatchNotification()
        case .denied:
            return
        case .notDetermined:
            notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                if didAllow {
                    dispatchNotification()
                }
            }
        default:
            return
        }
    }
}
    

func dispatchNotification(){
    let identifier = "workout-notification"
    let title = "Workout"
    let body = "Go workout"
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    let calendar = Calendar.current
    var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
    dateComponents.hour = 8
    dateComponents.minute = 0
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    
    notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    notificationCenter.add(request)
}

@main
struct text_widgetApp: App {
    init(){
        checkForPermission()

        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            @State var manager = [
                "Sunday": "Rest Day",
                "Monday": "Leg Gym",
                "Tuesday": "Push Gym",
                "Wednesday": "Pull Gym",
                "Thursday": "Leg Gym",
                "Friday": "Push Gym",
                "Saturday": "Pull Gym"
            ]
            
            
            for (managerKey, managerValue) in manager {
                SharedDataManager.shared.saveData(managerValue, forKey: managerKey)
            }
            
            let pullDay = "Calisthenics: 3 Sets of each, or 3 circuits\n--------\nScapula Pull ups - 10-12 REPS\nDead Hangs - 15-20 SECONDS\nOne Arm Rows - 12-15 REPS\nFL Raises - 4-6 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPull Ups - 8-10 REPS\nBicep Curls - 8 REPS\nChin Ups - 8-10 REPS\nWall Handstand - 30 SECONDS\nHollow Body Hold - MAX ~45-60s"
            let pushDay = "Calisthenics: 3 Sets of each, or 3 circuits\n--------\nScapula Push-ups - 12-15 REPS\nPlanche Lean - 15-20 SECONDS\nPseudo Planche Pushups - 12-15 REPS\nArcher Pushups - 10-12 REPS\nParallel Bar Dips - 8-10 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPike Push-Ups - 12-15 REPS\nDiamond Push Up - 12-15 REPS\nSide Plank - 45 SECONDS\nWall Handstand - 30 SECONDS\nHollow Body Hold - MAX ~45-60s"
            let legDay = "Calisthenics: 3 Sets of each, or 3 circuits\n--------\nBodyweight Squats - 10 REPS\nBridge Ups - 25 REPS\nLunges - 10 REPS\nArcher Squats - 10 REPS\nHorse Stance - 45 SECONDS\nCalf Raises - 25 REPS\nBulgarian Split Squats - 10-12 REPS\nSupported tuck - 10 REPS\nAbs leg lifts - 10 REPS\nPistol Squats - 5 REPS\nSingle Leg Planks - 30 SECONDS\nHollow Body Holds - MAX ~45-60s"
            let restDay="Rest"
            
            newWorkout(textData: pullDay, displayKey: "Pull Home")
            newWorkout(textData: pushDay, displayKey: "Push Home")
            newWorkout(textData: legDay, displayKey: "Leg Home")
            newWorkout(textData: restDay, displayKey: "Rest Day")
            
            
            let pullGym = "Gym: 3 Sets of each\n--------\nPull ups\nAbs\nPreacher Curls\nHammer Curls\nBicep Curls/Chin ups\nSeated Rows\nWide Lat pull-down\nRear delt flys"
            let pushGym = "Gym: 3 Sets of each\n--------\nMachine bench\nFly machine push\nChest machine push out\nShoulder Press\nTricep overhead\nCable lateral raises\nTricep pulldowns\nDips to failure\nPush-ups to failure\nAbs"
            let legGym = "Gym: 3 Sets of each\n--------\nLeg press\nLeg lift extension for thighs\nLeg curls for hamstrings\nCalves\nLeg abductors and adductors\nBulgarian Split Squats / Pistol squats"
            
            newWorkout(textData: pullGym, displayKey: "Pull Gym")
            newWorkout(textData: pushGym, displayKey: "Push Gym")
            newWorkout(textData: legGym, displayKey: "Leg Gym")
            
            
            let pushups = "Scapular Pushups\nPseudo Planche Pushups\nArcher Pushups\nPike Pushups\nDiamond Pushups"
            let abs = "Supported tuck w/hollow body decline\nAb leg lift\nPlank\nSide plank rotating twist\nBicycle Crunch"
            newWorkout(textData: pushups, displayKey: "Pushups")
            newWorkout(textData: abs, displayKey: "Abs")
            
        }
        func newWorkout(textData : String, displayKey: String){
            SharedDataManager.shared.saveData(textData, forKey: displayKey + "Text")
            SharedDataManager.shared.saveData(textData, forKey: "original" + displayKey + "Text")
        }
    }
    var body: some Scene {
        WindowGroup {
            HomeScreenView()
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
    @State private var viewPlans = false
    
    @State private var hasEdits = false
    @State private var noEditsFromCustomize = false
    
    @State private var isImageVisible = false
    @State private var motivationText = "Show Motivation"

    @State private var submissionString: String = ""
    @State private var searchQuery="kittens"
    
    @State private var setCount = 0
    @AppStorage("showSets") private var showSets = false
    
    @State private var day = ""
    
    @State private var bindTextDay = ""
    @State var keys = SharedDataManager.shared.keysEndingWithText()

    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack {
            Color.gruvboxBackground
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                HStack {
                    if isImageVisible {
                        if let imageUrl = imageUrl {
                            RemoteImageView(url: imageUrl)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 100)
                                .cornerRadius(10)
                                .onTapGesture {
                                    fetchRandomImage()
                                }
                                .offset(y: -50)
                                .offset(x: 200)
                                .padding(-85)
                            
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 120, height: 100)
                                .foregroundColor(.gruvboxForeground)
                                .padding(.top, -85)
                                .onTapGesture {
                                    fetchRandomImage()
                                }
                                .offset(x: 180)
                                .offset(y: -50)
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
                            .offset(x:-285)
                            .offset(y: -100)
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
                    .offset(y: -90)
                    .offset(x:-40)
                    
                    
                }
                
                
                let numberOfLines = numberOfLines(in: getTextFromWeekDay(using: getDayOfWeekString()))
                if numberOfLines < 16 {
                    Text("\(formattedElapsedTime)")
                        .font(.system(size: 70, design: .monospaced))
                        .foregroundColor(.gruvboxForeground)
                        .frame(width: 400)
                        .padding(.top, -46)
                        .padding(.bottom, 0)
                }else{
                    Text("\(formattedElapsedTime)")
                        .font(.system(size: 70, design: .monospaced))
                        .foregroundColor(.gruvboxForeground)
                        .frame(width: 400)
                        .padding(.top, -70)
                        .padding(.bottom, -10)
                }

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
                

                //Workout List
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
                        .disableAutocorrection(true)
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.gruvboxAccent)
                        .background(Color.gruvboxBackground)
                        .onChange(of: submissionString) { newValue in
                            if newValue.hasSuffix("\n") {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                searchQuery = submissionString
                                submissionString = "" //Clear the text
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
                EditableTextArea(text: $bindTextDay, hasEdits: $hasEdits, noEditsFromCustomize: $noEditsFromCustomize)
                
                
                HStack(spacing: 20) {
                    Button("Save") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
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
                    
                    VStack{
                        Button("Customize Plan") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                            customizingPlan = true
                            //auto save any edits, when entering customizing plan view
                            setSharedDataValueOfKey(using: $bindTextDay.wrappedValue, and: workoutDayToTextName(using: getSharedDataFromKey(using: getDayOfWeekString())))
                            setSharedDataValueOfKey(using: getTextFromWeekDay(using: getDayOfWeekString()), and: weekDayToOriginalTextName(using: getDayOfWeekString()))
                            hasEdits = false
                        }
                        .foregroundColor(.gruvboxForeground)
                        .padding(10)
                        .background(Color.gruvboxAccent)
                        .cornerRadius(10)
                        
                        Button("View Plans") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                            viewPlans = true
                        }
                        .foregroundColor(.gruvboxForeground)
                        .padding(10)
                        .background(Color.gruvboxAccent)
                        .cornerRadius(10)
                    }
                    

                    
                }
                .padding(.top, 20)
            }
            .padding()
            .background(Color.gruvboxBackground)
            .cornerRadius(10)
            if customizingPlan {
                CustomPlanPopup(customizingPlan: $customizingPlan, isShowingSettingsPopup: $isShowingSettingsPopup, bindTextDay: $bindTextDay, noEditsFromCustomize: $noEditsFromCustomize)
            }else if viewPlans {
                viewPlanPopup(viewPlans: $viewPlans, keys: $keys, noEditsFromCustomize: $noEditsFromCustomize, bindedDayText: $bindTextDay)
            }
        }
    }
    
    
    private func workoutDayToTextName(using string: String) -> String {
        return string + "Text"
    }
    
    private func weekDayToOriginalTextName(using day: String) -> String {
        return "original" + getSharedDataFromKey(using: day) + "Text"
    }
    
    
    private func workoutPrint(using text: String) -> some View {
        Text(text)
            .foregroundColor(.gruvboxForeground)
            .bold()
            .lineLimit(nil)
            .frame(width: 370)
    }
    
    private func numberOfLines(in text: String) -> Int {
        let lines = text.components(separatedBy: CharacterSet.newlines)
        return lines.count
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
            return "N/A"
        }
    }
    
    private func setSharedDataValueOfKey(using inputData: String, and key: String ){
        SharedDataManager.shared.saveData(inputData, forKey: key)
    }
    
    private struct EditableTextArea: View {
        @Binding var text: String
        @Binding var hasEdits: Bool
        @Binding var noEditsFromCustomize: Bool
        

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
                        if noEditsFromCustomize{
                            hasEdits = false
                            noEditsFromCustomize = false
                        }
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
    static let cyanMenu = Color(red: 7/255, green: 102/255, blue: 120/255)
    static let purpleMenu = Color(red: 143/255, green: 63/255, blue: 113/255)
    static let successColor = Color(red: 104/255, green: 157/255, blue: 106/255)
    static let redMenu = Color(red: 234/255, green: 105/255, blue: 98/255)
    
    static let buttonBlue = Color(red: 55/255, green: 65/255, blue: 65/255)
    static let buttonRed = Color(red: 64/255, green: 33/255, blue: 32/255)
    static let buttonGreen = Color(red: 111/255, green: 194/255, blue: 118/255)
    static let darkerGreenButton = Color(red: 52/255, green: 56/255, blue: 27/255)
    
    static let gruvBlue = Color(red: 131/255, green: 165/255, blue: 152/255)
    static let calTextColor = Color(red: 219/255, green: 174/255, blue: 147/255)
    

    
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



private struct viewPlanPopup: View {
    @Binding var viewPlans: Bool
    @Binding var keys: [String]
    @Binding var noEditsFromCustomize: Bool
    @Binding var bindedDayText: String
    
    @State var currKey = "N/A"
    @State var tempKey = ""
    @State var currentWorkoutDayKey = ""
    
    @State var text = "None"
    
    @State private var newName = ""
    @State private var showingAlert = false
    
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack(spacing: 20){
                HStack(spacing: 10){
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 10) {
                        ForEach(keys, id: \.self) { key in
                            Text("\(String(key.dropLast(4)))")
                                .font(.system(size: 15))
                                .fontWeight(.heavy)
                                .foregroundColor(.gruvboxForeground)
                                .onTapGesture {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                    currKey = key
                                    if let textData = SharedDataManager.shared.getData(forKey: currKey) as? String {
                                        text = textData
                                    } else {
                                        text = "None"
                                    }
                                }
                        }
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gruvboxSecondary, lineWidth: 1)
                )
                
                
                
                HStack{
                    Text("\(String(currKey.dropLast(4)))")
                        .font(.system(size: 20))
                        .fontWeight(.heavy)
                        .foregroundColor(.gruvboxForeground)
                    
                    Spacer()
                    
                    Button("Set Today") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                        SharedDataManager.shared.saveData(currKey.dropLast(4), forKey: getDayOfWeekString())
                        bindedDayText = getWorkoutDayData(inputData: getDayOfWeekString())
                    }
                    .foregroundColor(.gruvboxBackground)
                    .padding(5)
                    .background(Color.teal)
                    .cornerRadius(10)
                    .bold()
                    
                    Button("Add New") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                        
                        showingAlert.toggle()
                    }
                    .foregroundColor(.gruvboxBackground)
                    .padding(5)
                    .background(Color.buttonGreen)
                    .cornerRadius(10)
                    .bold()
                    .alert("Enter new workout name", isPresented: $showingAlert) {
                        TextField("New workout name", text: $newName)
                            .disableAutocorrection(true)
                        Button("Save", action: submitNewWorkout)
                    }
                    
                    
                    Button("Delete") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                        
                        if keys.count > 1{
                            guard let index = keys.firstIndex(of: currKey) else {
                                return
                            }
                            
                            if index > 0 {
                                tempKey = keys[index - 1]
                            } else if index < keys.count - 1 {
                                
                                tempKey = keys[index + 1]
                            }
                            
                            if let textData = SharedDataManager.shared.getData(forKey: tempKey) as? String {
                                text = textData
                            } else {
                                text = "None"
                            }
                            
                            SharedDataManager.shared.removeData(forKey: currKey)
                            SharedDataManager.shared.removeData(forKey: "original"+currKey)
                            
                            keys = SharedDataManager.shared.keysEndingWithText()
                            
                            currKey = tempKey
                            
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                    .foregroundColor(.gruvboxBackground)
                    .padding(5)
                    .background(Color.gruvboxSecondary)
                    .cornerRadius(10)
                    .bold()
                }
                
                
                VStack {
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.gruvboxForeground)
                        .background(Color.gruvboxBackground)
                        .padding()
                        .scrollContentBackground(.hidden)
                        .frame(minWidth: 370)
                        .frame(minHeight: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(rgb: (235,219,178)), lineWidth: 1)
                        )
                        .onChange(of: text) { _ in
                            noEditsFromCustomize = true
                            SharedDataManager.shared.saveData(text, forKey: currKey)
                            SharedDataManager.shared.saveData(text, forKey: ("original"+currKey))
                            if currentWorkoutDayKey == currKey{
                                bindedDayText = text
                            }
                        }
                    Divider()
                }
                .onTapGesture {
                    //nothing
                    //removes the deselecting option if the text area is tapped
                }
                
                
            
                Button("Close") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                    viewPlans = false
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .foregroundColor(.gruvboxForeground)
                .padding()
                .background(Color.buttonBlue)
                .cornerRadius(10)
                .bold()
            }
            .padding(100)
            .padding(.top, 100)
            .padding(.bottom, 200)
            .background(Color.gruvboxBackground)
            .cornerRadius(10)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
        .onAppear(){
            keys = SharedDataManager.shared.keysEndingWithText()
            if let sharedData = SharedDataManager.shared.getData(forKey: getDayOfWeekString()) as? String {
                currKey = sharedData + "Text"
                currentWorkoutDayKey = currKey
                
                addCurrentToKeys(textFieldData: bindedDayText, keyName: String(currentWorkoutDayKey.dropLast(4)))
                
                if let textData = SharedDataManager.shared.getData(forKey: currKey) as? String {
                    text = textData
                } else {
                    text = "None"
                }
            } else {
                currKey = "N/A"
                text = "None"
            }
        }
    }
    func getDayOfWeekString() -> String{
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
    func getWorkoutDayData(inputData: String) -> String{
        if let sharedData = SharedDataManager.shared.getData(forKey: inputData) as? String {
            if let sharedDatatwo = SharedDataManager.shared.getData(forKey: sharedData+"Text") as? String {
                return sharedDatatwo
            } else{
                return "N/A"
            }
        } else {
            return "N/A"
        }
    }
    
    func submitNewWorkout() {
        addCurrentToKeys(keyName: newName)
    }
    
    func addCurrentToKeys(textFieldData: String = "New Workout List:", keyName: String){
        if(!keys.contains(keyName+"Text")){
            SharedDataManager.shared.saveData(textFieldData, forKey: keyName+"Text")
            SharedDataManager.shared.saveData(textFieldData, forKey: "original"+keyName+"Text")
        }
        keys = SharedDataManager.shared.keysEndingWithText()
        newName = ""
        WidgetCenter.shared.reloadAllTimelines()
    }
}




private struct CustomPlanPopup: View {
    @Binding var customizingPlan: Bool
    @Binding var isShowingSettingsPopup: Bool
    @Binding var bindTextDay: String
    @Binding var noEditsFromCustomize: Bool
    
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
                    .frame(height: 10)
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
                                Text(getData(inputData: day))
                                    .foregroundColor(.gruvboxForeground)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.trailing)
                                    .onTapGesture {
                                        editableDays[day] = getData(inputData: day)
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
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                        for (day, editableText) in editableDays {
                            if getData(inputData: (editableText + "Text")) == "N/A" {
                                SharedDataManager.shared.saveData(editableText, forKey: day)
                                SharedDataManager.shared.saveData("Example Workout\nExercise 1:\nExercise 2:", forKey: (editableText + "Text"))
                                SharedDataManager.shared.saveData("Example Workout\nExercise 1:\nExercise 2:", forKey: ("original" + editableText + "Text"))
                            } else {
                                SharedDataManager.shared.saveData(editableText, forKey: day)
                            }
                        }
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    .foregroundColor(.gruvboxForeground)
                    .padding()
                    .background(Color.gruvboxAccent)
                    .cornerRadius(10)
                    .offset(y: -15)
                    
                    Button("Close") {
                        editableDays = originalEditableDays
                        WidgetCenter.shared.reloadAllTimelines()
                        customizingPlan = false
                        bindTextDay = getWorkoutDayData(inputData: getDayOfWeekString())
                        noEditsFromCustomize = true
                    }
                    .foregroundColor(.gruvboxForeground)
                    .padding()
                    .background(Color.gruvboxAccent)
                    .cornerRadius(10)
                    .offset(y: -15)
                    
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
    
    func getDayOfWeekString() -> String{
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
    
    func getWorkoutDayData(inputData: String) -> String{
        if let sharedData = SharedDataManager.shared.getData(forKey: inputData) as? String {
            if let sharedDatatwo = SharedDataManager.shared.getData(forKey: sharedData+"Text") as? String {
                return sharedDatatwo
            } else{
                return "N/A"
            }
        } else {
            return "N/A"
        }
    }
    func getData(inputData: String) -> String {
        if let sharedData = SharedDataManager.shared.getData(forKey: inputData) as? String {
            return sharedData
        } else {
            return "N/A"
        }
    }
}
