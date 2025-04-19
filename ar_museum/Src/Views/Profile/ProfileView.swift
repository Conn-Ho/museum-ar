//
//  ProfileView.swift
//  ar_museum
//
//  Created by ConnHo on 2025/3/22.
//

import SwiftUI

struct ProfileView: View {
   var body: some View {
        List {
            Section(header: Text("个人信息")) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("游客")
                            .font(.headline)
                        Text("点击登录")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Section(header: Text("功能测试")) {
            //     NavigationLink(destination: VirtualMuseumView()) {
            //         Label("虚拟导览测试", systemImage: "building.columns.fill")
            //     }
            // }
            
            Section(header: Text("功能")) {
                NavigationLink(destination: Text("收藏展品")) {
                    Label("收藏展品", systemImage: "star")
                }
                
                NavigationLink(destination: Text("浏览历史")) {
                    Label("浏览历史", systemImage: "clock")
                }
                
                NavigationLink(destination: Text("设置")) {
                    Label("设置", systemImage: "gear")
                }
            }
        }
        .navigationTitle("我的")
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}