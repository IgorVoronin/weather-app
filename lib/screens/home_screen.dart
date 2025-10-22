import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  WeatherModel? _weather;
  List<ForecastDay> _forecast = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWeather('Москва');
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<bool> _loadWeather(String city) async {
    setState(() => _isLoading = true);
    try {
      final weather = await _weatherService.getWeather(city);
      final forecast = await _weatherService.getForecast(city);
      setState(() {
        _weather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
      return true;
    } catch (e) {
      setState(() => _isLoading = false);
      return false;
    }
  }

  void _showCityDialog() {
    showDialog(
      context: context,
      builder: (context) => _CitySearchDialog(
        onCitySelected: (city) async {
          final success = await _loadWeather(city);
          if (success && mounted) {
            Navigator.pop(context);
          }
          return success;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Погода'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showCityDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _weather == null
              ? const Center(child: Text('Нет данных о погоде'))
              : RefreshIndicator(
                  onRefresh: () => _loadWeather(_weather!.city),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade800,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              _weather!.city,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Icon(
                              _getWeatherIcon(_weather!.icon),
                              size: 100,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${_weather!.temperature.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _weather!.description,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      Icons.thermostat,
                                      'Ощущается как',
                                      '${_weather!.feelsLike.toStringAsFixed(1)}°C',
                                    ),
                                    const Divider(),
                                    _buildInfoRow(
                                      Icons.water_drop,
                                      'Влажность',
                                      '${_weather!.humidity}%',
                                    ),
                                    const Divider(),
                                    _buildInfoRow(
                                      Icons.air,
                                      'Скорость ветра',
                                      '${_weather!.windSpeed} м/с',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_forecast.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Center(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _forecast
                                        .map((f) => _buildForecastCard(f))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(ForecastDay forecast) {
    final weekday = DateFormat('E', 'ru').format(forecast.date);
    final date = DateFormat('d/M').format(forecast.date);

    return Container(
      width: 85,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekday,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                _getWeatherIcon(forecast.icon),
                size: 36,
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 8),
              Text(
                '${forecast.temperature.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    if (iconCode.startsWith('01')) return Icons.wb_sunny;
    if (iconCode.startsWith('02')) return Icons.wb_cloudy;
    if (iconCode.startsWith('03') || iconCode.startsWith('04')) {
      return Icons.cloud;
    }
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return Icons.umbrella;
    }
    if (iconCode.startsWith('11')) return Icons.flash_on;
    if (iconCode.startsWith('13')) return Icons.ac_unit;
    return Icons.cloud;
  }
}

class _CitySearchDialog extends StatefulWidget {
  final Future<bool> Function(String city) onCitySelected;

  const _CitySearchDialog({required this.onCitySelected});

  @override
  State<_CitySearchDialog> createState() => _CitySearchDialogState();
}

class _CitySearchDialogState extends State<_CitySearchDialog> {
  final _controller = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  final List<String> _popularCities = [
    'Москва',
    'Санкт-Петербург',
    'Новосибирск',
    'Екатеринбург',
    'Казань',
    'Нижний Новгород',
    'Челябинск',
    'Самара',
    'Омск',
    'Ростов-на-Дону',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchCity(String city) async {
    if (city.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.onCitySelected(city.trim());

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!success) {
          _errorMessage = 'Город "$city" не найден. Проверьте название.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Поиск города'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Название города',
                  hintText: 'Например: Санкт-Петербург',
                  border: const OutlineInputBorder(),
                  errorText: _errorMessage,
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                enabled: !_isLoading,
                onSubmitted: _searchCity,
              ),
              const SizedBox(height: 16),
              const Text(
                'Популярные города:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ...(_popularCities.map((city) => ListTile(
                    leading: const Icon(Icons.location_city, size: 20),
                    title: Text(city),
                    dense: true,
                    enabled: !_isLoading,
                    onTap: () => _searchCity(city),
                  ))),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () => _searchCity(_controller.text),
          child: const Text('Найти'),
        ),
      ],
    );
  }
}
