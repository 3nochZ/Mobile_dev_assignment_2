import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/api_exception.dart';

class DetailScreen extends StatefulWidget {
  final String countryCode;
  const DetailScreen({super.key, required this.countryCode});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CountryApiService _apiService = CountryApiService();
  late Future<Country> _countryFuture;

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  void _loadCountry() {
    setState(() {
      _countryFuture = _apiService.fetchByCode(widget.countryCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Details'),
      ),
      body: FutureBuilder<Country>(
        future: _countryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            String message = 'An unexpected error occurred';
            if (error is ApiException) {
              message = error.message;
              if (error.statusCode != null) {
                message += ' (Status: ${error.statusCode})';
              }
            } else {
              message = 'An unexpected error occurred: ${error.toString()}';
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCountry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Country details not found.'));
          } else {
            final country = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      country.flagEmoji,
                      style: const TextStyle(fontSize: 100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      country.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailItem('Capital', country.capital),
                  _buildDetailItem('Region', country.region),
                  _buildDetailItem('Population', country.population.toString()),
                  _buildDetailItem('Area', '${country.area} km²'),
                  _buildDetailItem('Currencies', country.currencies.join(', ')),
                  _buildDetailItem('Languages', country.languages.join(', ')),
                  _buildDetailItem('Timezones', country.timezones.join(', ')),
                  _buildDetailItem('ISO Code', country.alpha3Code),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(fontSize: 18),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
