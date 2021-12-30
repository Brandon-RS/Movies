import 'package:flutter/material.dart';
import 'package:movies/providers/movie_provider.dart';
import 'package:movies/search/movie_search_delegate.dart';
import 'package:movies/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = 'Home';

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies on Cines'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: MovieSearchDelegate());
            },
            icon: const Icon(Icons.search_outlined),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardSwiper(movies: moviesProvider.onDisplayMovies),
            MovieSlider(
              movies: moviesProvider.popularMovies,
              title: 'Popular',
              onNextPage: () => moviesProvider.getPopularMovies(),
            ),
            MovieSlider(
              movies: moviesProvider.topRated,
              title: 'Top Rated',
              onNextPage: () => moviesProvider.getTopRatedMovies(),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
