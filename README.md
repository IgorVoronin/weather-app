# Weather App

Приложение для просмотра погоды с социальными функциями.

## Функции

- Погода в реальном времени для любого города
- Лента постов с комментариями
- Профили пользователей с аватарами

## Технологии

- **BLoC** — управление состоянием
- **HTTP** — OpenWeatherMap API
- **Firebase** — аутентификация и хранилище
- **SharedPreferences** — локальное хранение
- **JSON Serialization** — модели данных

## Запуск

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Вход

Любой email и пароль (мин. 6 символов).
