//
//  CardioView.swift
//  workout-regimen-manager
//
//  Created by Matthew Durcan on 9/3/23.
//


import SwiftUI
import MapKit
import CoreLocation

struct CardioView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    
    private let locationManager = CLLocationManager()
    @ObservedObject private var locationManagerDelegate = LocationManagerDelegate()
    @ObservedObject private var paceCalculator = PaceCalculator()
    @ObservedObject private var mileSplitsManager = MileSplitsManager()

    
    @Environment(\.presentationMode) var presentationMode

    @State private var timer: Timer? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var isRunning = false
    @State private var startedRun = false
    
    @State private var timeStarted : String = "hh:mm AM/PM"
    @State private var totalTimer: Timer? = nil
    @State private var totalElapsedTime: TimeInterval = 0
    
    @State private var showEndRunConfirmation = false
    
    @State private var runData = ""
    
    
    var body: some View {
        ZStack{
            Color.gruvboxBackground
                .edgesIgnoringSafeArea(.all)
            VStack{
                
                VStack {
                    Text("Time Started:")
                        .font(.headline)
                    Text(timeStarted)
                        .font(.system(size: 24, design: .monospaced))
                    Text("Time Elapsed:")
                        .font(.headline)
                    Text("\(formattedTotalElapsedTime)")
                        .font(.system(size: 24, design: .monospaced))
                }
                .padding()
                .padding(.top,10)
                
                HStack(alignment: .top){
                    Map(coordinateRegion: $region, showsUserLocation: true)
                        .onAppear {
                            locationManager.requestWhenInUseAuthorization()
                            if let userLocation = locationManager.location?.coordinate {
                                region.center = userLocation
                            }
                        }
                        .overlay(
                            Button(action: {
                                // Get the user's current location and center the map on it
                                if let userLocation = locationManager.location?.coordinate {
                                    region.center = userLocation
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                                .padding(.trailing, 16)
                                .padding(.top, 16)
                            , alignment: .topTrailing
                        )
                        .cornerRadius(30)
                        .frame(height: 200)
                        .padding(.leading, 10)
                        .padding(.bottom, 20)
                    
                    VStack {
                        Text("Mile Splits:")
                            .font(.headline)
                        ForEach(Array(mileSplitsManager.mileSplits.keys.sorted()), id: \.self) { mile in
                            HStack{
                                Text("Mile \(mile): ")
                                    .font(.headline)
                                Text(mileSplitsManager.mileSplits[mile] ?? "0.00")
                                    .font(.system(size: 18, design: .monospaced))
                            }
                        }
                    }
                    .padding()
                    .background(Color.buttonBlue.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                }
                
                
                VStack{
                    
                    HStack {
                        // Time Box
                        VStack {
                            Text("Time")
                                .font(.headline)
                            Text("\(formattedElapsedTime)")
                                .font(.system(size: 24, design: .monospaced))
                                .foregroundColor(.gruvboxForeground)
                        }
                        .padding()
                        
                        
                        VStack {
                            Text("Miles Ran")
                                .font(.headline)
                            Text("\(String(format: "%.2f", locationManagerDelegate.miles))")
                                .font(.system(size: 24, design: .monospaced))
                        }
                        .padding()
                        VStack {
                            Text("Pace")
                                .font(.headline)
                            Text("\(formattedPace)")
                                .font(.system(size: 24, design: .monospaced))
                        }
                        .padding()
                    }
                    
                    HStack {
                        // Time Box
                        VStack {
                            Text("Average Pace")
                                .font(.headline)
                            Text("\(mileSplitsManager.averagePace())")
                                .font(.system(size: 24, design: .monospaced))
                                .foregroundColor(.gruvboxForeground)
                        }
                        .padding()
                        
                        
                        VStack {
                            Text("Elevation Gain")
                                .font(.headline)
                            HStack{
                                Text("\(String(format: "%.2f", locationManagerDelegate.elevationGain))")
                                    .font(.system(size: 24, design: .monospaced))
                                Text("m")
                                    .font(.system(size: 24))
                            }
                        }
                        .padding()
                    }
                }
                .background(Color.buttonBlue.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                
                HStack{
                    Button(action: {
                        if isRunning {
                            stopTimer()
                            stopTracking()
                            locationManagerDelegate.pauseElevationTracking()
                        } else {
                            showEndRunConfirmation = false
                            if(!startedRun){
                                timeStarted = "\(timeDateCurrent)"
                                startTimer(total: true)
                            }
                            locationManagerDelegate.resumeElevationTracking()
                            startedRun = true
                            startTimer()
                            startTracking()
                        }
                    }) {
                        Text(isRunning ? "Pause Run" : "Start Run")
                            .foregroundColor(.gruvboxForeground)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .background(Color.gruvboxAccent)
                            .cornerRadius(10)
                    }
                    .font(.system(size:22))
                    .padding(.top, 16)
                    
                    
                    if(startedRun){
                        Button(action: {
                            
                            let mileSplitsString = mileSplitsManager.mileSplits.reversed().map { (mile, time) in
                                return "\t\t\tMile \(mile): \(time)"
                            }.joined(separator: "\n")

                            runData += "\n--------------------------------"
                            runData += "\nRUN SESSION:"
                            runData += "\n\tMiles Ran: \(String(format: "%.2f", locationManagerDelegate.miles))\n"
                            runData += "\t\tSplits:\n"
                            runData.append(mileSplitsString)
                            runData += "\n\tAverage Pace: \(mileSplitsManager.averagePace())\n"
                            
                            runData += "\tElevation Gain: \(String(format: "%.2f", locationManagerDelegate.elevationGain))\n"
                            
                            runData += "\t------\n\tTotal Time Outside: \(formattedTotalElapsedTime)\n"
                            runData += "\t\tRun Started: \(timeStarted)\n"
                            runData += "\t\tRun Finished: \(timeDateCurrent)\n"
                            runData += "\t\tTime Spent Running: \(formattedElapsedTime)\n"
                            runData += "--------------------------------"
                            
                            //reset run values
                            showEndRunConfirmation = true
                            timeStarted = "hh:mm AM/PM"
                            totalElapsedTime = 0
                            startedRun = false
                            isRunning = false
                            stopTimer(reset: true)
                            stopTracking()
                            locationManagerDelegate.resetTracking()
                            paceCalculator.resetPace()
                        }) {
                            Text("End Run")
                                .foregroundColor(.gruvboxForeground)
                                .padding(.horizontal, 25)
                                .padding(.vertical, 10)
                                .background(Color.gruvboxAccent)
                                .cornerRadius(10)
                        }
                        .font(.system(size:22))
                        .padding(.top, 16)
                        
                    }
                }
                
                Spacer()
            }
        }
        .foregroundColor(.gruvboxForeground)
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
        .alert(isPresented: $showEndRunConfirmation) {
            Alert(
                title: Text("End Run Confirmation"),
                message: Text("Would you like to log this run for \n\(formattedDate())?"),
                primaryButton: .default(Text("Yes")) {
                    print(runData)
                    logRun()
                },
                secondaryButton: .cancel(Text("No")) {
                    //dismiss
                    runData = ""
                }
            )
        }
    }
    
    private func startTimer(total: Bool = false) {
        if !total {
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                    elapsedTime += 0.01
                }
                RunLoop.current.add(timer!, forMode: .common)
                isRunning = true
            }
        }else{
            if totalTimer == nil {
                totalTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                    totalElapsedTime += 0.01
                }
                RunLoop.current.add(totalTimer!, forMode: .common)
            }
        }
    }

    private func stopTimer(reset: Bool = false) {
        if(reset){
            elapsedTime = 0
            mileSplitsManager.clearMileSplits()
            totalElapsedTime = 0
            
            totalTimer?.invalidate()
            totalTimer = nil
        }
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    private var formattedTotalElapsedTime: String {
        let minutes = Int(totalElapsedTime) / 60
        let seconds = Int(totalElapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var timeDateCurrent: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // Format for displaying time as "hh:mm AM/PM"
        return dateFormatter.string(from: Date())
    }
    
    private func startTracking() {
        locationManagerDelegate.resumeTracking()
        locationManager.delegate = locationManagerDelegate
        locationManager.startUpdatingLocation()
    }

    private func stopTracking() {
        locationManagerDelegate.pauseTracking()
        locationManager.stopUpdatingLocation()
    }
    
    private var formattedPace: String {
        let miles = locationManagerDelegate.miles
        
        if Int(miles) > Int(paceCalculator.mileSplitDistance) {
            paceCalculator.mileSplitDistance += 1
            mileSplitsManager.updateMileSplits(time: formattedElapsedTime)
        }
        
        if(miles-paceCalculator.lastMileageUpdate >= 0.1){
            paceCalculator.lastMileageUpdate += 0.1
            return paceCalculator.updatePaceIfNeeded(elapsedTime: elapsedTime, miles: miles)
        }else{
            return paceCalculator.currentPace
        }
    }
    
    private func logRun() {
        if let storedText = SharedDataManager.shared.getData(forKey: "\(Calendar.current.dateComponents([.year, .month, .day], from: Date()))") as? String {
            SharedDataManager.shared.saveData(storedText + runData, forKey: "\(Calendar.current.dateComponents([.year, .month, .day], from: Date()))")
        }else{
            SharedDataManager.shared.saveData(runData, forKey: "\(Calendar.current.dateComponents([.year, .month, .day], from: Date()))")
        }
    }

    private func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy" // Format for displaying the date
        return dateFormatter.string(from: Date())
    }
}


class LocationManagerDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastLocation: CLLocation?
    @Published var miles = 0.0
    @Published var elevationGain: Double = 0.0
    private var isPaused = false
    private var resetLocation = true
    private var elevationTracking = false

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        if !isPaused { // Check if the timer is not paused
            if(resetLocation){
                lastLocation = location
            }
            resetLocation = false
            if let lastLocation = lastLocation {
                let distance = lastLocation.distance(from: location)
                miles += distance / 1609.34
                
                if elevationTracking {
                    if location.altitude > lastLocation.altitude {
                        let elevationChange = location.altitude - lastLocation.altitude
                        let elevationChangeRounded = (elevationChange * 10).rounded(.down) / 10 // Round to lowest 0.1 increment
                        elevationGain += elevationChangeRounded
                    }
                }
            }
        }

        lastLocation = location
    }
    
    func pauseTracking() {
        resetLocation = true
        isPaused = true
    }
    
    func pauseElevationTracking() {
        elevationTracking = false
    }
    
    func resumeElevationTracking(){
        elevationTracking = true
    }
    
    func resumeTracking() {
        isPaused = false
    }
    
    func resetTracking(){
        miles = 0.0
        elevationGain = 0.0
    }
}


