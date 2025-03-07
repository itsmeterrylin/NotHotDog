//
//  LoadingView.swift
//  Not Hotdog
//
//  Created by Terry Lin on 2/19/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Image("LoadingView") // Load the background image from assets
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all) // Ensure it covers the whole screen

            // Progress indicator
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
        .onAppear {
            // Simulate a short loading time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView() // Load the main app after loading screen
        }
    }
}
