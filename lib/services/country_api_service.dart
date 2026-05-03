import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'api_exception.dart';

class CacheEntry<T> {
  final T data;
  final DateTime timestamp;

  CacheEntry(this.data) : timestamp = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(timestamp) > const Duration(minutes: 5);
}

class CountryApiService {
  final String _baseUrl = 'restcountries.com';
  final Duration _timeout = const Duration(seconds: 10);
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Cache for all countries
  CacheEntry<List<Country>>? _allCountriesCache;
  // Cache for search results
  final Map<String, CacheEntry<List<Country>>> _searchCache = {};

  bool isDataFromCache = false;

  Future<List<Country>> fetchAllCountries() async {
    isDataFromCache = false;

    // Check cache
    if (_allCountriesCache != null && !_allCountriesCache!.isExpired) {
      isDataFromCache = true;
      // Refresh in background as per bonus requirement "refreshing in the background"
      _refreshAllCountriesInBackground();
      return _allCountriesCache!.data;
    }

    final uri = Uri.https(_baseUrl, '/v3.1/all', {
      'fields': 'name,flag,region,capital,population,currencies,languages,area,timezones,cca3',
    });

    return _performRequest(() async {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);
      
      _checkResponse(response);
      
      final List<dynamic> data = jsonDecode(response.body);
      final countries = data.map((json) => Country.fromJson(json)).toList();
      
      // Update cache
      _allCountriesCache = CacheEntry(countries);
      
      return countries;
    });
  }

  void _refreshAllCountriesInBackground() async {
    try {
      final uri = Uri.https(_baseUrl, '/v3.1/all', {
        'fields': 'name,flag,region,capital,population,currencies,languages,area,timezones,cca3',
      });
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final countries = data.map((json) => Country.fromJson(json)).toList();
        _allCountriesCache = CacheEntry(countries);
      }
    } catch (_) {
      // Background refresh failed, keep existing cache
    }
  }

  Future<List<Country>> searchByName(String name) async {
    isDataFromCache = false;
    final searchKey = name.toLowerCase();

    // Check cache
    if (_searchCache.containsKey(searchKey) && !_searchCache[searchKey]!.isExpired) {
      isDataFromCache = true;
      return _searchCache[searchKey]!.data;
    }

    final uri = Uri.https(_baseUrl, '/v3.1/name/$name');

    return _performRequest(() async {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);
      
      if (response.statusCode == 404) {
        return []; 
      }

      _checkResponse(response);
      
      final List<dynamic> data = jsonDecode(response.body);
      final countries = data.map((json) => Country.fromJson(json)).toList();

      // Update cache
      _searchCache[searchKey] = CacheEntry(countries);

      return countries;
    });
  }

  Future<Country> fetchByCode(String code) async {
    final uri = Uri.https(_baseUrl, '/v3.1/alpha/$code');

    return _performRequest(() async {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);
      
      _checkResponse(response);
      
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) {
        throw ApiException('Country not found', 404);
      }
      return Country.fromJson(data.first);
    });
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        'Server returned a non-200 status',
        response.statusCode,
      );
    }
  }

  Future<T> _performRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw ApiException('No internet connection');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on FormatException {
      throw ApiException('Unexpected data format received');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }
}
