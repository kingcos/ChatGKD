import axios from "axios";
import type { AxiosRequestConfig, CancelTokenSource } from "axios";

export enum Role {
  user = "user",
  system = "system",
  assistant = "assistant",
}

interface ChatCompletion {
  id: string;
  object: string;
  created: number;
  model: string;
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
  choices: [
    {
      message: {
        role: string;
        content: string;
      };
      finish_reason: string;
      index: number;
    }
  ];
}

class OpenAIChatAPI {
  private readonly apiKey: string;
  private readonly model: string = "gpt-3.5-turbo";

  private chatHistory: { role: Role; content: string }[] = [];
  private source: CancelTokenSource = axios.CancelToken.source();

  constructor(
    apiKey: string,
    prompt: string | null = null,
    chatHistory: { role: Role; content: string }[] = []
  ) {
    this.apiKey = apiKey;
    if (prompt) {
      this.appendHistory(prompt, Role.system);
    }
    this.chatHistory = chatHistory;
    // if (model) {
    //   this.model = model;
    // }
  }

  // Public
  async send(message: string, timeout: number = 5000): Promise<string> {
    // 发送消息
    this.appendHistory(message);
    const response = await axios(this.requestConfig());
    console.log(response.data);

    const responsData: ChatCompletion = response.data;

    if (responsData.choices.length) {
      return responsData.choices[0].message.content;
    } else {
      throw new Error(`接口响应异常！${response.data}`);
    }
  }

  cancel() {
    // 终止本次对话
    this.source.cancel("已手动终止本次请求");
  }

  // Private
  private appendHistory(content: string, role: Role = Role.user) {
    this.chatHistory.push({
      role: role,
      content: content,
    });
  }

  private requestConfig(): AxiosRequestConfig {
    return {
      method: "post",
      url: "https://api.openai.com/v1/chat/completions",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.apiKey}`,
      },
      data: { model: this.model, messages: this.chatHistory },
      cancelToken: this.source?.token,
    };
  }
}

export default OpenAIChatAPI;