class PaceCalculator: ObservableObject {
    var lastMileageUpdate: Double = 0.0
    var currentPace: String = "0:00"
    var mileSplitDistance: Double = 0.0
    
    func updatePaceIfNeeded(elapsedTime: Double, miles: Double) -> String {
        if miles > 0 && elapsedTime > 0 {
            // Calculate pace for the current update
            let pace = (elapsedTime / 60) / miles
            let paceMinutes = Int(pace)
            let paceSeconds = Int((pace - Double(paceMinutes)) * 60)
            
            currentPace = String(format: "%02d:%02d", paceMinutes, paceSeconds)
            return currentPace
        } else {
            return "0:00"
        }
    }
    
    func resetPace(){
        lastMileageUpdate = 0.0
        currentPace = "0:00"
    }
}


class MileSplitsManager: ObservableObject {
    var mileSplits: [String: String] = [:]
    var mileCounter: Int = 0

    func updateMileSplits(time: String) {
        mileCounter += 1
        
        if mileCounter == 1 {
            mileSplits[String(mileCounter)] = time
        } else {
            var totalTimeInSeconds = 0.0
            var newTimeInSeconds = 0.0
            
            for mile in 1..<mileCounter {
                if let splitTime = mileSplits[String(mile)] {
                    let components = splitTime.split(separator: ":").compactMap { Double($0) }
                    if components.count == 2 {
                        totalTimeInSeconds += components[0] * 60 + components[1]
                    }
                }
            }
            
            let currentComponents = time.split(separator: ":").compactMap { Double($0) }
            
            if currentComponents.count == 2 {
                newTimeInSeconds = currentComponents[0] * 60 + currentComponents[1]
                
                let split = newTimeInSeconds - totalTimeInSeconds
                
                let splitMinutes = Int(split) / 60
                let splitSeconds = Int(split) % 60
                
                mileSplits[String(mileCounter)] = String(format: "%02d:%02d", splitMinutes, splitSeconds)
            }
        }
    }

    func clearMileSplits() {
        mileSplits.removeAll()
        mileCounter = 0
    }
    
    func averagePace() -> String{
        guard mileCounter > 0 else {
            return "0:00"
        }

        var totalSeconds = 0.0

        for (_, time) in mileSplits {
            let components = time.split(separator: ":").compactMap { Double($0) }
            if components.count == 2 {
                totalSeconds += components[0] * 60 + components[1]
            }
        }

        let averageTimeInSeconds = totalSeconds / Double(mileCounter)
        let averageMinutes = Int(averageTimeInSeconds) / 60
        let averageSeconds = Int(averageTimeInSeconds) % 60

        return String(format: "%02d:%02d", averageMinutes, averageSeconds)
    }
}
