---
name: geodetic-surveyor
description: AI-агент для автоматизации геодезических работ. Парсинг тахеометра → DXF-чертёж с точками/слоями/подписями/_RAW_DATA + пакет документов.
version: 0.2.0
author: Oleg (Hermes)
platforms: [linux]
metadata:
  hermes:
    tags: [geodesy, autocad, dxf, surveying, construction]
    related_skills: [business-agent-architect, architect]
---

# geodetic-surveyor

## Архитектура

```
Геодезист → Telegram → Hermes (Linux VPS)
                            │
                    ┌───────┴────────┐
                    │ ezdxf (основной)│
                    │ Total Open St. │
                    │ openpyxl       │
                    │ python-docx    │
                    └───────┬────────┘
                            │ DXF + XLSX + PDF
                            ▼
              Геодезист открывает в СВОЁМ AutoCAD
              (CAD-PyRx/Civil 3D — опционально на машине геодезиста)
```

**Ключевые решения:**
- Сервер на Linux — без Windows, без лицензий AutoCAD на сервере
- ezdxf — основной CAD-движок (MIT, кросс-платформенный)
- Total Open Station — парсинг тахеометров (GSI, SDR33, RW5)
- Геодезист работает в своём AutoCAD — открывает DXF
---

## Когда загружать этот skill

- Пользователь упоминает: геодезию, тахеометр, AutoCAD, Civil 3D, топоплан, исполнительную схему, разбивочный чертёж, КС-2, КС-3, ГОСТ 21.508, СП 126.13330, координаты, отметки, съёмку
- Пользователь спрашивает: «автоматизировать геодезию», «создать чертёж по точкам», «перевести тахеометр в AutoCAD», «сделать топоплан»
- Контекст: строительство, изыскания, генплан, геодезическое сопровождение

## Архитектура (обоснование)

**Почему ezdxf — основной движок, а CAD-PyRx — опциональный:**

1. **Linux-совместимость** — ezdxf работает на твоём сервере (Linux). CAD-PyRx требует Windows + AutoCAD.
2. **Batch-генерация** — ezdxf создаёт DXF без запущенного AutoCAD. CAD-PyRx требует открытого AutoCAD.
3. **80% функционала** — точки, слои, подписи, блоки, xdata, _RAW_DATA — всё есть в ezdxf.
4. **Civil 3D-специфика** (COGO, TIN, профили) — только через CAD-PyRx + C# DLL на **машине геодезиста**.

**Где что работает:**
```
Твой Linux VPS (серверная часть):
  ├── ezdxf — DXF с точками, слоями, подписями, _RAW_DATA
  ├── Total Open Station — парсинг тахеометра
  ├── openpyxl — ведомости, каталоги
  ├── python-docx — акты, справки
  └── Hermes — оркестрация, Telegram

Windows геодезиста (опционально):
  ├── CAD-PyRx — Civil 3D: COGO, TIN, профили
  └── C# DLL — обёртка над Civil 3D API (5-10 функций)
```

## Этапы разработки

### Phase 0: Подготовка ✅ (ЗАВЕРШЕНО)
- [x] Установить зависимости: ezdxf, totalopenstation, scipy, openpyxl
- [x] Создать структуру проекта /home/oleg/agents/geodetic-surveyor/
- [x] Написать pipeline.py — CSV → DXF (точки, слои, подписи, полилинии, штамп, _RAW_DATA)
- [x] Проверить: 20 синтетических точек → 40 точек DXF + 44 подписи + 9 полилиний + 9 слоёв
- [ ] Получить реальные файлы (.gsi/.sdr) и протестировать парсинг
- [ ] Открыть DXF в AutoCAD → визуальная проверка

### Phase 1: MVP «Поле → Чертёж» (3-4 недели)
- Telegram-бот (Hermes): приём файла → пайплайн
- Парсинг через Total Open Station → координаты
- Фильтрация выбросов (IQR/DBSCAN)
- Группировка по кодам → code_mapping.yaml
- ezdxf: слои по ГОСТ, точки, подписи, _RAW_DATA
- Штамп + рамка из шаблонного DXF-блока
- openpyxl: каталог координат
- ZIP → пользователю

### Phase 2: Парсинг ТЗ заказчика (3 недели)
- PDF/DOCX → Unstructured.io → текст
- LLM (DeepSeek): извлечение параметров оформления
- Явный вывод нераспознанных параметров
- Профиль заказчика (YAML)

### Phase 3: Пакет документов (3 недели)
- Ведомость объёмов из геометрии
- Акт расхождений (сравнение _RAW_DATA с итогом)
- Справка о корректности (хеш + временная метка)
- Технический отчёт (шаблон + LLM)

### Phase 4: CAD-PyRx / Civil 3D (опционально)
- C#-прослойка для Civil 3D API
- COGO-точки, TIN-поверхность, профили
- «Проект vs Факт» с цветовой индикацией

