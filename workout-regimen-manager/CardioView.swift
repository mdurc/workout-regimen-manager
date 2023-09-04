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
    
    @Environment(\.presentationMode) var presentationMode

    @State private var timer: Timer? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var isRunning = false

    
    
    var body: some View {
        ZStack{
            Color.gruvboxBackground
                .edgesIgnoringSafeArea(.all)
            VStack{
                Button(action: {
                    if isRunning {
                        stopTimer()
                        stopTracking()
                    } else {
                        startTimer()
                        startTracking()
                    }
                }) {
                    Text(isRunning ? "Stop Run" : "Start Run")
                        .foregroundColor(.gruvboxForeground)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .background(Color.gruvboxAccent)
                        .cornerRadius(10)
                }
                .font(.system(size:22))
                .padding(.top, 16)
                
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
                .background(Color.gray.opacity(0.5))

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
    
    private func startTracking() {
        locationManager.delegate = locationManagerDelegate
        locationManager.startUpdatingLocation()
    }

    private func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    private var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    

    private var formattedPace: String {
        let miles = locationManagerDelegate.miles
        
        if(miles-paceCalculator.lastMileageUpdate >= 0.1){
            return paceCalculator.updatePaceIfNeeded(elapsedTime: elapsedTime, miles: miles)
        }else{
            return paceCalculator.currentPace
        }
    }



}


class LocationManagerDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastLocation: CLLocation?
    @Published var miles = 0.0

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        if let lastLocation = lastLocation {
            let distance = lastLocation.distance(from: location)
            miles += distance / 1609.34 // Convert meters to miles
        }

        lastLocation = location
    }
}


class PaceCalculator: ObservableObject {
    @Published var lastMileageUpdate: Double = 0.0
    @Published var currentPace: String = "0.00"
    
    func updatePaceIfNeeded(elapsedTime: Double, miles: Double) -> String {
        if miles > 0 && elapsedTime > 0 {
            lastMileageUpdate += 0.1
            let minutes = Int(elapsedTime) / 60
            let seconds = Int(elapsedTime) % 60
            
            // Calculate pace for the current update
            let pace = (elapsedTime / 60) / miles
            let paceMinutes = Int(pace)
            let paceSeconds = Int((pace - Double(paceMinutes)) * 60)
            
            currentPace = String(format: "%02d:%02d", paceMinutes, paceSeconds)
            return currentPace
        } else {
            return "0.00"
        }
    }
}
