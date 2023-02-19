import { reactive, watch } from "vue";

interface AppState {
  apiKey: string | null;
  history: string | null;
  prompt: string | null;
}

const appState: AppState = reactive({
  apiKey: null,
  history: null,
  prompt: null,
});

// 重复代码，待优化 TODO

export function basePrompt() {
  const promptKey = "me.kingcos.chatgkd.prompt";

  appState.prompt = localStorage.getItem(promptKey);

  watch(
    () => appState.prompt,
    (prompt) => {
      appState.prompt = prompt;
      if (prompt) {
        localStorage.setItem(promptKey, prompt);
      } else {
        localStorage.removeItem(promptKey);
      }
    }
  );

  const setPrompt = (prompt: string) => {
    appState.prompt = prompt;
  };

  const getPrompt = () => {
    return appState.prompt;
  };

  return { getPrompt, setPrompt };
}

export function chatHistory() {
  const storageKey = "me.kingcos.chatgkd.history";

  appState.history = localStorage.getItem(storageKey);

  watch(
    () => appState.history,
    (history) => {
      appState.history = history;
      if (history) {
        localStorage.setItem(storageKey, history);
      } else {
        localStorage.removeItem(storageKey);
      }
    }
  );

  const setHistory = (history: string) => {
    appState.history = history;
  };

  const getHistory = () => {
    return appState.history;
  };

  return { getHistory, setHistory };
}

export function useApiKey() {
  const storageKey = "me.kingcos.chatgkd.apikey";

  // 尝试从 localStorage 中获取 apiKey
  appState.apiKey = localStorage.getItem(storageKey);

  // 监听 apiKey 变化，存储在 localStorage 中
  watch(
    () => appState.apiKey,
    (apiKey) => {
      appState.apiKey = apiKey;
      if (apiKey) {
        localStorage.setItem(storageKey, apiKey);
      } else {
        localStorage.removeItem(storageKey);
      }
    }
  );

  // 返回一个设置 apiKey 的方法
  const setApiKey = (apiKey: string) => {
    appState.apiKey = apiKey;
  };

  const getApiKey = () => {
    return appState.apiKey;
  };

  return { getApiKey, setApiKey };
}
