import 'package:flutter/material.dart';

// Imports

import 'package:movies/screens/home_screen.dart';
import 'package:movies/screens/details_screen.dart';

// Exports

export 'package:movies/screens/home_screen.dart';
export 'package:movies/screens/details_screen.dart';

// Routes

Map<String, WidgetBuilder> getAplicationRoutes() => <String, WidgetBuilder>{
      HomeScreen.routeName: (BuildContext context) => const HomeScreen(),
      DetailsScreen.routeName: (BuildContext context) => const DetailsScreen(),
    };
