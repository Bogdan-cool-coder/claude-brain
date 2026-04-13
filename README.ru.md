# Claude Brain

**Система постоянной памяти для Claude Code, которая переживает сжатие контекста на 200K токенов.**

[English version](README.md)

## Проблема

Claude Code теряет весь контекст при достижении лимита в 200K токенов. После сжатия Claude забывает текущую задачу, план и решения — часто спрашивая «на чём остановились?» или начиная заново.

## Решение

Claude Brain использует Obsidian Vault (или любую папку) как внешнюю память с автоматическим управлением состоянием.

### Три версии:

| | CLI версия | Desktop версия | Cowork Plugin |
|--|-----------|---------------|---------------|
| **Защита** | 5/5 уровней (полная) | 3/5 уровней (частичная) | 5/5 уровней (полная) |
| **Как работает** | Хуки авто-сохраняют/восстанавливают контекст | Усиленный CLAUDE.md + launchd бэкапы | Plugin авто-загружает CLAUDE.md + skill устанавливает хуки |
| **Платформа** | Claude Code CLI в Терминале | Claude Desktop приложение (Code tab) | Claude Cowork (Desktop приложение) |
| **После сжатия** | Claude мгновенно продолжает с точного шага | Claude читает STATE по инструкциям из CLAUDE.md | Claude мгновенно продолжает с точного шага |
| **Установка** | `bash install.sh` → выбрать CLI | `bash install.sh` → выбрать Desktop | Скачать `.plugin` → открыть в Cowork → сказать «настрой brain» |

### CLI: 5 уровней защиты

| Уровень | Механизм | Что делает |
|---------|----------|-----------|
| 1 | CLAUDE.md | Автозагружаемые правила и протокол непрерывности |
| 2 | compactPrompt | Направляет что Claude сохраняет при сжатии |
| 3 | PreCompact хук | Бэкап SESSION_STATE.md перед сжатием |
| 4 | PostCompact хук | Инжекция контекста задачи после сжатия |
| 5 | SessionStart хук | Напоминание при каждом запуске |

### Desktop: 3 уровня защиты

| Уровень | Механизм | Что делает |
|---------|----------|-----------|
| 1 | Усиленный CLAUDE.md | Агрессивные инструкции самосохранения |
| 2 | compactPrompt | Направляет что Claude сохраняет при сжатии |
| 3 | launchd бэкап | Автобэкап SESSION_STATE каждые 5 минут |

