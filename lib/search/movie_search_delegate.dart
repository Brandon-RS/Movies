import 'package:movies/models/models.dart';
import 'package:movies/screens/details_screen.dart';
import 'package:provider/provider.dart';
import 'package:movies/providers/movie_provider.dart';

class MovieSearchDelegate extends SearchDelegate {
  @override
  String? get searchFieldLabel => 'Buscar Pelicula';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) return _emptyWidget();

    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    return FutureBuilder(
      future: movieProvider.searchMovie(query),
      builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
        if (!snapshot.hasData) return _emptyWidget();

        final List<Movie> movies = snapshot.data!;

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (_, int index) {
            return _MovieItem(movie: movies[index]);
          },
        );
      },
    );
  }

  Widget _emptyWidget() => const Center(
        child: Icon(Icons.movie_creation_outlined, color: Colors.black38, size: 120),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return _emptyWidget();

    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    movieProvider.getSuggestionsByQuery(query);

    return StreamBuilder(
      stream: movieProvider.suggestionStream,
      builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
        if (!snapshot.hasData) return _emptyWidget();

        final List<Movie> movies = snapshot.data!;

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (_, int index) {
            return _MovieItem(movie: movies[index]);
          },
        );
      },
    );
  }
}

class _MovieItem extends StatelessWidget {
  const _MovieItem({Key? key, required this.movie}) : super(key: key);

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    movie.heroId = 'search-${movie.id}';

    return ListTile(
      leading: FadeInImage(
        placeholder: const AssetImage('assets/images/no-image.jpg'),
        image: NetworkImage(movie.fullPosterImg),
        width: 50,
        fit: BoxFit.cover,
        height: 100,
      ),
      title: Text(movie.title),
      subtitle: Text(movie.originalTitle),
      onTap: () => Navigator.pushNamed(context, DetailsScreen.routeName, arguments: movie),
    );
  }
}
