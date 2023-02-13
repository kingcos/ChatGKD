//
//  ChatModel.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import Foundation

class ChatModel: Identifiable {
    var id = UUID()
    
    var isGPT: Bool
    var message: String
    
    init(id: UUID = UUID(), isGPT: Bool, message: String) {
        self.id = id
        self.isGPT = isGPT
        self.message = message
    }
}
