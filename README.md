# IPWatcher

Утилита в строке меню macOS для слежения за публичным IP-адресом.

## Что делает

- Показывает текущий IP прямо в трее
- Уведомляет, если IP изменился
- Работает без Dock-иконки в фоне

## Установка

```bash
git clone https://github.com/medgimet/IPWatcher.git
cd IPWatcher
swift build -c release
.build/release/IPWatcher &
```

При первом запуске откроется окно настроек — введи целевой IP и интервал проверки.
