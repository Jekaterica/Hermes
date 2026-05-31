"""
main.py — Точка входа Telegram-бота для малого бизнеса.

КОПИРУЙ ЭТОТ ФАЙЛ В НОВЫЙ ПРОЕКТ И МЕНЯЙ ПОД СЕБЯ.

Особенности:
- Строго по делу (архитектура Олега)
- State machine на входе
- Никаких сюрпризов
- Только то, что заказано
"""

import asyncio
import logging

from aiogram import Bot, Dispatcher
from aiogram.client.default import DefaultBotProperties
from aiogram.enums import ParseMode
from aiogram.fsm.storage.memory import MemoryStorage
from aiogram.types import BotCommand

from bot.config import settings
from bot.handlers import start, faq, booking, admin
from bot.core.escallation import escallation_handler

logger = logging.getLogger(__name__)


async def set_commands(bot: Bot):
    """Устанавливает короткие команды для бота."""
    commands = [
        BotCommand(command="start", description="Начать работу"),
        BotCommand(command="help", description="Список услуг и команд"),
        BotCommand(command="cancel", description="Отменить текущее действие"),
        BotCommand(command="admin", description="Связаться с администратором"),
    ]
    await bot.set_my_commands(commands)


async def main():
    """Запуск бота."""
    logging.basicConfig(
        level=settings.LOG_LEVEL,
        format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    )

    bot = Bot(
        token=settings.BOT_TOKEN,
        default=DefaultBotProperties(parse_mode=ParseMode.HTML),
    )
    dp = Dispatcher(storage=MemoryStorage())

    # Подключаем роутеры
    dp.include_routers(
        start.router,
        faq.router,
        booking.router,
        admin.router,
    )

    # Обработчик эскалации (всё, что не подошло под другие роутеры)
    dp.message.register(escallation_handler)

    await set_commands(bot)
    logger.info(f"Бот запущен: @{settings.BOT_USERNAME or 'unknown'}")

    # Polling (по умолчанию). Если нужны webhooks — замени на start_webhook
    await dp.start_polling(bot)


if __name__ == "__main__":
    asyncio.run(main())
