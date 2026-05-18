<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <div class="card-header">
          <div class="logo-area">
            <div class="logo-icon">
              <svg viewBox="0 0 48 48" width="96" height="96">
                <defs>
                  <linearGradient id="logoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" style="stop-color:#4A90E2;stop-opacity:1" />
                    <stop offset="100%" style="stop-color:#6BB6FF;stop-opacity:1" />
                  </linearGradient>
                  <linearGradient id="folderGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" style="stop-color:#FFD700;stop-opacity:1" />
                    <stop offset="100%" style="stop-color:#FFE55C;stop-opacity:1" />
                  </linearGradient>
                </defs>
                <!-- 云朵背景 -->
                <ellipse cx="24" cy="26" rx="18" ry="12" fill="url(#logoGradient)" opacity="0.9"/>
                <circle cx="16" cy="24" r="8" fill="url(#logoGradient)" opacity="0.9"/>
                <circle cx="32" cy="24" r="8" fill="url(#logoGradient)" opacity="0.9"/>
                <circle cx="24" cy="20" r="10" fill="url(#logoGradient)" opacity="0.9"/>
                <!-- 文件夹图标 -->
                <path d="M16 28 L16 34 C16 35.1 16.9 36 18 36 L30 36 C31.1 36 32 35.1 32 34 L32 28 L16 28 Z" fill="url(#folderGradient)" stroke="#E6C200" stroke-width="1"/>
                <path d="M16 28 L16 26 C16 24.9 16.9 24 18 24 L24 24 L26 26 L32 26 C33.1 26 32 24.9 32 26 L32 28 L16 28 Z" fill="url(#folderGradient)" stroke="#E6C200" stroke-width="1"/>
                <!-- 上传箭头 -->
                <path d="M22 30 L24 28 L26 30" fill="none" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M24 28 L24 32" fill="none" stroke="white" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
            </div>
            <h2>夸克网盘管理器</h2>
          </div>
        </div>
      </template>
      <el-tabs v-model="activeTab">
        <el-tab-pane label="二维码登录" name="qrcode">
          <div class="qrcode-login">
            <div class="qrcode-area">
              <div v-if="loading" class="qrcode-loading">
                <el-icon class="is-loading" :size="40">
                  <Loading />
                </el-icon>
                <p>正在生成二维码...</p>
              </div>
              <div v-else-if="error" class="qrcode-error">
                <el-icon :size="40" color="#f56c6c">
                  <Warning />
                </el-icon>
                <p>{{ error }}</p>
                <el-button type="primary" @click="generateQrcode">重新获取</el-button>
              </div>
              <div v-else class="qrcode-box">
                <canvas ref="qrcodeCanvas"></canvas>
              </div>
            </div>
            <div class="qrcode-tips">
              <p v-if="qrcodeToken">请使用夸克 APP 扫码登录</p>
              <p v-if="checkingLogin" class="checking-status">
                <el-icon class="is-loading"><Loading /></el-icon>
                等待扫码中...
              </p>
              <el-link type="primary" @click="generateQrcode" :disabled="loading">刷新二维码</el-link>
            </div>
          </div>
        </el-tab-pane>
        <el-tab-pane label="Cookie 登录" name="cookie">
          <div class="cookie-login">
            <el-form :model="cookieForm" label-width="80px">
              <el-form-item label="Cookie">
                <el-input
                  v-model="cookieForm.cookie"
                  type="textarea"
                  :rows="6"
                  placeholder="请输入 Cookie"
                />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="loginByCookie">登录</el-button>
              </el-form-item>
            </el-form>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading, Warning } from '@element-plus/icons-vue'
import QRCode from 'qrcode'
import { authAPI } from '@/api/quark'
import { useUserStore } from '@/stores'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const activeTab = ref('qrcode')
const loading = ref(false)
const error = ref('')
const qrcodeCanvas = ref<HTMLCanvasElement>()
const qrcodeToken = ref('')
const checkingLogin = ref(false)

let pollTimer: number | null = null

const cookieForm = reactive({
  cookie: ''
})

