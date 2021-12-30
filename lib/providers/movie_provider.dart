import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:movies/helpers/debouncer.dart';
import 'package:movies/models/models.dart';
import 'package:movies/models/search_response.dart';

class MovieProvider extends ChangeNotifier {

  // !Put your API_KEY here.
  final String _apiKey = 'c1fc4**********************2da6b';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> topRated = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;
  int _topRatedPage = 0;

  final debouncer = Debouncer(duration: const Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionStreamController = StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => _suggestionStreamController.stream;

  MovieProvider() {
    getOnDiaplayMovies();
    getPopularMovies();
    getTopRatedMovies();
  }

  Future<String> _getJsonData(String endPoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, '3/movie/$endPoint', {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });

    final response = await http.get(url);
    return response.body;
  }

  getOnDiaplayMovies() async {
    final jsonData = await _getJsonData('now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);

    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  getTopRatedMovies() async {
    _topRatedPage++;
    final jsonData = await _getJsonData('top_rated', _topRatedPage);
    final topRatedResponse = PopularResponse.fromJson(jsonData);

    topRated = [...topRated, ...topRatedResponse.results];
    notifyListeners();
  }

  Future<List<Movie>> getSimilarMovies(int id) async {
    final jsonData = await _getJsonData('$id/similar', 1);
    final similarResponse = PopularResponse.fromJson(jsonData);

    return similarResponse.results;
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final jsonData = await _getJsonData('$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;
    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'page': '1',
      'query': query,
    });

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovie(value);
      _suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
