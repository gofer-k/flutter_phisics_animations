
import 'package:first_flutter_app/surface_tension_page.dart';
import 'package:flutter/material.dart';

import 'bermoulli_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final bool _showDebugBanner = true; // Or some other logic to determine this

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: _showDebugBanner,
      title: "Bernoulli expressing",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            children: [
              navigatingCard(
                context,
                Image.asset("assets/icon/ic_bermoulli_card.png", fit: BoxFit.contain),
                "Bermoulli expression",
                BermoulliPage(title: "Bermoulli expression")
              ),
              navigatingCard(
                context,
                Image.asset("assets/icon/ic_surface_tension_card.png", fit: BoxFit.contain),
                "Surface tension",
                SurfaceTensionPage()
              ),
            ],
          )
      ),
    );
  }

  Card navigatingCard<T extends StatefulWidget>(
      BuildContext context, Image image, String label, T widget) {
    const double edgeMargin = 8;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child:
        Padding(
          padding: const EdgeInsets.fromLTRB(edgeMargin, edgeMargin, edgeMargin, edgeMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) {
                        return widget;
                      }),
                    ),
                  );
                },
                icon: image,
              ),
            ],
          ),
      ),
    );
  }
}