> **Примечание:** Хуки не работают в Desktop из-за [известного бага](https://github.com/anthropics/claude-code/issues/42336). Desktop версия компенсирует это более сильными инструкциями в CLAUDE.md и автоматическими бэкапами.

## Быстрый старт

### Требования

- **macOS** или **Linux**
- **Claude Code CLI** (`npm install -g @anthropic-ai/claude-code`) — для CLI версии
- **Claude Desktop приложение** — для Desktop версии
- **Claude Cowork** (Desktop приложение) — для Plugin версии
- Папка для vault'ов (рекомендуется Obsidian, но необязательно)

### Вариант A: Cowork Plugin (самый простой)

1. Скачай [`claude-brain.plugin`](claude-brain.plugin) из этого репо
2. Открой в Claude Cowork — нажми **Install**
3. В любой сессии скажи: **«настрой brain»** или **«setup brain»**
4. Укажи имя vault и путь когда спросит
5. Готово — хуки, STATE и папки vault создаются автоматически

### Вариант B: CLI / Desktop установка

```bash
git clone https://github.com/bogdan-cool-coder/claude-brain.git
cd claude-brain
bash install.sh
```

Установщик покажет меню:

```
Choose what to install:

  1) CLI version        — Full protection (5/5 levels)
  2) Desktop version    — Partial protection (3/5 levels)
  3) Both               — CLI + Desktop (recommended)
```

Опционально — сделать `claude-brain` доступной как команду:

```bash
sudo ln -sf ~/.claude/hooks/claude-brain /usr/local/bin/claude-brain
```

### Инициализация проекта

```bash
cd ~/your/project
claude-brain init MyProject
```

Создаст: папку vault со структурой (00-10), `CLAUDE.md` в корне проекта, `SESSION_STATE.md`, и `.claude/brain.conf`.

### Начало работы

```bash
cd ~/your/project
claude              # CLI версия
```

Для Desktop: открой проект во вкладке Code в Claude Desktop. CLAUDE.md загрузится автоматически.

## Как это работает

### Структура Vault

Каждый проект получает папку vault с 11 директориями:

```
Obsidian Vault/MyProject/
├── 00 — General Info/
├── 01 — Architecture/
├── 02 — Change History/        (по месяцам)
├── 03 — Active Development/    (SESSION_STATE.md здесь)
├── 04 — Bug Reports/
├── 05 — Tech Debt/
├── 06 — Ideas/
├── 07 — Module Docs/
├── 08 — Snippets/
├── 09 — Infrastructure/
└── 10 — Process/
```

### SESSION_STATE.md

Сердце системы — отслеживает текущую задачу, план (→ отмечает активный шаг), изменённые файлы, **проверенный/найденный код** (предотвращает повторные поиски после сжатия), решения и следующее действие.

### Правила экономии токенов (НОВОЕ в v1.1)

На основе [исследований сообщества](https://github.com/anthropics/claude-code/issues/13579), задокументировавших 700K+ впустую потраченных токенов:

- **grep-before-implement** — всегда искать по кодовой базе перед написанием нового кода. `grep` стоит 100 токенов vs 70K за повторную реализацию существующего функционала
- **Секция Проверено/Найдено** в STATE — фиксирует что уже было найдено, предотвращая повторные поиски после сжатия
- **Защита от drift после сжатия** — явное правило читать STATE и Проверено/Найдено перед любым Edit после сжатия, противодействуя смещению поведения с аккуратного (Read→Read→Edit) на рискованное (Edit→Edit)

### Поток хуков (CLI)

```
SessionStart → Напомнить Claude прочитать STATE
     ↓
[Claude работает, контекст растёт до 200K]
     ↓
PreCompact  → Бэкап STATE
     ↓
[Контекст сжат]
     ↓
PostCompact → Инжекция: task ID, текущий шаг, следующее действие
     ↓
Claude читает STATE → Продолжает с шага →
```

### Поток Desktop

```
CLAUDE.md загружен → Claude читает STATE при старте
     ↓
[Claude работает, сохраняет STATE каждые 5 сообщений]
     ↓
[Контекст сжат — compactPrompt сохраняет ключевую информацию]
     ↓
Claude читает CLAUDE.md → Читает STATE → Продолжает с шага →
     ↓
launchd → Бэкапы каждые 5 мин (страховка)
```

## Команды

```bash
claude-brain init [имя]    # Инициализировать vault проекта
claude-brain status        # Статус текущего проекта
claude-brain list          # Список всех проектов
```

## Структура репозитория

```
claude-brain/
├── install.sh              # Главный установщик (выбор CLI/Desktop/Оба)
├── claude-brain.plugin     # Готовый к установке файл Cowork plugin
├── cli/
│   ├── install.sh          # Установщик CLI версии
│   ├── hooks/              # Хук-скрипты (SessionStart, PreCompact, PostCompact)
│   └── settings.json       # Настройки с хуками + compactPrompt
├── desktop/
│   ├── install.sh          # Установщик Desktop версии
│   ├── backup-state.sh     # Скрипт бэкапа для launchd
│   └── settings.desktop.json  # Настройки только с compactPrompt
├── plugin/                 # Исходники Cowork plugin
│   ├── .claude-plugin/     # Манифест plugin
│   ├── CLAUDE.md           # Always-on правила (авто-загружаются plugin'ом)
│   └── skills/
│       ├── brain-protocol/ # Полная методика vault, STATE формат, шаблоны
│       └── brain-setup/    # Авто-установка хуков для нового проекта
└── shared/
    ├── claude-brain         # CLI утилита управления
    └── templates/
        ├── CLAUDE.cli.md.template
        ├── CLAUDE.desktop.md.template
        └── SESSION_STATE.md.template
```

## Важно

- **CLI версия** требует Claude Code CLI v2.0+. Хуки не работают в Desktop ([баг #42336](https://github.com/anthropics/claude-code/issues/42336)).
- **Desktop версия** работает во вкладке Code Claude Desktop с частичной защитой.
- **Обе версии** можно установить вместе — они не конфликтуют.
- **Obsidian не обязателен.** Любая папка подходит как vault.
- **Переопределение для проекта.** Добавь `.claude/brain.conf` с `vault_name=CustomName` если имя vault отличается от имени директории.

## Лицензия

MIT
