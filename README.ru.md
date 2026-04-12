# Claude Brain

**Система постоянной памяти для Claude Code CLI, которая переживает сжатие контекста на 200K токенов.**

Claude Code теряет весь контекст когда разговор достигает лимита в 200K токенов и сжимается. Claude Brain решает эту проблему используя Obsidian Vault (или любую папку) как внешнюю память, с хуками которые автоматически сохраняют состояние перед сжатием и восстанавливают после.

## Проблема

При работе над сложными проектами Claude Code регулярно достигает лимита в 200K токенов. После сжатия Claude забывает текущую задачу, план, решения и прогресс — часто спрашивая «на чём остановились?» или начиная заново.

## Решение

Claude Brain реализует 5 уровней защиты:

| Уровень | Механизм | Что делает |
|---------|----------|-----------|
| 1 | **CLAUDE.md** | Автозагружаемые правила и протокол непрерывности |
| 2 | **compactPrompt** | Направляет что Claude сохраняет при сжатии |
| 3 | **PreCompact хук** | Бэкап SESSION_STATE.md перед сжатием |
| 4 | **PostCompact хук** | Инжекция контекста задачи после сжатия |
| 5 | **SessionStart хук** | Напоминание прочитать состояние при каждом запуске |

После сжатия Claude сразу читает SESSION_STATE.md, находит текущий шаг (отмеченный →) и продолжает с «Далее — [действие]» без единого вопроса.

## Быстрый старт

### Требования

- **Claude Code CLI** v2.0+ (`npm install -g @anthropic-ai/claude-code`)
- **macOS** или **Linux**
- Папка для vault'ов проектов (рекомендуется Obsidian Vault, но необязательно)

### Установка (один раз)

```bash
git clone https://github.com/bogdan-cool-coder/claude-brain.git
cd claude-brain
bash install.sh
```

Установщик спросит путь к папке vault и настроит всё глобально.

Опционально — сделать `claude-brain` доступной как команду:

```bash
sudo ln -sf ~/.claude/hooks/claude-brain /usr/local/bin/claude-brain
```

### Инициализация проекта

```bash
cd ~/your/project
claude-brain init MyProject
```

Это создаст:
- Папку vault со структурой директорий (00-10)
- `CLAUDE.md` в корне проекта с протоколом непрерывности
- `SESSION_STATE.md` для отслеживания текущей задачи
- `.claude/brain.conf` — связь проекта с его vault

### Начало работы

```bash
cd ~/your/project
claude
```

Всё. Хуки автоматически активируются когда Claude Code запускается в проекте с brain.

## Как это работает

### Структура Vault

Каждый проект получает папку vault с 11 директориями:

```
Obsidian Vault/MyProject/
├── 00 — General Info/          # README, стек, версии
├── 01 — Architecture/          # Архитектура, API, БД
├── 02 — Change History/        # История ВСЕХ изменений (по месяцам)
├── 03 — Active Development/    # SESSION_STATE.md, WIP
├── 04 — Bug Reports/           # Разборы багов
├── 05 — Tech Debt/             # Техдолг, риски
├── 06 — Ideas/                 # Feature requests
├── 07 — Module Docs/           # Документация модулей
├── 08 — Snippets/              # Сниппеты, паттерны
├── 09 — Infrastructure/        # Серверы, CI/CD
└── 10 — Process/               # Git-flow, стандарты
```

### SESSION_STATE.md

Сердце системы — структурированный файл который отслеживает:
- Текущую задачу и план (→ отмечает активный шаг)
- Изменённые файлы и решения
- Счётчик сжатий
- Следующее действие (обязательно с именем файла)

### Поток хуков

```
SessionStart → Напомнить Claude прочитать STATE
     ↓
[Claude работает, контекст растёт до 200K]
     ↓
PreCompact  → Бэкап STATE, метка времени
     ↓
[Контекст сжат]
     ↓
PostCompact → Инжекция: task ID, текущий шаг, следующее действие
     ↓
Claude читает STATE → Продолжает с шага →
```

## Команды

```bash
claude-brain init [имя]    # Инициализировать vault проекта
claude-brain status        # Статус текущего проекта
claude-brain list          # Список всех проектов с vault
```

## Структура файлов

```
~/.claude/
├── settings.json          # Глобальные настройки хуков
├── brain-config           # Путь к корню vault
├── hooks/
│   ├── _detect-project.sh # Автодетект проекта и vault
│   ├── session-start.sh   # SessionStart хук
│   ├── pre-compact.sh     # PreCompact хук
│   ├── post-compact.sh    # PostCompact хук
│   └── claude-brain       # CLI утилита управления
└── templates/
    ├── CLAUDE.md.template
    └── SESSION_STATE.md.template
```

## Важно

- **Только Claude Code CLI.** Хуки не работают во вкладке Code десктопного приложения (известный баг: [#42336](https://github.com/anthropics/claude-code/issues/42336)).
- **Obsidian не обязателен.** Любая папка подходит как vault. Obsidian просто удобен для просмотра и редактирования файлов.
- **Переопределение для проекта.** Добавь `.claude/brain.conf` с `vault_name=CustomName` если имя vault отличается от имени директории.
- **Бэкапы.** PreCompact хранит последние 20 бэкапов SESSION_STATE автоматически.

## Лицензия

MIT
