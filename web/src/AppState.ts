import { reactive, watch } from "vue";

interface AppState {
  apiKey: string | null;
  history: string | null;
}

const appState: AppState = reactive({
  apiKey: null,
  history: null,
});

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
