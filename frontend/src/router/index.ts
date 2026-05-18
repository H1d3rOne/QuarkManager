import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/stores'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/Home.vue'),
    meta: { title: '首页' }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录', public: true }
  },
  {
    path: '/files',
    name: 'Files',
    component: () => import('@/views/Files.vue'),
    meta: { title: '文件管理', requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach(async (to, from, next) => {
  document.title = `${to.meta.title || 'QuarkManager'} - 夸克网盘管理系统`
  
  const userStore = useUserStore()
  
  // 等待初始化完成
  if (!userStore.initialized) {
    await userStore.init()
  }
  
  // 需要认证的页面
  if (to.meta.requiresAuth && !userStore.isLoggedIn) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
    return
  }
  
  // 已登录用户访问登录页，重定向到文件管理
  if (to.name === 'Login' && userStore.isLoggedIn) {
    next({ name: 'Files' })
    return
  }
  
  next()
})

export default router
