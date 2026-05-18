import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authAPI } from '@/api/quark'

export const useUserStore = defineStore('user', () => {
  const isLoggedIn = ref(false)
  const userInfo = ref<any>(null)
  const loading = ref(false)
  const initialized = ref(false)

  // 从 localStorage 加载状态
  const loadFromStorage = () => {
    try {
      const stored = localStorage.getItem('quark_auth')
      if (stored) {
        const data = JSON.parse(stored)
        isLoggedIn.value = data.isLoggedIn || false
        userInfo.value = data.userInfo || null
      }
    } catch (e) {
      console.error('加载认证状态失败:', e)
    }
  }

  // 保存状态到 localStorage
  const saveToStorage = () => {
    try {
      localStorage.setItem('quark_auth', JSON.stringify({
        isLoggedIn: isLoggedIn.value,
        userInfo: userInfo.value
      }))
    } catch (e) {
      console.error('保存认证状态失败:', e)
    }
  }

  const setLoginStatus = (status: boolean) => {
    isLoggedIn.value = status
    saveToStorage()
  }

  const setUserInfo = (info: any) => {
    userInfo.value = info
    saveToStorage()
  }

  // 登录成功
  const loginSuccess = (info?: any) => {
    isLoggedIn.value = true
    if (info) {
      userInfo.value = info
    }
    saveToStorage()
  }

  // 退出登录
  const logout = async () => {
    try {
      await authAPI.logout()
    } catch (e) {
      console.error('退出登录失败:', e)
    }
    isLoggedIn.value = false
    userInfo.value = null
    localStorage.removeItem('quark_auth')
    localStorage.removeItem('quark_cookies')
    localStorage.removeItem('quark_cookies_expiry')
  }

  // 检查登录状态（调用后端 API）
  const checkAuthStatus = async () => {
    loading.value = true
    try {
      const response = await authAPI.getStatus()
      if (response.is_logged_in) {
        isLoggedIn.value = true
        userInfo.value = response.user_info || null
        saveToStorage()
        return true
      } else {
        // 后端未登录，尝试自动登录
        try {
          const autoLoginResponse = await authAPI.autoLogin()
          if (autoLoginResponse.success) {
            isLoggedIn.value = true
            saveToStorage()
            return true
          }
        } catch (e) {
          // 自动登录失败
        }
        isLoggedIn.value = false
        userInfo.value = null
        saveToStorage()
        return false
      }
    } catch (e) {
      console.error('检查登录状态失败:', e)
      return false
    } finally {
      loading.value = false
      initialized.value = true
    }
  }

  // 初始化（从 localStorage 加载并检查后端状态）
  const init = async () => {
    loadFromStorage()
    if (isLoggedIn.value) {
      // 如果本地显示已登录，验证后端状态
      await checkAuthStatus()
    } else {
      // 尝试自动登录
      await checkAuthStatus()
    }
    initialized.value = true
  }

  return {
    isLoggedIn,
    userInfo,
    loading,
    initialized,
    setLoginStatus,
    setUserInfo,
    loginSuccess,
    logout,
    checkAuthStatus,
    init
  }
})
