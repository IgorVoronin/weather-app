import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/weather_model.dart';

class FakeDataRepository {
  static List<UserModel> getFakeUsers() {
    return [
      UserModel(
        id: '1',
        name: 'Иван Иванов',
        email: 'ivan@example.com',
        city: 'Москва',
      ),
      UserModel(
        id: '2',
        name: 'Мария Петрова',
        email: 'maria@example.com',
        city: 'Санкт-Петербург',
      ),
      UserModel(
        id: '3',
        name: 'Алексей Сидоров',
        email: 'alex@example.com',
        city: 'Казань',
      ),
      UserModel(
        id: '4',
        name: 'Елена Смирнова',
        email: 'elena@example.com',
        city: 'Новосибирск',
      ),
    ];
  }

  static List<PostModel> getFakePosts() {
    final users = getFakeUsers();
    return [
      PostModel(
        id: '1',
        user: users[0],
        weather: WeatherModel(
          city: 'Москва',
          temperature: 18.5,
          description: 'ясно',
          icon: '01d',
          feelsLike: 17.0,
          humidity: 45,
          windSpeed: 2.5,
        ),
        comment: 'Отличная погода для прогулки! ☀️',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PostModel(
        id: '2',
        user: users[1],
        weather: WeatherModel(
          city: 'Санкт-Петербург',
          temperature: 15.0,
          description: 'облачно',
          icon: '03d',
          feelsLike: 14.0,
          humidity: 70,
          windSpeed: 4.0,
        ),
        comment: 'Прохладно, но приятно 🌤️',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PostModel(
        id: '3',
        user: users[2],
        weather: WeatherModel(
          city: 'Казань',
          temperature: 22.0,
          description: 'переменная облачность',
          icon: '02d',
          feelsLike: 21.5,
          humidity: 50,
          windSpeed: 3.0,
        ),
        comment: 'Лето наконец-то пришло! 🌞',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      PostModel(
        id: '4',
        user: users[3],
        weather: WeatherModel(
          city: 'Новосибирск',
          temperature: 12.0,
          description: 'дождь',
          icon: '10d',
          feelsLike: 10.0,
          humidity: 85,
          windSpeed: 5.5,
        ),
        comment: 'Не забудьте зонтики! ☔',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
