//
//  CardioView.swift
//  workout-regimen-manager
//
//  Created by Matthew Durcan on 9/3/23.
//


 import SwiftUI

 struct CardioView: View {
     @Environment(\.presentationMode) var presentationMode
     var body: some View {
         ZStack{
             Color.gruvboxBackground
                 .edgesIgnoringSafeArea(.all)
             
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
 }
