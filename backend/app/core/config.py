from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """应用配置"""
    app_name: str = "QuarkManager"
    debug: bool = True
    
    # 数据库配置
    database_url: str = "sqlite:///./data/quarkmanager.db"
    
    # Redis 配置
    redis_url: str = "redis://localhost:6379/0"
    
    # 安全配置
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24 * 7
    
    # CORS 配置
    backend_cors_origins: list[str] = [
        "http://localhost:8000",
        "http://127.0.0.1:8000",
    ]
    
    class Config:
        env_file = ".env"


@lru_cache()
def get_settings():
    """获取配置单例"""
    return Settings()
