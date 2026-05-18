<template>
  <div class="home-container">
    <el-container>
      <el-header class="header">
        <div class="header-content">
          <h1>QuarkManager</h1>
          <span class="subtitle">夸克网盘 Web 管理系统</span>
        </div>
      </el-header>
      <el-main class="main">
        <div class="welcome-card">
          <h2>欢迎使用 QuarkManager</h2>
          <p>一个功能完整的夸克网盘 Web 管理工具</p>
          <div class="action-buttons">
            <el-button v-if="userStore.isLoggedIn" type="primary" size="large" @click="$router.push('/files')">
              进入文件管理
            </el-button>
            <el-button v-else type="primary" size="large" @click="$router.push('/login')">
              开始使用
            </el-button>
          </div>
        </div>
      </el-main>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores'

const router = useRouter()
const userStore = useUserStore()

onMounted(async () => {
  // 如果已登录，直接跳转到文件管理
  if (userStore.isLoggedIn) {
    router.push('/files')
  }
})
</script>

<style scoped>
.home-container {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.header {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  display: flex;
  align-items: center;
}

.header-content h1 {
  margin: 0;
  font-size: 28px;
}

.subtitle {
  margin-left: 20px;
  font-size: 14px;
  opacity: 0.8;
}

.main {
  display: flex;
  justify-content: center;
  align-items: center;
}

.welcome-card {
  background: white;
  padding: 60px;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.welcome-card h2 {
  font-size: 32px;
  color: #333;
  margin-bottom: 16px;
}

.welcome-card p {
  color: #666;
  font-size: 16px;
  margin-bottom: 32px;
}

.action-buttons {
  margin-top: 20px;
}
</style>
