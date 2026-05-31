"""
Базовый state machine для бизнес-агентов.
КОПИРУЙ ЭТОТ ФАЙЛ В НОВЫЙ ПРОЕКТ И МЕНЯЙ ПОД СЕБЯ.
"""

import json
from enum import Enum
from dataclasses import dataclass, field
from typing import Optional


class State(Enum):
    """Состояния агента. Меняй под свою бизнес-логику."""
    START = "start"
    AWAITING_INTENT = "awaiting_intent"
    AWAITING_CONFIRMATION = "awaiting_confirmation"
    AWAITING_DATA = "awaiting_data"  # например, ожидание даты/времени
    PROCESSING = "processing"
    ESCALATED = "escallated"


@dataclass
class Session:
    """Сессия диалога с пользователем. Хранится в БД."""
    user_id: str
    state: State = State.START
    data: dict = field(default_factory=dict)  # временные данные диалога
    history: list = field(default_factory=list)  # последние N сообщений


class StateMachine:
    """
    Машина состояний агента.
    
    Правила:
    1. Из ЛЮБОГО состояния можно перейти в ESCALATED
    2. Все write-операции требуют AWAITING_CONFIRMATION
    3. Если пользователь молчит 5+ минут — AWAITING_INTENT (сброс)
    """
    
    VALID_TRANSITIONS = {
        State.START: [State.AWAITING_INTENT],
        State.AWAITING_INTENT: [State.PROCESSING, State.ESCALATED],
        State.AWAITING_CONFIRMATION: [
            State.PROCESSING, State.AWAITING_INTENT, State.ESCALATED
        ],
        State.AWAITING_DATA: [
            State.PROCESSING, State.AWAITING_INTENT, State.ESCALATED
        ],
        State.PROCESSING: [
            State.AWAITING_INTENT, State.AWAITING_CONFIRMATION,
            State.AWAITING_DATA, State.ESCALATED
        ],
        State.ESCALATED: [],  # терминальное состояние
    }
    
    @classmethod
    def can_transition(cls, current: State, target: State) -> bool:
        """Проверка корректности перехода."""
        return target in cls.VALID_TRANSITIONS.get(current, [])
    
    @classmethod
    def transition(cls, session: Session, target: State) -> Optional[str]:
        """Выполнить переход. Возвращает ошибку или None."""
        if not cls.can_transition(session.state, target):
            return (
                f"Некорректный переход: {session.state.value} -> {target.value}. "
                f"Эскалация администратору."
            )
        session.state = target
        return None


# === Пример использования ===

def route_intent(session: Session, message: str) -> tuple[State, str]:
    """
    Определение намерения пользователя и выбор следующего состояния.
    
    В реальном проекте сюда подключается LLM для анализа намерения.
    """
    msg_lower = message.lower().strip()
    
    # Простейшая маршрутизация (для демо)
    if any(w in msg_lower for w in ["цена", "сколько стоит", "прайс"]):
        return State.PROCESSING, "price"
    elif any(w in msg_lower for w in ["записаться", "запиши", "хочу"]):
        return State.AWAITING_DATA, "booking"
    elif any(w in msg_lower for w in ["адрес", "как проехать", "где"]):
        return State.PROCESSING, "address"
    elif any(w in msg_lower for w in ["админ", "человек", "оператор"]):
        return State.ESCALATED, "escallation"
    else:
        return State.PROCESSING, "unknown"  # ответит «нет информации»


def process_message(session: Session, message: str) -> str:
    """
    Главный обработчик входящего сообщения.
    
    1. Проверить state
    2. Определить intent
    3. Выполнить переход
    4. Вызвать соответствующий handler
    5. Вернуть ответ
    """
    if session.state == State.ESCALATED:
        return "Диалог передан администратору. Ожидайте."
    
    target_state, intent = route_intent(session, message)
    
    err = StateMachine.transition(session, target_state)
    if err:
        session.state = State.ESCALATED
        return err
    
    # Здесь вызывается соответствующий handler в зависимости от intent
    # Например: handlers[intent](session, message)
    
    return f"[DEBUG] State: {session.state.value}, Intent: {intent}"
