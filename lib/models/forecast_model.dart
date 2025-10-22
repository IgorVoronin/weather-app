class ForecastDay {
  final DateTime date;
  final double temperature;
  final String description;
  final String icon;

  ForecastDay({
    required this.date,
    required this.temperature,
    required this.description,
    required this.icon,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json, DateTime date) {
    return ForecastDay(
      date: date,
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}
