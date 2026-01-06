# Описание проекта
Настройка рабочего окружения на базе концепции - Dotfiles.

# Старт с нуля

1. Установить chezmoi
2. chezmoi init https://github.com/sgolikov/dotfiles.git (т.к. нет еще git)
3. chezmoi apply

# ВСЁ!

Дальше все необходимы инструменты и их настройки развернуться сами.


# Chezmoi: границы ответственности

## Назначение
`chezmoi` используется как **источник истины для пользовательской среды**
(user environment state), а не как универсальный установщик или provisioner.

---

## Что делаем через chezmoi

### 1. Dotfiles / User State
То, что определяет **поведение среды**, а не процесс установки.

**Shell / Environment**
- `.zshrc`, `.bashrc` (адаптеры)
- aliases, functions
- `PATH`, `EDITOR`, `PAGER`, `LANG`
- `XDG_*`
- структура каталогов (`~/Workspace/...`, `~/.local/bin`)

**Git**
- `~/.gitconfig`
- `includeIf` (work / personal)
- глобальные алиасы и политики
- `.gitignore_global`

**GPG**
- `gpg.conf`, `gpg-agent.conf`
- pinentry (OS-specific)
- политика подписи (`commit.gpgsign = false`, временно)
- `GNUPGHOME`

> Криптографические ключи **не хранятся** в репозитории.

---

### 2. DevOps tooling — только конфигурация
Инструменты могут устанавливаться временно через chezmoi,
но конфигурация хранится здесь.

- `~/.aws/config` (profiles, SSO)
- `~/.terraformrc`
- другие CLI-конфиги при необходимости

---

### 3. KeePassXC (пользовательский ИБ-контур)
Через chezmoi хранится **только конфигурация**, не базы и не ключи.

- `keepassxc.ini` (OS-specific paths)
- интеграция с:
    - GPG
    - аппаратными ключами
    - (опционально) SSH agent
- политика безопасности (clipboard, агенты, defaults)

> `.kdbx` базы и приватные ключи в репозиторий не входят.

---

## Что допустимо через chezmoi временно

### Базовые переносимые пакеты
Минимум, необходимый для применения конфигов и работы CLI:

- `git`
- `gpg`
- `curl`, `unzip`, `ca-certificates`
- `jq` (опционально)

> Это **временный bootstrap**, до выноса provisioning в отдельный слой.

---

## Что НЕ делаем через chezmoi

- большие списки пакетов
- роли машины (dev / server / ci)
- сервисы и демоны
- system-level security (firewall, kernel, services)
- IDE и GUI-heavy софт
- сложную логику установки

Это зона **Ansible / Nix / отдельных install-репозиториев**.

---

## Целевая архитектура

Provisioning layer → Ansible / Nix / scripts
Thin bootstrap → 1–2 run_once (опционально)
Chezmoi (истина) → dotfiles + user security state


---

## Резюме

**Chezmoi управляет состоянием пользовательской среды и ИБ-контура.  
Установка ПО — временный bootstrap; provisioning выносится при росте сложности.**



# Правила именования

Краткая шпаргалка для нумерации `run_once_*` скриптов в репозитории dotfiles (one-repo / multi-OS).

---

## Базовый принцип

**Номер = логический этап bootstrap**, а не порядок файлов.

---

## Правила нумерации

### 01–09 — Foundation (обязательный базовый слой)

| №  | Смысл шага      | Примеры              |
| -- | --------------- | -------------------- |
| 01 | SCM             | git                  |
| 02 | Crypto / Trust  | gpg                  |
| 03 | OS env          | GNUPGHOME            |
| 04 | Shell runtime   | zsh, bash            |
| 05 | Package helpers | brew taps, apt repos |

### 10–19 — User / Dev tooling

| №  | Примеры     |
| -- | ----------- |
| 10 | git helpers |
| 11 | ssh         |
| 12 | editors     |

### 20–39 — Language toolchains

| №  | Примеры |
| -- | ------- |
| 20 | python  |
| 21 | node    |
| 22 | go      |

### 40–59 — Containers / Cloud / IaC

| №  | Примеры    |
| -- | ---------- |
| 40 | docker     |
| 41 | kubernetes |
| 42 | terraform  |

### 90–99 — Personal / Experimental

| №  | Примеры         |
| -- | --------------- |
| 90 | personal tweaks |
| 99 | experiments     |

---

## Правила именования `.chezmoiscripts`

* Все bootstrap-скрипты: `run_once_<NN>-<os>-<action>.*.tmpl`
* `<NN>` — номер этапа по таблице выше
* `<os>` — `windows | darwin | linux`
* Один номер = один смысл шага на всех ОС

Пример:

```
run_once_01-windows-install-git.ps1.tmpl
run_once_01-darwin-install-git.sh.tmpl
run_once_01-linux-install-git.sh.tmpl

run_once_02-windows-install-gpg.ps1.tmpl
run_once_02-darwin-install-gpg.sh.tmpl
run_once_02-linux-install-gpg.sh.tmpl

run_once_03-windows-set-gnupghome.ps1.tmpl
```

---

**Итог:**

* номер = смысл этапа
* OS не влияет на номер
* если шага нет на ОС — файла просто нет
