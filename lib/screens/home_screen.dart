import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/api_exception.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CountryApiService _apiService = CountryApiService();
  final ScrollController _scrollController = ScrollController();
  
  List<Country> _allCountries = [];
  List<Country> _displayedCountries = [];
  bool _isLoading = true;
  bool _isDataFromCache = false;
  String? _errorMessage;
  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _displayedCountries.length < _allCountries.length) {
      _loadMore();
    }
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    try {
      final countries = await _apiService.fetchAllCountries();
      // Sort countries alphabetically
      countries.sort((a, b) => a.name.compareTo(b.name));
      
      if (mounted) {
        setState(() {
          _allCountries = countries;
          _isDataFromCache = _apiService.isDataFromCache;
          _displayedCountries = _allCountries.take(_pageSize).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e is ApiException ? e.message : e.toString();
        });
      }
    }
  }

  void _loadMore() {
    if (_displayedCountries.length >= _allCountries.length) return;
    
    setState(() {
      _currentPage++;
      final nextSet = _allCountries
          .skip((_currentPage - 1) * _pageSize)
          .take(_pageSize)
          .toList();
      _displayedCountries.addAll(nextSet);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Explorer'),
        actions: [
          if (_isDataFromCache)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text('Cached', style: TextStyle(color: Colors.white, fontSize: 10)),
                backgroundColor: Colors.orange,
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _displayedCountries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _displayedCountries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCountries,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_displayedCountries.isEmpty) {
      return const Center(child: Text('No countries found.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _displayedCountries.length + (_displayedCountries.length < _allCountries.length ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _displayedCountries.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final country = _displayedCountries[index];
        return ListTile(
          leading: Text(
            country.flagEmoji,
            style: const TextStyle(fontSize: 32),
          ),
          title: Text(country.name),
          subtitle: Text(country.region),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(countryCode: country.alpha3Code),
              ),
            );
          },
        );
      },
    );
  }
}
