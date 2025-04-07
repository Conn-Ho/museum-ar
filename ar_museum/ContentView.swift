//
//  ContentView.swift
//  ar_museum
//
//  Created by ConnHo on 2025/3/22.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ExhibitListView()) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .font(.title)
                            .foregroundColor(.blue)
                        Text("展品列表")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
                
                NavigationLink(destination: ARExhibitionView()) {
                    HStack {
                        Image(systemName: "arkit")
                            .font(.title)
                            .foregroundColor(.green)
                        Text("AR展览")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
                
                NavigationLink(destination: VirtualMuseumView()) {
                    HStack {
                        Image(systemName: "building.columns")
                            .font(.title)
                            .foregroundColor(.purple)
                        Text("虚拟博物馆")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
                
                NavigationLink(destination: SettingsView()) {
                    HStack {
                        Image(systemName: "gear")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text("设置")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("AR博物馆")
        }
    }
}

#Preview {
    ContentView()
}
