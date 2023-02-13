//
//  SettingsView.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("NameSwitch") var nameSwitch: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Toggle("名称切换", isOn: $nameSwitch)
                
                Text("Powered by kingcos with Love.")
            }
            .navigationTitle("设置")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