const generateQrcode = async () => {
  loading.value = true
  error.value = ''
  
  // 停止之前的轮询
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
  
  try {
    // 调用后端API获取二维码
    const response = await authAPI.getQRCode()
    console.log('二维码响应:', response)
    
    if (response.success && response.qrcode_url) {
      // 先设置 loading 为 false，让 canvas 显示出来
      loading.value = false
      
      // 等待 DOM 更新
      await nextTick()
      
      // 再次检查 canvas 是否存在
      if (qrcodeCanvas.value) {
        // 生成二维码图片
        await QRCode.toCanvas(qrcodeCanvas.value, response.qrcode_url, {
          width: 200,
          margin: 2,
          color: {
            dark: '#000000',
            light: '#ffffff'
          }
        })
        
        qrcodeToken.value = response.qrcode_token || ''
        ElMessage.success('二维码已生成，请使用夸克 APP 扫码')
        
        // 开始轮询检查登录状态
        if (qrcodeToken.value) {
          startPolling(qrcodeToken.value)
        }
      } else {
        console.error('Canvas 元素未找到')
        error.value = '渲染二维码失败，请刷新重试'
      }
    } else {
      loading.value = false
      error.value = response.message || '获取二维码失败'
      ElMessage.error(error.value)
    }
  } catch (err: any) {
    loading.value = false
    console.error('获取二维码失败:', err)
    error.value = err.response?.data?.detail || '获取二维码失败，请检查后端服务是否正常'
    ElMessage.error(error.value)
  }
}

const startPolling = (token: string) => {
  checkingLogin.value = true
  
  // 每2秒检查一次登录状态
  pollTimer = window.setInterval(async () => {
    try {
      const result = await authAPI.checkLogin({ qrcode_token: token })
      console.log('登录状态检查:', result)
      
      if (result.is_logged_in) {
        // 登录成功
        stopPolling()
        userStore.loginSuccess()
        ElMessage.success('登录成功！')
        // 跳转到原请求页面或文件管理
        const redirect = route.query.redirect as string || '/files'
        router.push(redirect)
      }
    } catch (err: any) {
      console.error('检查登录状态失败:', err)
      // 如果是二维码过期等错误，停止轮询
      if (err.response?.status === 400) {
        stopPolling()
        error.value = '二维码已过期，请重新获取'
        ElMessage.warning(error.value)
      }
    }
  }, 2000)
  
  // 5分钟后自动停止轮询（二维码过期）
  setTimeout(() => {
    if (pollTimer) {
      stopPolling()
      error.value = '二维码已过期，请重新获取'
      ElMessage.warning(error.value)
    }
  }, 5 * 60 * 1000)
}

const stopPolling = () => {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
  checkingLogin.value = false
}

const loginByCookie = async () => {
  if (!cookieForm.cookie.trim()) {
    ElMessage.warning('请输入 Cookie')
    return
  }
  
  try {
    const response = await authAPI.login({ 
      method: 'simple', 
      cookies: cookieForm.cookie 
    })
    
    if (response.success) {
      userStore.loginSuccess()
      ElMessage.success('登录成功')
      const redirect = route.query.redirect as string || '/files'
      router.push(redirect)
    } else {
      ElMessage.error(response.message || '登录失败')
    }
  } catch (err: any) {
    ElMessage.error(err.response?.data?.detail || '登录失败')
  }
}

// 尝试自动登录
const tryAutoLogin = async () => {
  try {
    const response = await authAPI.autoLogin()
    if (response.success) {
      userStore.loginSuccess()
      ElMessage.success('已自动登录')
      const redirect = route.query.redirect as string || '/files'
      router.push(redirect)
      return true
    }
  } catch (err: any) {
    console.log('自动登录失败:', err.response?.data?.detail || err.message)
  }
  return false
}

onMounted(async () => {
  // 如果已经登录，直接跳转
  if (userStore.isLoggedIn) {
    const redirect = route.query.redirect as string || '/files'
    router.push(redirect)
    return
  }
  
  // 先尝试自动登录
  const loggedIn = await tryAutoLogin()
  if (!loggedIn) {
    // 如果自动登录失败，生成二维码
    generateQrcode()
  }
})

onUnmounted(() => {
  stopPolling()
})
</script>

<style scoped>
.login-container {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-card {
  width: 500px;
}

.card-header {
  text-align: center;
}

.logo-area {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.logo-icon {
  animation: logoFloat 3s ease-in-out infinite;
}

@keyframes logoFloat {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-5px);
  }
}

.card-header h2 {
  margin: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  font-size: 24px;
  font-weight: 600;
}

.qrcode-login {
  text-align: center;
}

.qrcode-area {
  margin: 20px 0;
  min-height: 240px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.qrcode-loading {
  text-align: center;
}

.qrcode-loading p {
  margin-top: 10px;
  color: #666;
}

.qrcode-box {
  width: 200px;
  height: 200px;
  border: 1px solid #ddd;
  border-radius: 8px;
  overflow: hidden;
  background: #fff;
  display: flex;
  justify-content: center;
  align-items: center;
}

.qrcode-box canvas {
  display: block;
}

.qrcode-tips {
  margin-top: 20px;
}

.qrcode-tips p {
  color: #666;
  margin-bottom: 10px;
}

.cookie-login {
  padding: 10px 0;
}
</style>
