import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'api_exception.dart';

class CountryApiService {
  final String _baseUrl = 'restcountries.com';
  final Duration _timeout = const Duration(seconds: 10);
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Country>> fetchAllCountries() async {
    final uri = Uri.https(_baseUrl, '/v3.1/all', {
      'fields': 'name,flag,region,capital,population,currencies,languages,area,timezones,cca3',
    });

    return _performRequest(() async {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);
      
      _checkResponse(response);
      
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Country.fromJson(json)).toList();
    });
  }

  Future<List<Country>> searchByName(String name) async {
    final uri = Uri.https(_baseUrl, '/v3.1/name/$name');

    return _performRequest(() async {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);
      
      if (response.statusCode == 404) {
        return []; // Return empty list if no country found
      }

      _checkResponse(response);
      
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Country.fromJson(json)).toList();
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
