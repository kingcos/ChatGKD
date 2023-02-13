//
//  MainView.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ChatListView()
                .tabItem {
                    Image(systemName: "ellipsis.bubble.fill")
                        .font(.system(size: 22))
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
