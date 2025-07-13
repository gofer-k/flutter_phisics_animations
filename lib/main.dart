import 'package:first_flutter_app/bernoulli_formula_anim.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'bernoulli_formula.dart';
import 'factor_input_row.dart';
import 'display_expression.dart';

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

  // Controllers for factor inputs
  late TextEditingController _startAreaController;
  late TextEditingController _endAreaController;
  late TextEditingController _strokeWidthController;
  late TextEditingController _flowPercentageController;
  late TextEditingController _animationDurationController;
  // Add more controllers as needed for other factors (density, pressure, etc.)

  // Variables to hold the parsed values (optional, but good for direct use)
  double _currentStartArea = 20.0;
  double _currentEndArea = 50.0;
  double _currentStrokeWidth = 1.5;
  double _currentFlowPercentage = 0.10;
  int _currentAnimationDurationSeconds = 3;
  
  @override
  void initState() {
    super.initState();

    // Initialize controllers with default values
    _startAreaController = TextEditingController(text: _currentStartArea.toString());
    _endAreaController = TextEditingController(text: _currentEndArea.toString());
    _strokeWidthController = TextEditingController(text: _currentStrokeWidth.toString());
    _flowPercentageController = TextEditingController(text: (_currentFlowPercentage * 100).toStringAsFixed(0)); // Display as %
    _animationDurationController = TextEditingController(text: _currentAnimationDurationSeconds.toString());


    // Listener to update BernoulliPainter when values change (example for one controller)
    _startAreaController.addListener(_updatePainterParameters);
    _endAreaController.addListener(_updatePainterParameters);
    _strokeWidthController.addListener(_updatePainterParameters);
    _flowPercentageController.addListener(_updatePainterParameters);
    _animationDurationController.addListener(_updatePainterAndAnimationParameters);
    
    _curveAnimationController = AnimationController(
      vsync: this, // Requires SingleTickerProviderStateMixin
      duration: Duration(seconds: _currentAnimationDurationSeconds), // Duration for the curve drawing animation
    );
    _rebuildCurveAnimation();
        // Optionally start the animation immediately
    // _curveAnimationController.forward();
  }

  @override
  void dispose() {
    _startAreaController.dispose();
    _endAreaController.dispose();
    _strokeWidthController.dispose();
    _flowPercentageController.dispose();
    _animationDurationController.dispose();

    _curveAnimationController.dispose();
    // ... (your existing dispose code)
    super.dispose();
  }

  // Helper method to build or rebuild the _curveAnimation
  void _rebuildCurveAnimation() {
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
  }
  
  void _updatePainterParameters() {
    // Try to parse values and update state, then call setState to redraw CustomPaint
    setState(() {
      _currentStartArea = double.tryParse(_startAreaController.text) ?? _currentStartArea;
      _currentEndArea = double.tryParse(_endAreaController.text) ?? _currentEndArea;
      _currentStrokeWidth = double.tryParse(_strokeWidthController.text) ?? _currentStrokeWidth;

      double percentageInput = double.tryParse(_flowPercentageController.text) ?? (_currentFlowPercentage * 100);
      _currentFlowPercentage = (percentageInput / 100).clamp(0.0, 1.0);

      _rebuildCurveAnimation();
    });
  }
  
  void _updatePainterAndAnimationParameters() {
    setState(() {
      _currentAnimationDurationSeconds = int.tryParse(_animationDurationController.text) ?? _currentAnimationDurationSeconds;
      if (_currentAnimationDurationSeconds < 1) _currentAnimationDurationSeconds = 1; // Min duration

      // Update other parameters as well if they are linked or for consistency
      _updatePainterParameters();

      // If animation duration changes, we need to update the AnimationController
      _curveAnimationController.duration = Duration(seconds: _currentAnimationDurationSeconds);
      // If the animation is running, you might want to stop and restart it,
      // or let it finish its current cycle with the old duration.
      // For simplicity, changing duration will apply on next _startCurveAnimation.
    });
  }
  
  // Add a method to start/restart the animation if needed
  void _startCurveAnimation() {
    _curveAnimationController.reset();
    _curveAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    final double widgetWidth = screenWidth * 0.90; // 90% of screen width

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
        // https://pl.wikipedia.org/wiki/R%C3%B3wnanie_Bernoulliego
        title: Text("ogólna postać formuli Bernoulli"),
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
            display_expression(context: context, expression: r'\frac{V_1^2}{2} + g \cdot h_1 + \frac{p_1}{\rho} = \frac{V_2^2}{2} + g \cdot h_2 + \frac{p_2}{\rho}', scale: 1.2, widgetWidth: widgetWidth),

            const SizedBox(height: 10), // Add some spacing
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Animation Parameters", style: Theme.of(context).textTheme.titleMedium),
            ),
            FactorInputRow(label: r'\text{Pole przekroju } p_1', unit: 'rcm^2', controller: _startAreaController),
            FactorInputRow(label:  r'\text{Pole przekroju } p_2', unit: 'rcm^2', controller: _endAreaController),
            // display_expression(context: context, expression: r'\text{Głębokość } h_1', scale: 1.0, widgetWidth: widgetWidth),
            // display_expression(context: context, expression: r'\text{Głębokość } h_2', scale: 1.0, widgetWidth: widgetWidth),
            // display_expression(context: context, expression: r'\text{Prędkość } V_1', scale: 1.0, widgetWidth: widgetWidth),
            // display_expression(context: context, expression: r'\text{Gęstość płynu } \rho', scale: 1.0, widgetWidth: widgetWidth),
            // display_expression(context: context, expression: r'\text{Ciśnienie } p_1', scale: 1.0, widgetWidth: widgetWidth),

            const SizedBox(height: 10),
            Container( // Optional: Add a border to see the CustomPaint area
              width: widgetWidth,
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
