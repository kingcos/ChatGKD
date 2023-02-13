//
//  ChatListView.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import SwiftUI

struct ChatListView: View {
    @State var currrentMessage = ""
    @State var isLoading = false
    @State var chats: [ChatModel] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ForEach(chats) { chat in
                        Text("\(chat.isGPT ? "🤖️" : "🧑")：\(chat.isGPT && isLoading ? ChatGPTHelper.MessagePlaceholder : chat.message)")
                            .bold(!chat.isGPT)
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = chat.message
                                } label: {
                                    Label("复制", systemImage: "doc.on.doc.fill")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                
                HStack(spacing: 4) {
                    TextField(isLoading ? ChatGPTHelper.MessagePlaceholder : "Say Hi to ChatGPT", text: $currrentMessage)
                        .padding(.leading, 12)
                        .disabled(isLoading)
                    
                    Button {
                        if isLoading {
                            
                        } else {
                            isLoading = true
                            
                            chats.append(ChatModel(isGPT: false, message: currrentMessage))
                            currrentMessage = ""
                            
                            Task {
                                do {
                                    let stream = try await ChatGPTHelper.api.sendMessageStream(text: chats.last?.message ?? "")
                                    for try await var line in stream {
                                        if line.isEmpty || line == " " {
                                            continue
                                        }
                                        
                                        if chats.last!.isGPT {
                                            chats.last!.message.append(line)
                                        } else {
                                            if line.starts(with: " ") {
                                                line.removeFirst()
                                            }
                                            chats.append(ChatModel(isGPT: true, message: line))
                                        }
                                        print(line)
                                    }
                                    isLoading = false
                                } catch {
                                    chats.append(ChatModel(isGPT: true, message: error.localizedDescription))
                                }
                            }
                        }
                    } label: {
                        Group {
                            if isLoading {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .frame(width: 26, height: 26)
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .cornerRadius(13)
                            } else {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(width: 26, height: 26)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(13)
                            }
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(4)
                    .disabled(currrentMessage.isEmpty)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 17)
                        .stroke(Color(uiColor: .systemGray4))
                )
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            .navigationTitle("ChatGKD")
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}