## Технологии

### Основные (установить сейчас)
```bash
pip install ezdxf              # Создание DXF (MIT)
pip install totalopenstation   # Парсинг тахеометров (GPL)
pip install scipy              # Фильтрация выбросов (BSD)
pip install openpyxl           # Excel-ведомости (MIT)
```

### Дополнительные (Phase 2+)
```bash
pip install unstructured        # Парсинг PDF/DOCX
pip install pypdf python-docx  # Лёгкие альтернативы
pip install cad-pyrx           # Для Windows/Civil 3D (LGPL)
```

## Структура проекта

```
/home/oleg/agents/geodetic-surveyor/
├── data/
│   ├── test_samples/       # Тестовые файлы .gsi/.sdr/.csv
│   └── templates/          # DXF-шаблоны штампов, рамок, блоков
├── scripts/
│   ├── parse_survey.py     # Парсинг тахеометра
│   ├── generate_dxf.py     # Создание DXF через ezdxf
│   ├── catalog_xlsx.py     # Каталог координат
│   └── pipeline.py         # Полный пайплайн
├── tests/
│   ├── test_parse.py       # Тесты парсинга
│   └── test_dxf.py         # Тесты DXF
├── config/
│   ├── code_mapping.yaml   # Соответствие кодов → слои/блоки
│   └── profile.yaml        # Профили заказчиков
└── output/                 # Выходные файлы
```

## Пайплайн (pipeline.py)

```python
# 1. Парсинг
coordinates = parse_total_station(input_file)  # → list[Point(x,y,z,code)]
# 2. Фильтрация
coordinates = filter_outliers(coordinates)      # IQR по Z
# 3. Группировка
mapping = load_mapping("config/code_mapping.yaml")
entities = group_by_code(coordinates, mapping)
# 4. DXF
doc = ezdxf.new("R2000")
add_layers(doc, entities)
add_points(doc, entities)
add_labels(doc, entities)
add_template(doc, "data/templates/a3_stamp.dxf")
add_raw_data(doc, coordinates)    # скрытый слой
doc.saveas("output/чертёж.dxf")
# 5. Ведомости
generate_catalog(coordinates, "output/каталог.xlsx")
# 6. ZIP
create_zip("output/пакет.zip", ["чертёж.dxf", "каталог.xlsx"])
```

## Pitfalls

1. **Форматы тахеометров различаются** — Total Open Station не обрабатывает все варианты GSI. Всегда тестировать на реальных файлах.
2. **Кодировка точек у всех разная** — не пытаться угадать. Юзер настраивает маппинг один раз (YAML), дальше автомат.
3. **LLM НЕ вставлять числовые данные** — только текст описаний. Все цифры (координаты, даты, номера) — строгий код.
4. **DXF версия R2000** — совместимость со всеми версиями AutoCAD. Не использовать новее без необходимости.
5. _RAW_DATA **не защищает от редактирования** в самом DXF — это не ЭЦП. Только хеш + внешняя справка.
6. **Не гоняться за идеальным Civil 3D** (TIN, профили) в MVP — Civil 3D есть не у всех геодезистов.
7. **Память в Hermes ограничена (2200 chars)** — ключевое по проекту сюда не пиши. Детали — в SKILL.md.

## Критерии качества

- Точность координат в DXF vs оригинал: < 0.001 мм
- Время обработки 5000 точек: < 30 секунд
- % ошибок парсинга: < 0.1%
- Размер DXF: < 5 MB на 5000 точек
- Код:
  - Python 3.12+
  - PEP 8
  - type hints
  - docstrings

## Коммерция

- MVP подписка: 3-5к ₽/мес
- Разово: 15-30к ₽
- Целевая аудитория: ИП-геодезисты и малые фирмы (2-5 чел)
- Конкуренты: GeoniCS (40-60к), CREDO (100к+), Topocad (60к) — все Win-плагины без серверного подхода

## Связанные файлы

### References (документация)
- `references/competition.md` — конкурентный ландшафт (GeoniCS, CREDO, Topocad, PyRadials, AutoCAD-MCP, SPCAD)
- `references/document-portfolio.md` — полный перечень документов по этапам строительства
- `references/code-mapping-guide.md` — настройка маппинга кодов точек для геодезиста

### Scripts (исполняемые)
- `scripts/pipeline.py` — полный пайплайн: CSV → парсинг → фильтр → DXF (точки, слои, подписи, полилинии, штамп, _RAW_DATA)

### Templates (шаблоны для копирования)
- `config/code_mapping.yaml` — конфиг соответствия кодов точек → слои/цвета

## История версий

- **0.2.0** — Добавлены references/: competition, document-portfolio, code-mapping-guide. Уточнена архитектура (ezdxf primary, CAD-PyRx secondary). Bump Phase 0 → завершено.
- **0.1.0** — Первая версия: архитектура, этапы, технологии, pitfalls.
