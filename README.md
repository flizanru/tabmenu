# Кастомная Таблица Результатов для Garry's Mod

![Скриншот Таблицы Результатов](https://cdn.discordapp.com/attachments/1317169706901307473/1326573250880213165/image.png?ex=677feb1d&is=677e999d&hm=714726f959f6bfe9de047ca5d833e459b143304f33d2fcbccdc684db5c1754b2&)

## Содержание

- [Обзор](#обзор)
- [Особенности](#особенности)
- [Использование](#использование)
- [Настройка](#настройка)
- [Специальные Привилегии](#специальные-привилегии)
- [Локализация](#локализация)
- [Оптимизация](#оптимизация)
- [Вклад](#вклад)
- [Лицензия](#лицензия)

## Обзор

**SimpleTAB** — это Lua-скрипт для Garry's Mod, предоставляющий улучшенную и визуально привлекательную таблицу результатов для администраторов серверов и игроков. Она предлагает настраиваемые столбцы, анимированные переходы и поддержку специальных ролей пользователей, обеспечивая лучший опыт взаимодействия во время игры.

## Особенности

- **Кастомные Шрифты:** Использует семейство шрифтов Montserrat для современного и чистого вида.
- **Анимированные Переходы:** Плавные анимации появления и скрытия таблицы.
- **Динамические Столбцы:** Отображение информации о игроках по нескольким столбцам, включая Имя, Привелегию, Убийства, Смерти и Пинг.
- **Специальные Привилегии:** Назначение уникальных ролей конкретным игрокам на основе их SteamID, выделенных отличительными цветами.
- **Интерактивная Информационная Панель:** Кликните на игрока, чтобы просмотреть подробную информацию, включая аватар и опции копирования имени или SteamID.
- **Поддержка Локализации:** Легко переводится и адаптируется к разным языкам.
- **Оптимизированная Производительность:** Локализованные функции и кэшированные переменные обеспечивают минимальное влияние на производительность.

## Использование

- **Просмотр TAB:**
  - Нажмите стандартную клавишу для открытия (обычно `Tab`), чтобы переключить видимость таблицы.

- **Взаимодействие с Игроками:**
  - Наведите курсор на строку игрока, чтобы выделить её.
  - Кликните на строку игрока, чтобы открыть **Информационную Панель**.
  - В Информационной Панели вы можете:
    - Просмотреть аватар и имя игрока.
    - Нажать кнопки для копирования имени или SteamID игрока в буфер обмена.

## Настройка

### Добавление Специальных Привилегий

Чтобы назначить специальные роли конкретным игрокам на основе их SteamID, измените таблицу `specialPrivileges` в скрипте:

```lua
local specialPrivileges = {
    ["STEAM_0:0:562063878"] = { role = "Разработчик", color = Color(0, 0, 255, 255) },
    -- Добавьте другие SteamID и их роли здесь
}
```

### Регулировка Расстояния Между Столбцами

Если вы хотите изменить расстояние между столбцами, отрегулируйте значения `padding` и смещения столбцов:

```lua
local padding = 10
local nameColumnX = x + padding * 2 + 10
local privilegeColumnX = nameColumnX + 200
local killsColumnX = privilegeColumnX + 150
local deathsColumnX = killsColumnX + 150
local pingColumnX = deathsColumnX + 150
```

### Изменение Цветов

Для настройки используемых цветов в таблице результатов измените определения цветов:

```lua
scoreboard.bgColor = Color(25, 25, 25, 220)
scoreboard.headerColor = Color(35, 35, 35, 255)
scoreboard.playerBgColor = Color(40, 40, 40, 200)
scoreboard.textColor = Color(255, 255, 255, 255)
scoreboard.accentColor = Color(50, 50, 50, 255)
scoreboard.buttonHoverColor = Color(70, 70, 70, 255)
scoreboard.headerTextColor = Color(200, 200, 200, 255)
scoreboard.hoverColor = Color(60, 60, 60, 255)
```

## Специальные Привилегии

### Роль Разработчика

Игроки с определенными SteamID могут быть назначены уникальными ролями, которые выделяются в таблице результатов.

- **SteamID:** `STEAM_0:0:562063878`
- **Роль:** `Разработчик`
- **Цвет Подсветки:** Синий (`Color(0, 0, 255, 255)`)

### Добавление Дополнительных Ролей

Для добавления других ролей, расширьте таблицу `specialPrivileges`:

```lua
local specialPrivileges = {
    ["STEAM_0:0:562063878"] = { role = "Разработчик", color = Color(0, 0, 255, 255) },
    ["STEAM_0:1:123456789"] = { role = "Администратор", color = Color(255, 0, 0, 255) },
    -- Добавьте дополнительные SteamID здесь
}
```

## Локализация

Все текстовые элементы в таблице результатов управляются через таблицу локализации `L`. Для перевода таблицы на другой язык измените значения в таблице `L`:

```lua
local L = {
    title = "⋘ BlackoutPVP ⋙",
    header_name = "Имя",
    header_privilege = "Привелегия",
    header_kills = "Убийства",
    header_deaths = "Смерти",
    header_ping = "Пинг",
    copy_name = "Копировать имя",
    copy_steamid = "Копировать SteamID",
    name_copied = "Имя скопировано!",
    steamid_copied = "SteamID скопирован!",
    developer = "Разработчик"
}
```

Например, для перевода на английский:

```lua
local L = {
    title = "⋘ BlackoutPVP ⋙",
    header_name = "Name",
    header_privilege = "Privilege",
    header_kills = "Kills",
    header_deaths = "Deaths",
    header_ping = "Ping",
    copy_name = "Copy Name",
    copy_steamid = "Copy SteamID",
    name_copied = "Name copied!",
    steamid_copied = "SteamID copied!",
    developer = "Developer"
}
```

## Оптимизация

Скрипт оптимизирован для производительности за счет:

- **Локализации Функций:** Часто используемые глобальные функции локализованы для уменьшения времени доступа.
- **Кэширования Переменных:** Статические значения и таблицы кэшируются для быстрого доступа.
- **Эффективной Отрисовки:** Перерисовываются только необходимые элементы каждый кадр, минимизируя нагрузку на рендеринг.

## Вклад

Вклад приветствуется! Чтобы внести изменения:

1. **Форкните Репозиторий**
2. **Создайте Новую Ветку**
   ```bash
   git checkout -b feature/YourFeature
   ```
3. **Закоммитьте Ваши Изменения**
4. **Запушьте в Ваш Форк**
5. **Откройте Pull Request**

Пожалуйста, убедитесь, что ваш код соответствует существующему стилю и включает необходимые оптимизации.

## Лицензия

Этот проект лицензирован под [MIT License](LICENSE).

---

*Разработано с ❤️ [Flizan](https://flizan.ru)*
