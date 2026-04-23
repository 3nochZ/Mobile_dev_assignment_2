class Country {
  final String name;
  final String flagEmoji;
  final String region;
  final String capital;
  final int population;
  final List<String> currencies;
  final List<String> languages;
  final double area;
  final List<String> timezones;
  final String alpha3Code;

  Country({
    required this.name,
    required this.flagEmoji,
    required this.region,
    required this.capital,
    required this.population,
    required this.currencies,
    required this.languages,
    required this.area,
    required this.timezones,
    required this.alpha3Code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Extract name
    final nameData = json['name'] as Map<String, dynamic>?;
    final commonName = (nameData?['common'] as String?) ?? 'N/A';

    // Extract flag emoji
    final flag = (json['flag'] as String?) ?? '';

    // Extract region
    final region = (json['region'] as String?) ?? 'N/A';

    // Extract capital (it's a list in the API)
    final capitals = json['capital'] as List<dynamic>?;
    final capital = (capitals != null && capitals.isNotEmpty)
        ? capitals.first as String
        : 'N/A';

    // Extract population
    final population = (json['population'] as num?)?.toInt() ?? 0;

    // Extract currencies
    final currenciesData = json['currencies'] as Map<String, dynamic>?;
    final List<String> currencyList = [];
    if (currenciesData != null) {
      currenciesData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final currencyName = value['name'] as String?;
          if (currencyName != null) {
            currencyList.add(currencyName);
          }
        }
      });
    }

    // Extract languages
    final languagesData = json['languages'] as Map<String, dynamic>?;
    final List<String> languageList = [];
    if (languagesData != null) {
      languagesData.forEach((key, value) {
        if (value is String) {
          languageList.add(value);
        }
      });
    }

    // Extract area
    final area = (json['area'] as num?)?.toDouble() ?? 0.0;

    // Extract timezones
    final timezonesData = json['timezones'] as List<dynamic>?;
    final List<String> timezoneList =
        timezonesData?.map((e) => e as String).toList() ?? [];

    // Extract alpha3Code (cca3 in API)
    final alpha3Code = (json['cca3'] as String?) ?? (json['alpha3Code'] as String?) ?? 'N/A';

    return Country(
      name: commonName,
      flagEmoji: flag,
      region: region,
      capital: capital,
      population: population,
      currencies: currencyList,
      languages: languageList,
      area: area,
      timezones: timezoneList,
      alpha3Code: alpha3Code,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {'common': name},
      'flag': flagEmoji,
      'region': region,
      'capital': [capital],
      'population': population,
      'currencies': {
        for (var c in currencies) c: {'name': c}
      },
      'languages': {
        for (var l in languages) l: l
      },
      'area': area,
      'timezones': timezones,
      'cca3': alpha3Code,
    };
  }

  Country copyWith({
    String? name,
    String? flagEmoji,
    String? region,
    String? capital,
    int? population,
    List<String>? currencies,
    List<String>? languages,
    double? area,
    List<String>? timezones,
    String? alpha3Code,
  }) {
    return Country(
      name: name ?? this.name,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      region: region ?? this.region,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      area: area ?? this.area,
      timezones: timezones ?? this.timezones,
      alpha3Code: alpha3Code ?? this.alpha3Code,
    );
  }
}
