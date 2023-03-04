<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue";
import { useApiKey, chatHistory, basePrompt } from "./AppState";
import OpenAIChatAPI, { Role } from "./OpenAIChatAPI";

interface ChatModel {
  isGPT: boolean;
  message: string;
}

const { getApiKey, setApiKey } = useApiKey();
const { getHistory, setHistory } = chatHistory();
const { getPrompt, setPrompt } = basePrompt();

const ErrorPrefix = "[出错咯]";
const StopTips = "[已停止]";
const LoadingTips = "💭 思考中...";

const showHelp = ref(false); // 展示帮助面板
const officialTips = ref(""); // 展示官方对话
const items = ref<ChatModel[]>([]);
const inputText = ref("");
const isLoading = ref(false);
const chatAPI = ref<OpenAIChatAPI>(new OpenAIChatAPI(""));

function renew(clearHistory = false) {
  if (clearHistory) {
    setHistory(""); // 清空历史存储
  } else {
    const history = getHistory();
    if (history) {
      items.value = JSON.parse(history);
    }
  }

  const apiKey = getApiKey();
  if (apiKey != null && apiKey.length > 0) {
    chatAPI.value = new OpenAIChatAPI(
      apiKey,
      getPrompt(),
      items.value.map((e) => {
        return {
          role: e.isGPT ? Role.assistant : Role.user,
          content: e.message,
        };
      })
    );
  }
}

renew();

function toggleHelp() {
  showHelp.value = !showHelp.value;
}

function newChat() {
  items.value = [];
  renew(true);
}

function addItem() {
  const input = inputText.value.trim();
  inputText.value = "";

  // key 操作
  if (input.startsWith("key:")) {
    const key = input.replace("key:", "");

    if (key == "clear") {
      officialTips.value = "API Key 已清空。";

      // 登出，清空 key
      setApiKey("");
    } else {
      // 更新 key
      setApiKey(key);
      renew();

      officialTips.value = "API Key 已更新。";
    }
    return;
  }

  // prompt 操作
  if (input.startsWith("prompt:")) {
    const prompt = input.replace("prompt:", "");

    if (prompt == "clear") {
      officialTips.value = "Prompt 已重置。";

      // 登出，清空
      setPrompt("");
      renew();
    } else {
      // 更新 key
      setPrompt(prompt);
      renew();

      officialTips.value = "Prompt 已更新。";
    }
    return;
  }

  const apiKey = getApiKey();
  if (apiKey == null || apiKey.length == 0) {
    officialTips.value =
      "请先按照格式「key:YOUR_API_KEY」格式输入以更新 API Key。";
    return;
  }

  // 有 key
  officialTips.value = "";

  if (isLoading.value) {
    // 加载中
    // 不应该出现这种情况，应该禁用
    inputText.value = input;
  } else {
    // 非加载中
    if (input) {
      isLoading.value = true;
      items.value.push({ isGPT: false, message: input });
      setHistory(JSON.stringify(items.value)); // 保存历史
      items.value.push({ isGPT: true, message: LoadingTips });

      // 请求 ChatGPT
      chatAPI.value
        .send(input)
        .then((reply) => {
          isLoading.value = false;
          items.value[items.value.length - 1].message = reply.trim();
          setHistory(JSON.stringify(items.value));
        })
        .catch((error) => {
          isLoading.value = false;
          let message = `${ErrorPrefix}${error}`;
          if (error.message.includes("aborted")) {
            message = StopTips;
          }
          items.value[items.value.length - 1] = {
            isGPT: true,
            message: message,
          };
        });
    }
  }
}

function stop() {
  isLoading.value = false;
  chatAPI.value.cancel();
}

function gptTextColor(text: string): string {
  if (text.startsWith(ErrorPrefix)) {
    return "red";
  }
  if (text.startsWith(StopTips)) {
    return "orange";
  }
  if (text.startsWith(LoadingTips)) {
    return "grey";
  }

  return "black";
}

// 输入框占位符
const inputPlaceholder = computed(() => {
  if (isLoading.value) {
    return LoadingTips;
  } else {
    return "请在此输入消息...";
  }
});

// 键盘与输入框
const inputBottom = ref(0);

function handleKeyboardEvent(event: any) {
  if (event.type === "show") {
    // 键盘弹起时，将input组件显示在键盘上方
    inputBottom.value = event.height;
  } else if (event.type === "hide") {
    // 键盘收起时，将input组件重新放置在屏幕底部
    inputBottom.value = 0;
  }
}

onMounted(() => {
  // 监听键盘事件
  window.addEventListener("keyboardWillShow", handleKeyboardEvent);
  window.addEventListener("keyboardWillHide", handleKeyboardEvent);
});

onUnmounted(() => {
  // 取消监听键盘事件
  window.removeEventListener("keyboardWillShow", handleKeyboardEvent);
  window.removeEventListener("keyboardWillHide", handleKeyboardEvent);
});
</script>

