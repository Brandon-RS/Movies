import 'package:movies/models/models.dart';
import 'package:movies/providers/movie_provider.dart';
import 'package:movies/routes/routes.dart';
import 'package:provider/provider.dart';

class MovieSlider extends StatefulWidget {
  const MovieSlider({Key? key, required this.movies, this.title, required this.onNextPage}) : super(key: key);

  final List<Movie> movies;
  final String? title;
  final Function onNextPage;

  @override
  State<MovieSlider> createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {
  late ScrollController scrollController = ScrollController();

  int flag = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent - 600) {
        flag++;
        if (flag == 1) widget.onNextPage();
      } else {
        flag = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: size.width,
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(widget.title!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
            ),
          Flexible(
            child: ListView.builder(
              controller: scrollController,
              itemCount: widget.movies.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, int index) => _MoviePoster(
                movie: widget.movies[index],
                title: widget.title ?? 'undefined',
                index: index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {
  const _MoviePoster({Key? key, required this.movie, required this.title, required this.index}) : super(key: key);

  final Movie movie;
  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    movie.heroId = '$title-${movie.id}-$index-${movie.id - index}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 130.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, DetailsScreen.routeName, arguments: movie),
            child: Hero(
              tag: movie.heroId!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FadeInImage(
                  placeholder: const AssetImage('assets/images/no-image.jpg'),
                  image: NetworkImage(movie.fullPosterImg),
                  width: 130,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(movie.title, overflow: TextOverflow.ellipsis, maxLines: 2),
        ],
      ),
    );
  }
}

class SimilarMovieSlider extends StatelessWidget {
  const SimilarMovieSlider({Key? key, required this.id, required this.title}) : super(key: key);

  final int id;
  final String title;

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MovieProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: size.width,
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
          ),
          Flexible(
            child: FutureBuilder(
              future: moviesProvider.getSimilarMovies(id),
              builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 180.0,
                    child: Center(child: CircularProgressIndicator(color: Colors.indigo)),
                  );
                }

                final List<Movie> movies = snapshot.data!;

                return ListView.builder(
                  itemCount: movies.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, int index) => _MoviePoster(
                    movie: movies[index],
                    title: title,
                    index: index,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
