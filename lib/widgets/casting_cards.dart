import 'package:movies/models/models.dart';
import 'package:movies/providers/movie_provider.dart';
import 'package:provider/provider.dart';

class CastingCards extends StatelessWidget {
  const CastingCards({Key? key, required this.movieId}) : super(key: key);

  final int movieId;

  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MovieProvider>(context, listen: false);

    return FutureBuilder(
      future: moviesProvider.getMovieCast(movieId),
      builder: (_, AsyncSnapshot<List<Cast>> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 180.0,
            child: Center(child: CircularProgressIndicator(color: Colors.indigo)),
          );
        }

        final List<Cast> cast = snapshot.data!;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          height: 180.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (BuildContext context, int index) => _CastCard(actor: cast[index]),
          ),
        );
      },
    );
  }
}

class _CastCard extends StatelessWidget {
  const _CastCard({Key? key, required this.actor}) : super(key: key);

  final Cast actor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 110.0,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/no-image.jpg'),
              image: NetworkImage(actor.fullProfilePath),
              height: 140,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5),
          Text(actor.name, maxLines: 2, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
