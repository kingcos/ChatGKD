# ChatGKD

A new app for ChatGPT in SwiftUI & [Vue 3](https://kingcos.me/ChatGKD).

> What is *ChatGKD*?
>
> GKD stands for Gao（搞）Kuai（快）Dian（点）, which means faster in Chinese.

## Preview

<img src="https://github.com/kingcos/ChatGKD/blob/main/resources/web.png?raw=true" width=250px />

<img src="https://github.com/kingcos/ChatGKD/blob/main/resources/main.PNG?raw=true" width=250px /> <img src="https://github.com/kingcos/ChatGKD/blob/main/resources/history.PNG?raw=true" width=250px />

## Usages

### For Web

Open [kingcos.me/ChatGKD](https://kingcos.me/ChatGKD), then just input your APY key as followed:

```
key:YOUR_API_KEY
```

Then, enjoy.

### For App

Just replace your API key in `Utils/ChatGPTHelper.swift`:

```swift
_api = ChatGPTAPI(apiKey: "YOUR_API_KEY")
```

Build, and enjoy.
