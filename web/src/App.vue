<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue";
import useApiKey from "./API";

interface ChatModel {
  isGPT: boolean;
  message: string;
}

const { apiKey, setApiKey } = useApiKey();
const items = ref<ChatModel[]>([]);
const inputText = ref("");
const isLoading = ref(false);

function addItem() {
  if (!apiKey?.length) {
    // 未验证，保存 key
    setApiKey(inputText.value);
    isVerified.value = true;
    inputText.value = "";
    return;
  }

  if (inputText.value == "登出") {
    // 登出，清空 key
    setApiKey("");
    isVerified.value = false;
    inputText.value = "";
    return;
  }

  if (isLoading.value) {
  } else {
    // 非加载中

    if (inputText.value.trim()) {
      items.value.push({ isGPT: false, message: inputText.value });
      inputText.value = "";
    }
  }
}

// 是否已保存 API Key
const isVerified = ref(apiKey?.length != 0);

// 输入框占位符
const inputPlaceholder = computed(() => {
  if (isLoading.value) {
    return "💭 思考中...";
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
    <h1 class="title">ChatGKD</h1>
    <div class="list">
      <div v-if="!isVerified" class="warn">
        <!-- 未验证，需输入 API Key -->
        <div class="item">⚠️ 请先输入 API Key</div>
        <div class="item">仅保存于浏览器缓存中，不会上传等其他使用</div>
      </div>
      <div v-else class="info">
        <!-- 已验证，可更换 -->
        <div class="item">已保存 API Key</div>
        <div class="item">输入「登出」即可清除</div>
      </div>
      <div v-for="(item, index) in items" :key="index" class="item">
        <span v-if="item.isGPT">🤖️：</span>
        <span v-else>🧑：</span>
        <span>{{ item.message }}</span>
      </div>
    </div>

    <div class="input-container" :style="{ bottom: inputBottom + 'px' }">
      <input
        type="text"
        v-model="inputText"
        v-bind:placeholder="inputPlaceholder"
        @keydown.enter="addItem"
      />
    </div>
  </div>
</template>

<style scoped>
.chatgkd {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 10px;

  padding-bottom: 50px; /* 预留input组件的高度 */
  /* background-color: red; */
}

.title {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 10px;
}

.list {
  flex: 1;
  overflow-y: auto;
}

/* .item {
  margin-bottom: 10px;
  padding: 10px;
  border-radius: 8px;
  background-color: #e4e4e4;
} */

.input-container {
  position: fixed;
  left: 0;
  right: 0;
  height: 50px;
}

input {
  width: 100%;
  height: 100%;
  border: none;
  outline: none;
  font-size: 14px;
  padding: 0 10px;

  background-color: #e2e2e2;
}

.info {
  background-color: rgb(83, 97, 246);
  color: #ffffff;
  padding: 10px;
}

.warn {
  background-color: rgb(246, 83, 83);
  color: #ffffff;
  padding: 10px;
}
</style>
