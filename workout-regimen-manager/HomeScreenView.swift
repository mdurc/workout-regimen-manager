//
//  HomeScreenView.swift
//  workout-regimen-manager
//
//  Created by Matthew Durcan on 9/2/23.
//

import SwiftUI


struct HomeScreenView: View {
    var body: some View {
        NavigationStack {
            ZStack{
                Color.gruvboxBackground
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 30) {
                    Text("Menu")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.redMenu)
                        .padding(.bottom, 50)
                        .padding(.top,100)
                    
                    NavigationLink(destination: ContentView()) {
                        Text("Gym Workout")
                            .font(.system(size:25).weight(.medium))
                            .foregroundColor(.gruvboxForeground)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .background(Color.buttonBlue)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: CalendarView()) {
                        Text("Calender + Log")
                            .font(.system(size:25).weight(.medium))
                            .foregroundColor(.gruvboxForeground)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .background(Color.buttonBlue)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
            }
        }
    }
}
