# Country Explorer App

## Student Information
- **Name:** [PLEASE FILL YOUR NAME]
- **Student ID:** [PLEASE FILL YOUR ID]

## Track Chosen
- **Track A:** Country Explorer App (API: RestCountries)

## App Description
Country Explorer is a Flutter application that allows users to browse, search, and view detailed information about countries worldwide. It fetches real-time data from the RestCountries public API. Features include:
- A comprehensive list of all countries.
- Search functionality by country name.
- Detailed view for each country including capital, population, region, currencies, languages, area, and timezones.
- Robust error handling for network issues, timeouts, and API errors.
- Retry mechanism for all data fetching operations.

## Bonus Tasks Implemented
- **Search Debouncing (+5 marks):** Implemented a 400ms debounce timer in the search screen to optimize API calls.
- **Local Caching (+5 marks):** Implemented an in-memory cache in the service layer with a 5-minute TTL and background refreshing. A "Cached" badge appears when data is served from cache.
- **Pagination (+5 marks):** Implemented client-side infinite scroll pagination (20 items per page) in the main list.

## Setup Instructions
1.  **Prerequisites:**
    - Flutter SDK installed (3.0.0 or higher recommended).
    - Dart SDK installed.
2.  **Clone the repository:**
    ```bash
    git clone [repository-url]
    cd Mobile_dev_assignment_2
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```
    *Note: No API key or .env file is required for this track.*

## API Endpoints Used
The application uses the following endpoints from `https://restcountries.com/v3.1`:
- `GET /all?fields=name,flag,region,capital,population,currencies,languages,area,timezones,cca3` - Fetches all countries for the home screen.
- `GET /name/{name}` - Searches for countries by name.
- `GET /alpha/{code}` - Fetches detailed information for a single country by its ISO code.

## Known Limitations or Bugs
- The search functionality depends on the API's `/name/{name}` endpoint, which may return multiple results for partial matches.
- Some countries might have missing data fields in the API (e.g., missing capital or currencies), which are handled with 'N/A' placeholders.
- Flag emojis might not render correctly on all devices/platforms (especially some Windows versions).

## Project Structure
```
lib/
├── main.dart
├── models/
│   └── country.dart
├── services/
│   ├── country_api_service.dart
│   └── api_exception.dart
└── screens/
    ├── home_screen.dart
    ├── search_screen.dart
    └── detail_screen.dart
```

