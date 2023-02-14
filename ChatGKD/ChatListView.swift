//
//  ChatListView.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import SwiftUI

struct ChatListView: View {
    @AppStorage("NameSwitch") var nameSwitch: Bool = false
    
    @State var currrentMessage = ""
    @State var isLoading = false {
        didSet {
            loadingUUID = nil
        }
    }
    @State var loadingUUID: UUID?
    @State var chats: [ChatModel] = []
    
    @State var showingHistory = false
    
    @State var task: Task<Void, Never>?
    
    let tapGesture = TapGesture()
        .onEnded { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ForEach(chats) { chat in
                        Text("\(chat.isGPT ? "🤖️" : "🧑")：\(chat.isGPT && chat.message.isEmpty ? ChatGPTHelper.MessagePlaceholder : chat.message)")
                            .bold(!chat.isGPT)
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = chat.message
                                } label: {
                                    Label("复制", systemImage: "doc.on.doc.fill")
                                }
                            }
                            .foregroundColor(
                                chat.message.starts(with: ChatGPTHelper.ChatErrorPrefix) ? .red : (loadingUUID == chat.id ? .secondary : .primary)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .gesture(tapGesture)
                
                HStack(spacing: 4) {
                    TextField(isLoading ? ChatGPTHelper.MessagePlaceholder : "请在此输入消息...", text: $currrentMessage)
                        .padding(.leading, 12)
                        .disabled(isLoading)
                    
                    Button {
                        if isLoading {
                            task?.cancel()
                            
                            if task == nil || task!.isCancelled {
                                isLoading = false
                                
                                if chats.last!.isGPT {
                                    var last = chats.last!
                                    last.message.append(ChatGPTHelper.ChatStopTips)
                                    chats[chats.count-1] = last
                                } else {
                                    chats.append(ChatModel(isGPT: true, message: ChatGPTHelper.ChatStopTips))
                                }
                                
                                ChatProvider.shared.saveOrUpdate(chats.last!)
                            }
                        } else {
                            isLoading = true
                            
                            chats.append(ChatModel(isGPT: false, message: currrentMessage))
                            ChatProvider.shared.saveOrUpdate(chats.last!)
                            
                            currrentMessage = ""
                            
                            task = Task {
                                do {
                                    let stream = try await ChatGPTHelper.api.sendMessageStream(text: chats.last?.message ?? "")
                                    chats.append(ChatModel(isGPT: true, message: ChatGPTHelper.MessagePlaceholder))
                                    loadingUUID = chats.last?.id
                                    
                                    var last = chats.last!
                                    
                                    for try await var line in stream {
                                        // 跳过空行
                                        if line.isEmpty || line == " " {
                                            continue
                                        }
                                        
                                        // 终止的任务
                                        if task == nil || task!.isCancelled {
                                            break
                                        }
                                        
                                        // 去除占位
                                        if last.message == ChatGPTHelper.MessagePlaceholder {
                                            last.message = ""
                                            
                                            // 处理空格，仅第一行
                                            if line.starts(with: " ") {
                                                line.removeFirst()
                                            }
                                        }
                                        
                                        last.message.append(line)
                                        chats[chats.count-1] = last
                                        
//                                        print(line)
                                    }
                                    isLoading = false
                                    
                                    ChatProvider.shared.saveOrUpdate(chats.last!)
                                } catch {
                                    if !chats.last!.isGPT {
                                        chats.append(ChatModel(isGPT: true, message: "\(ChatGPTHelper.ChatErrorPrefix) [\(error.localizedDescription)]"))
                                        isLoading = false
                                    }
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
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 17)
                        .stroke(Color(uiColor: .systemGray4))
                )
                .padding(.horizontal)
                .padding(.vertical, 6)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingHistory = true
                        } label: {
                            Image(systemName: "clock")
                        }
                    }
                    
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button {
//
//                        } label: {
//                            Image(systemName: "plus.message")
//                        }
//                    }
                }
                .sheet(isPresented: $showingHistory) {
                    HistoryChatView()
                }
            }
            .navigationTitle(nameSwitch ? "ChatGKD" : "ChatGPT")
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}
