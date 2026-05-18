import axios from 'axios'

// 开发环境下使用相对路径，通过 Vite proxy 转发请求
// 生产环境下使用绝对路径
const apiBaseURL = import.meta.env.VITE_API_BASE_URL || '/api/v1'

const api = axios.create({
  baseURL: apiBaseURL,
  timeout: 120000, // 增加到 2 分钟，适应大文件上传
  headers: {}
})

api.interceptors.request.use(
  config => {
    if (typeof FormData !== 'undefined' && config.data instanceof FormData) {
      if (config.headers) {
        delete (config.headers as any)['Content-Type']
      }
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

api.interceptors.response.use(
  response => {
    return response.data
  },
  error => {
    return Promise.reject(error)
  }
)

export default api
