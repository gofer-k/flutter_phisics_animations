import 'package:first_flutter_app/bernoulli_formula_anim.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'bernoulli_formula.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bernoulli expressing",
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  late AnimationController _curveAnimationController;
  late Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    // ... (your existing initState code)

    _curveAnimationController = AnimationController(
      vsync: this, // Requires SingleTickerProviderStateMixin
      duration: const Duration(seconds: 3), // Duration for the curve drawing animation
    );

    _curveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _curveAnimationController,
        curve: Curves.easeIn, // Let the BezierPainter handle the "curviness" of the draw
      ),
    )..addListener(() {
      setState(() {
        // This will trigger a repaint of CustomPaint
      });
    });

    // Optionally start the animation immediately
    // _curveAnimationController.forward();
  }

  @override
  void dispose() {
    _curveAnimationController.dispose();
    // ... (your existing dispose code)
    super.dispose();
  }

  // Add a method to start/restart the animation if needed
  void _startCurveAnimation() {
    _curveAnimationController.reset();
    _curveAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 30), // Add some spacing
            // https://pl.wikipedia.org/wiki/R%C3%B3wnanie_Bernoulliego
            Text(
              "General Bernoulli formula",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Math.tex(r'\frac{V_1^2}{2} + g*h_1 + \frac{p_1}{\rho} = \frac{V_2^2}{2} + g*h_2 + \frac{p_2}{\rho}',
                textStyle: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10), // Add some spacing
            Text(
              "Visualizing BernoulliFormulaAnim.ease:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            //TODO: modify the simulation parameters
            // V1, V2, pho (list of fluids to choose), g (const), h1, h2, p1, p2

            const SizedBox(height: 10),
            Container( // Optional: Add a border to see the CustomPaint area
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.grey.shade200, // Light background for the graph
              ),
              clipBehavior: Clip.hardEdge,
              child: CustomPaint(
                size: const Size(250, 250),
                painter: BernoulliPainter(
                  curve: BernoulliFormulaAnim.ease, // Your custom Cubic curve
                  animationProgress: _curveAnimation.value, // From your AnimationController
                  originalCurveColor: Colors.deepPurple,
                  offsetCurveColor: Colors.orangeAccent,
                  strokeWidth: 1.5,
                  startPipeRadius: 20.0, // How far apart the parallel lines are
                  endPipeRadius: 10.0,
                  segments: 100, // Increase for smoother parallels
                  dashPattern: const [20, 20], // Draw 15px, skip 8px
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _startCurveAnimation, // Button to trigger/restart animation
              child: const Text("Draw Curve"),
            ),
          ],
        ),
      ),
    );
  }
}
