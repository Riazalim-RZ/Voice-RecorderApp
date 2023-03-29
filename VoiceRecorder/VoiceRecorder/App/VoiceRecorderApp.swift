//
//  VoiceRecorderApp.swift
//  VoiceRecorder
//
//  Created by Riaz Alim on 17/03/2023.
//
import SwiftUI

@main
struct VoiceRecTestApp: App {
    
    @State private var showLaunchView: Bool = true
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            
            ZStack {
                // SplashScreenView()
                 ContentView()
                     .environment(\.managedObjectContext, persistenceController.container.viewContext)
                     // always use dark mode
                     .preferredColorScheme(.dark)
                ZStack {
                    
                    if showLaunchView {
                        LaunchView(showLaunchView: $showLaunchView)
                            .transition(.move(edge: .leading))
                    }
                }
                .zIndex(2.0)
            }
        }
    }
}
