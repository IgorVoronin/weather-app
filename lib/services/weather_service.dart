import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  // OpenWeatherMap API
  final String apiKey = 'f5e3f42aee166a05a345c41a0e4376cf';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel> getWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric&lang=ru'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel(
          city: data['name'],
          temperature: data['main']['temp'].toDouble(),
          description: data['weather'][0]['description'],
          icon: data['weather'][0]['icon'],
          feelsLike: data['main']['feels_like'].toDouble(),
          humidity: data['main']['humidity'],
          windSpeed: data['wind']['speed'].toDouble(),
        );
      } else if (response.statusCode == 404) {
        throw Exception('Город "$city" не найден. Проверьте название.');
      } else {
        throw Exception('Ошибка загрузки погоды');
      }
    } catch (e) {
      rethrow; // Перебрасываем ошибку для отображения пользователю
    }
  }

  Future<List<ForecastDay>> getForecast(String city) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=ru'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        // Группируем по дням и берем полденный прогноз (12:00)
        Map<String, Map<String, dynamic>> dailyForecasts = {};
        
        for (var item in forecastList) {
          final DateTime date = DateTime.parse(item['dt_txt']);
          final dateKey = '${date.year}-${date.month}-${date.day}';
          
          // Берем прогноз на 12:00 или ближайший к 12:00
          if (!dailyForecasts.containsKey(dateKey) || 
              (date.hour >= 12 && date.hour <= 15)) {
            dailyForecasts[dateKey] = item;
          }
        }
        
        // Берем только 5 дней
        final forecasts = dailyForecasts.entries
            .take(5)
            .map((entry) {
              final date = DateTime.parse(entry.value['dt_txt']);
              return ForecastDay.fromJson(entry.value, date);
            })
            .toList();
        
        return forecasts;
      } else {
        throw Exception('Ошибка загрузки прогноза');
      }
    } catch (e) {
      // Возвращаем пустой список при ошибке
      return [];
    }
  }

  // Фейковые данные для демонстрации
  WeatherModel _getFakeWeather(String city) {
    return WeatherModel(
      city: city,
      temperature: 22.5,
      description: 'облачно с прояснениями',
      icon: '02d',
      feelsLike: 21.0,
      humidity: 65,
      windSpeed: 3.5,
    );
  }
}
