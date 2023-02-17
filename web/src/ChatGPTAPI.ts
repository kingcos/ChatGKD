class ChatGPTAPI {
  private apiKey: string;
  private historyList: string[] = [];
  private get urlRequest() {
    const url = "https://api.openai.com/v1/completions";
    return new Request(url);
  }
  private dateFormatter = new Intl.DateTimeFormat("en-US", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
  private basePrompt = `You are ChatGPT, a large language model trained by OpenAI. Respond conversationally. Do not answer as the user. Current date: ${this.dateFormatter.format(
    new Date()
  )}

User: Hello
ChatGPT: Hello! How can I help you today? \n\n\n`;

  constructor(apiKey: string) {
    this.apiKey = apiKey;
  }

  private generateChatGPTPrompt(text: string): string {
    let prompt = `${this.basePrompt}${this.historyList.join(
      ""
    )}User: ${text}\nChatGPT:`;
    if (prompt.length > 4000 * 4) {
      this.historyList.shift();
      prompt = this.generateChatGPTPrompt(text);
    }
    return prompt;
  }

  private async jsonBody(text: string, stream = true): Promise<string> {
    const body = {
      model: "text-davinci-003",
      temperature: 0.5,
      max_tokens: 1024,
      prompt: this.generateChatGPTPrompt(text),
      stop: ["\n\n\n", "<|im_end|>"],
      stream: stream,
    };
    const response = await fetch(this.urlRequest, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify(body),
    });

    if (response.ok) {
      const text = await response.text();
      const result = text.trim().split("\n");
      let responseText = "";
      for (let i = 0; i < result.length; i++) {
        const line = result[i];
        if (line.length == 0 || line == " ") {
          continue;
        }
        if (line.startsWith("data: ") && !line.endsWith("data: [DONE]")) {
          const text = JSON.parse(line.slice(6)).choices[0].text;
          responseText += text;
          console.log(`ChatGPT: ${text}`);
        }
      }

      return responseText;
    } else {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
  }

  private appendToHistoryList(userText: string, responseText: string) {
    this.historyList.push(`User: ${userText}\n\n\nChatGPT: ${responseText}\n`);
  }

  async sendMessageStream(text: string): Promise<string> {
    const responseText = await this.jsonBody(text, true);
    this.appendToHistoryList(text, responseText);
    return responseText;
  }

//   async sendMessage(text: string): Promise<string> {
//     const responseText = await this.jsonBody(text, false);
//     this.appendToHistoryList(text, responseText);
//     return responseText;
//   }
}

export default ChatGPTAPI;
