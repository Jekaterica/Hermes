from aiogram.types import Message
from aiogram.filters import Command
from aiogram import Router

router = Router()


@router.message(Command("admin", "help"))
async def cmd_admin(message: Message):
    """Эскалация к администратору."""
    await message.answer(
        "Свяжитесь с администратором:\n"
        "📞 [номер телефона]\n"
        "Или напишите сюда — я передам"
    )


async def escallation_handler(message: Message):
    """
    Fallback-обработчик.
    Если ни один handler не подошёл.
    """
    # Логируем непонятое сообщение
    print(f"[ESCALLATION] @{message.from_user.username}: {message.text}")

    # Без фантазий — только факт
    await message.answer(
        "Я вас не понял. "
        "Напишите /help для списка команд "
        "или /admin чтобы связаться с администратором"
    )
