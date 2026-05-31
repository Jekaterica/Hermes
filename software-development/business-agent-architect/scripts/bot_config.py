"""
config.py — Конфигурация бизнес-агента из .env.

КОПИРУЙ И МЕНЯЙ ПОД СВОЙ ПРОЕКТ.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # --- Telegram ---
    BOT_TOKEN: str
    BOT_USERNAME: str | None = None
    ADMIN_IDS: list[int] = []  # Telegram ID администраторов

    # --- База данных ---
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_USER: str = "agent_user"
    DB_PASS: str = "password"
    DB_NAME: str = "agent_db"

    @property
    def DB_URL(self) -> str:
        return (
            f"postgresql+asyncpg://{self.DB_USER}:{self.DB_PASS}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
        )

    @property
    def DB_URL_SYNC(self) -> str:
        return (
            f"postgresql://{self.DB_USER}:{self.DB_PASS}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
        )

    # --- Redis (опционально) ---
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_PASS: str = ""
    REDIS_DB: int = 0

    # --- LLM ---
    DEEPSEEK_API_KEY: str = ""
    DEEPSEEK_MODEL: str = "deepseek-chat"

    # --- Webhook (опционально) ---
    USE_WEBHOOK: bool = False
    WEBHOOK_HOST: str = ""
    WEBHOOK_PATH: str = "/webhook"
    WEBHOOK_SECRET: str = ""
    WEBHOOK_PORT: int = 8080

    # --- Бизнес-данные (меняй под клиента) ---
    COMPANY_NAME: str = "Компания"
    COMPANY_ADDRESS: str = ""
    COMPANY_PHONE: str = ""
    COMPANY_WORK_HOURS: str = ""

    # --- Прочее ---
    LOG_LEVEL: str = "INFO"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


settings = Settings()
