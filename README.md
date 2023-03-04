# ChatGKD

A new app for ChatGPT in SwiftUI & [Vue 3](https://kingcos.me/ChatGKD).

现已支持最新 Chat API！赶快体验类似 ChatGPT 一般的能力吧～

> What is *ChatGKD*?
>
> GKD stands for Gao（搞）Kuai（快）Dian（点）, which means faster in Chinese.

## Preview

<table>
  <tr>
    <td>Web</td>
    <td colspan="2"><center>App</center></td>
  </tr>
  <tr>
    <td><img src="https://github.com/kingcos/ChatGKD/blob/main/resources/web.jpeg?raw=true"></td>
    <td><img src="https://github.com/kingcos/ChatGKD/blob/main/resources/main.PNG?raw=true"></td>
    <td><img src="https://github.com/kingcos/ChatGKD/blob/main/resources/history.PNG?raw=true"></td>
  </tr>
</table>

## Features

- [x] Custom prompt (web version)
- [x] Support new gpt-3.5-turbo model (web version)

## Usages

### For Web

Open [kingcos.me/ChatGKD](https://kingcos.me/ChatGKD), then just input your APY key as followed:

```
key:YOUR_API_KEY
```

And, enjoy.

### For App

Replace your API key in `Utils/ChatGPTHelper.swift`:

```swift
_api = ChatGPTAPI(apiKey: "YOUR_API_KEY")
```

Build, and enjoy.