<template>
  <div class="chatgkd">
    <!-- Header -->
    <div class="header">
      <span class="button" @click="toggleHelp">{{
        showHelp ? "关闭帮助" : "帮助"
      }}</span>
      <div class="title-container">
        <span class="title">ChatGKD</span>
        <a class="subtitle" href="https://github.com/kingcos/ChatGKD"
          >Powered by kingcos.me</a
        >
      </div>
      <span class="button" @click="newChat">新对话</span>
    </div>

    <!-- 帮助区域 -->
    <div class="help" v-if="showHelp">
      <div>
        1. 欢迎使用 ChatGKD for web，本项目已开源在
        <a href="https://github.com/kingcos/ChatGKD"
          >github.com/kingcos/ChatGKD</a
        >；<br />
        2. ChatGKD for web 仅做接口封装与页面展示，不提供 API Key 且不对 OpenAI
        内容负责，请自行申请使用并对内容负责；<br />
        3. API
        Key、与对话历史将只保存在浏览器本地存储，不会上传或其他任何操作；<br />
        4. 请按照格式「prompt:YOUR_CUSTOM_PROMPT」替换并输入，即可更新
        Prompt；<br />
        5. 请按照格式「prompt:clear」输入，即可重置 Prompt；<br />
        6. 请按照格式「key:YOUR_API_KEY」替换并输入，即可更新 API Key；<br />
        7. 请按照格式「key:clear」输入，即可清除本地存储的 API Key；<br />
        8. 点击「新对话」将清除本次历史对话，并重新开启上下文对话。<br /><br />
        关注作者公众号「萌面大道」，更多好玩不迷路～
      </div>
    </div>
    <div class="list" v-if="items.length > 0 || officialTips">
      <div class="tips" v-if="officialTips">{{ officialTips }}</div>
      <div v-for="(item, index) in items" :key="index" class="item">
        <span v-if="item.isGPT">🤖️：</span>
        <span v-else>🧑：</span>
        <span
          v-if="item.isGPT"
          :style="{ color: gptTextColor(item.message) }"
          >{{ item.message }}</span
        >
        <span v-else class="human-text">{{ item.message }}</span>
      </div>
    </div>

    <!-- Footer -->
    <div class="footer" :style="{ bottom: inputBottom + 'px' }">
      <div class="input-wrapper">
        <input
          type="text"
          v-model="inputText"
          v-bind:placeholder="inputPlaceholder"
          v-bind:disabled="isLoading"
          @keydown.enter="addItem"
        />
      </div>
      <button v-if="isLoading" class="footer-button" @click="stop">停止</button>
      <button v-else class="footer-button" @click="addItem">发送</button>
    </div>
  </div>
</template>

<style scoped>
body {
  padding: 0px;
  margin: 0px;
}

.chatgkd {
  display: flex;
  flex-direction: column;
  height: 100%;

  padding-top: 50px;
  padding-left: 10px;
  padding-right: 10px;

  padding-bottom: 50px; /* 预留input组件的高度 */
}

.header {
  position: fixed;
  left: 0;
  right: 0;
  top: 0;
  height: 50px;

  display: flex;
  align-items: center;
  padding: 10px;
  background-color: #e2e2e2;
}

.title {
  font-size: 24px;
  font-weight: 600;
}

.subtitle {
  font-size: 12px;
}

.title-container {
  flex: 1;
  display: flex;
  align-items: center;
  flex-direction: column;
}

.button {
  color: blue;
  border: 1px solid #000;
  padding: 5px;
  border-radius: 5px;
}

.footer {
  position: fixed;
  left: 0;
  right: 0;
  height: 50px;
  width: 100%;

  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}

.help {
  position: fixed;
  left: 0;
  right: 0;
  top: 70px;

  background-color: rgba(83, 97, 246, 0.95);
  color: #ffffff;
  padding: 10px;
  margin: 10px;
  border-radius: 10px;
}

.list {
  flex: 1;
  overflow-y: auto;

  margin-top: 30px;
  margin-bottom: 10px;
  padding: 10px 10px 0px 10px;
  border-radius: 10px;
  background-color: #efefef;
}

.tips {
  padding-bottom: 10px;
}

.item {
  padding-bottom: 10px;
}

.human-text {
  font-weight: 600;
}

.input-wrapper {
  flex: 1;
  margin-right: 10px;
  height: 100%;
}

.input-wrapper input {
  width: 100%;
  height: 100%;

  padding-left: 10px;
  font-size: 14px;
  border: none;
  outline: none;

  background-color: #e2e2e2;
}

.footer-button {
  width: 80px;
  height: 100%;

  font-size: 16px;
  padding-left: 10px;
  padding-right: 10px;
}
</style>
