import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FirstView()
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("First")
                }
            
            SecondView()
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("Second")
                }
        }
    }
}
//
//  MainTabView.swift
//  Lab5_TabbedApp
//
//  Created by harsh saw on 2025-02-26.
//

