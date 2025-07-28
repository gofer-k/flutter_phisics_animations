import 'package:first_flutter_app/bermoulli_model_types.dart';
import 'package:first_flutter_app/bermoulli_model.dart';
import 'package:first_flutter_app/bernoulli_formula_anim_curve.dart';
import 'package:first_flutter_app/dynamic_label.dart';
import 'package:first_flutter_app/pipe_path.dart';
import 'package:first_flutter_app/sigmoid_pipe_path.dart';
import 'package:flutter/material.dart';

import 'bernoulli_painter.dart';
import 'density.dart';
import 'display_expression.dart';
import 'factor_input_row.dart';
import 'factor_slider.dart';

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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _curveAnimationController;
  late Animation<double> _curveAnimation;

  late AnimationController _expandController;
  late Animation<double> _expandAnimationParameters;
  bool _isInputParametersExpanded = true;

  // Controllers for factor inputs
  late TextEditingController _startAreaController;
  late TextEditingController _endAreaController;
  late TextEditingController _startHighController;
  late TextEditingController _endHighController;
  late TextEditingController _startSpeedFlowController;
  late TextEditingController _pressureAtStartController;
  
  // Add more controllers as needed for other factors (density, pressure, etc.)

  // Variables to hold the parsed values (optional, but good for direct use)
  final BermoulliModel _model = BermoulliModel(
      area: Area(begin: 0.4, end:0.2),
      levelGround: LevelFromGround(begin: 0.0, end: 1.0),
      beginSpeed: SpeedFlow(begin: 0.0, end: 20.0),
      beginPressure: Pressure(begin: 990.0, end: 1500.0),
      density: Density.water,
      path: SigmoidCurve(
          xRange: Range(begin: -1.0, end: 1.0),
          yRange: Range(begin: 0.0, end: 1.0),
          segments: 100));

  late double _currentSpeedFlow ;
  late double _currentPressure;
  late double _currentLevel;

  final int _initAnimationDurationMilliSecs = 3000;
  final double _initStartSpeedFlow = 4.0;

  @override
  void initState() {
    super.initState();

    _model.beginPressure.value = 1000.0;
    _model.beginSpeed.value = 4.0;
    _currentSpeedFlow = _model.beginSpeed.value;
    _currentPressure = _model.beginPressure.value;
    _currentLevel = _model.levelGround.begin;

    _expandController = AnimationController(
      vsync: this, // from SingleTickerProviderStateMixin
      duration: const Duration(milliseconds: 300),
    );

    // 3. Create Animation (e.g., CurvedAnimation for easing)
    _expandAnimationParameters = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    if (_isInputParametersExpanded) {
      _expandController.forward();
    }

    // Initialize controllers with default values
    _startAreaController =
        TextEditingController(text: _model.area.begin.toString());
    _endAreaController =
        TextEditingController(text: _model.area.end.toString());
    _startHighController =
        TextEditingController(text: _model.levelGround.begin.toString());
    _endHighController =
        TextEditingController(text: _model.levelGround.end.toString());
    _startSpeedFlowController =
        TextEditingController(text: _model.beginSpeed.begin.toString());
    _pressureAtStartController =
        TextEditingController(text: _model.beginPressure.begin.toString());

    final int durationMilliSecs = _updateAnimationDdration();

    _curveAnimationController = AnimationController(
      vsync: this, // Requires SingleTickerProviderStateMixin

      duration: Duration(
          milliseconds: durationMilliSecs), // Duration for the curve drawing animation
    );
    _rebuildCurveAnimation();
  }

  @override
  void dispose() {
    _startAreaController.dispose();
    _endAreaController.dispose();
    _startHighController.dispose();
    _endHighController.dispose();
    _startSpeedFlowController.dispose();
    _curveAnimationController.dispose();
    _pressureAtStartController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpandParameters() {
    setState(() {
      _isInputParametersExpanded = !_isInputParametersExpanded;
      if (_isInputParametersExpanded) {
        _expandController.forward(); // Play animation to expand
      } else {
        _expandController.reverse(); // Play animation to collapse
      }
    });
  }

  // Helper method to build or rebuild the _curveAnimation
  void _rebuildCurveAnimation() {
    _curveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _curveAnimationController,
        curve: Curves
            .easeInOut, // Let the BezierPainter handle the "curviness" of the draw
      ),
    )
    ..addListener(() {
      setState(() {
        // This will trigger a repaint of CustomPaint
        final int indexPath = _model.indexPath(_curveAnimation.value);
        _currentSpeedFlow = _model.currentSpeedFlow(indexPath);
        _currentPressure = _model.currentPressure(indexPath);
        _currentLevel = _model.currentLevelGround(indexPath);
      });
    })
    ..addStatusListener((status){
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _currentSpeedFlow = _model.endSpeedFlow();
        _currentPressure = _model.endPressure();
        _currentLevel = _model.levelGround.end;
      }
    });
  }

  void durationMilliSecs() {
    // Try to parse values and update state, then call setState to redraw CustomPaint
    setState(() {
      final startArea =
          double.tryParse(_startAreaController.text) ?? _model.area.begin;
      final endArea =
          double.tryParse(_endAreaController.text) ?? _model.area.end;
      final startHigh =
          double.tryParse(_startHighController.text) ?? _model.levelGround.begin;
      final endHigh =
          double.tryParse(_endHighController.text) ?? _model.levelGround.end;
      final startSpeedFlow =
          double.tryParse(_startSpeedFlowController.text) ??  _model.beginSpeed.value;
      final startPressure = double.tryParse(_pressureAtStartController.text) ??
          _model.beginPressure.value;

      if (startArea != _model.area.begin ||
          endArea != _model.area.end ||
          startHigh != _model.levelGround.begin ||
          endHigh != _model.levelGround.end ||
          startSpeedFlow != _model.beginSpeed.value ||
          startPressure != _model.beginPressure.value) {
        _model.regenerateAll(
            Area(begin: startArea, end: endArea),
            LevelFromGround(begin: startHigh, end: endHigh),
            SpeedFlow(begin: startSpeedFlow, end: _model.beginSpeed.end),
            Pressure(begin: startPressure, end: _model.beginPressure.end));
        _rebuildCurveAnimation();
      }
      // _rebuildCurveAnimation();
    });
  }

  int _updateAnimationDdration() {
    return (_initStartSpeedFlow / _model.beginSpeed.value *
        _initAnimationDurationMilliSecs).round();
  }

  void _handleStartSpeed(double value) {
    if (!mounted) return;

    setState(() {
      _model.beginSpeed.value = value;
      final int duration = _updateAnimationDdration();
      _curveAnimationController.duration = Duration(milliseconds: duration);
    });
    _toggleCurveAnimation(); // Restart animation with new duration
  }

  void _handleStartArea(double value) {
    if (!mounted) return;

    setState(() {
      _model.changeArea(Area(begin: value, end: _model.area.end));
      _startAreaController.text = value.toString();
    });
    _toggleCurveAnimation(); // Restart animation with new duration
  }

  void _handleEndArea(double value) {
    if (!mounted) return;

    setState(() {
      _model.changeArea(Area(begin: _model.area.begin, end: value));
      _endAreaController.text = value.toString();
    });
    _toggleCurveAnimation(); // Restart animation with new duration
  }

  void _handleStartPressureSubmit(String value) {
    if (!mounted) return;
    final double? newPressure = double.tryParse(value);
    if (newPressure != null &&
        newPressure >= 0) { // Assuming area can't be negative
      setState(() {
        _model.beginPressure.value = newPressure;
        _pressureAtStartController.text = newPressure.toString();
      });
      _toggleCurveAnimation();
    } else {
      _pressureAtStartController.text = _model.beginPressure.value.toString();
    }
  }

  void _handleStartHighSubmit(String value) {
    if (!mounted) return;
    final double? newHighLevel = double.tryParse(value);
    if (newHighLevel != null &&
        newHighLevel >= 0) { // Assuming area can't be negative
      setState(() {
        _model.changeLevelGround(
            LevelFromGround(begin: newHighLevel, end: _model.levelGround.end));
        _startHighController.text =
            _model.levelGround.end.toString(); // Update controller text
      });
      _toggleCurveAnimation();
    } else {
      _startHighController.text = _model.levelGround.begin.toString();
    }
  }

  void _handleEndHighSubmit(String value) {
    if (!mounted) return;
    final double? newHighLevel = double.tryParse(value);
    if (newHighLevel != null &&
        newHighLevel >= 0) { // Assuming area can't be negative
      setState(() {
        _model.changeLevelGround(
            LevelFromGround(begin: _model.levelGround.begin,
                end: newHighLevel));

        _endHighController.text = newHighLevel.toString();
      });
      _toggleCurveAnimation();
    } else {
      _endHighController.text = _model.levelGround.end.toString();
    }
  }

  // Add a method to start/restart the animation if needed
  void _toggleCurveAnimation() {
    setState(() {
      if (_curveAnimationController.isAnimating) {
        _curveAnimationController.stop();
      }
      else if (_curveAnimationController.isCompleted) {
        _curveAnimationController.reset();
      }
      else {
        _curveAnimationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final deviceData = MediaQuery.of(context);

    final Size screenSize = deviceData.size;

    // Define breakpoints for different screen sizes
    double breakpointSmall = 600.0;

    // Choose the appropriate layout based on screen width
    Widget content;
    if (screenSize.width < breakpointSmall) {
      content = buildMobileLayout(screenSize);
    }
    // else if (screenSize.width < breakpointMedium) {
    //   // content = buildTabletLayout();
    // }
    else {
      content = buildDesktopLayout();
    }

    return SafeArea(child:
      Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Ogólna postać formuli Bernoulli"),
        ),
        body: Center(
          child: Container(
            width: screenSize.width * 0.9,
            color: Colors.white,
            child: content,
          ),
        )
      )
    );
  }

  Widget buildMobileLayout(Size screenSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // Center column content
        children: <Widget>[
          DisplayExpression(
              context: context,
              expression: r'\frac{V_1^2}{2} + g \cdot h_1 + \frac{p_1}{\rho} = \frac{V_2^2}{2} + g \cdot h_2 + \frac{p_2}{\rho}', scale: 1.5),
          Divider(),
          const SizedBox(height: 10), // Add some spacing
          
          animationPlaybackPanel(Size(screenSize.width * 0.8, 250)),
          
          const Divider(),

          animationResultParameters(),

          const Divider(),

          animationInputParameters(),
  
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildDesktopLayout() {
    return Text("Desktop content display here");
  }

  Widget displayParameterResult(String label, String unit, double value) {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DisplayExpression(context: context, expression: label, scale: 1.2),
        DynamicLabel(labelText: value.toStringAsFixed(2)),
        DisplayExpression(context: context, expression: unit, scale: 1.2)
      ],
    );
  }

  Widget animationPlaybackPanel(Size animationSize) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey.shade200, // Light background for the graph
          ),
          clipBehavior: Clip.hardEdge,
          child: CustomPaint(
            size: animationSize,
            painter: BernoulliPainter(
              curve: BernoulliFormulaAnimCurve.ease,
              animationProgress: _curveAnimation.value,
              originalCurveColor: Colors.deepPurple,
              offsetCurveColor: Colors.orangeAccent,
              strokeWidth: 1.5,
              dashPattern: const [20, 20], // Draw 15px, skip 8px
              model: _model,
            ),
          ),
        ),
        // const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleCurveAnimation, // Button to trigger/restart animation
              child: Icon(
                _curveAnimationController.isAnimating ? Icons.pause : Icons.play_arrow),
            ),
          ],
        ),
      ],
    );
  }

  Widget animationResultParameters() {
    return Column(
      children: [
        displayParameterResult(r'\text{p = }', r' kPa',  _currentPressure),
        displayParameterResult(r'\text{h = }', r' m', _currentLevel),
        displayParameterResult(r'\text{V = }', r' \frac{m}{s}', _currentSpeedFlow),
      ],
    );
  }
  
  Widget animationInputParameters() {
    return Column(
      children: [
        InkWell(onTap: _toggleExpandParameters,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Animation Parameters",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(
                  _isInputParametersExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 30.0,
                  semanticLabel: _isInputParametersExpanded ? 'Collapse parameters' : 'Expand parameters',
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          axisAlignment: -1.0,
          sizeFactor: _expandAnimationParameters,
          child: Column(
            children: [
              DisplayExpression(context: context, expression: r'\text{Pole przekroju }[cm^2]', scale: 1.2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: <Widget>[
                    FactorSlider(
                      label: r'a_1',
                      // initialValue: _areaAtBeginning,
                      initialValue: _model.area.begin,
                      minValue: 10.0,
                      maxValue: 50.0,
                      onChanged: _handleStartArea,),
                    FactorSlider(
                      label: r'a_2',
                      // initialValue: _areaAtEnd,
                      initialValue: _model.area.end,
                      minValue: 10.0,
                      maxValue: 50.0,
                      onChanged: _handleEndArea,),
                  ],
                ),
              ),
              FactorSlider(
                label: r'\text{Prędkość } V_1 \frac{m}{s}',
                initialValue: _model.beginSpeed.value,
                minValue: 0.0,
                maxValue: 20.0,
                onChanged: _handleStartSpeed,),
              DisplayExpression(context: context, expression: r'\text{Poziom }[cm]', scale: 1.2),
              Padding( // Optional: Add padding around the Row
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FactorInputRow(
                        label: r'h_1',
                        controller: _startHighController,
                        onSubmitted: _handleStartHighSubmit,
                      ),
                    ),
                    const SizedBox(width: 8), // Spacing between the two FactorInputRows
                    Expanded(
                      child: FactorInputRow(
                        label: r'h_2',
                        controller: _endHighController,
                        onSubmitted: _handleEndHighSubmit,
                      ),
                    ),
                  ],
                ),
              ),
              FactorInputRow(
                label: r'\text{Ciśnienie } p_1 [kPa]',
                controller: _pressureAtStartController,
                onSubmitted: _handleStartPressureSubmit,
              ),
              //TODO::
              // display_expression(context: context, expression: r'\text{Gęstość płynu } \rho', scale: 1.0, widgetWidth: widgetWidth),
            ],
          ),
        ),
      ],
    );
  }
}
