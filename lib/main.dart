import 'dart:ui';

import 'package:first_flutter_app/bermoulli_model_types.dart';
import 'package:first_flutter_app/bermoulli_model.dart';
import 'package:first_flutter_app/bernoulli_formula_anim_curve.dart';
import 'package:first_flutter_app/dynamic_label.dart';
import 'package:first_flutter_app/pipe_path.dart';
import 'package:first_flutter_app/sigmoid_pipe_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  
   // Variables to hold the parsed values (optional, but good for direct use)
  final pipeLength = 50.0;  // [m]
  late final BermoulliModel _model;

  late double _currentSpeedFlow ;
  late double _currentPressure;
  late double _currentLevel;

  final int _initAnimationDurationMilliSecs = 3000;
  final double _initStartSpeedFlow = 4.0;
  final animationStep = 0.02;  // 1 / 50 step of animation

  @override
  void initState() {
    super.initState();

    _model = initModel();

    _currentSpeedFlow = _model.beginSpeed.value;
    _currentPressure = _model.beginPressure.value;
    _currentLevel = _model.levelGround.begin;

    _expandController = AnimationController(
      vsync: this, // from SingleTickerProviderStateMixin
      duration: const Duration(milliseconds: 300),
    );

    _expandAnimationParameters = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    if (_isInputParametersExpanded) {
      _expandController.forward();
    }

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

  BermoulliModel initModel() {
    BermoulliModel model = BermoulliModel(
        area: Area(begin: 0.1, end:0.1),
        levelGround: LevelFromGround(begin: 0.0, end: 1.0),
        beginSpeed: SpeedFlow(begin: 0.0, end: 20.0),
        beginPressure: Pressure(begin: 990.0, end: 1500.0),
        density: Density.water,
        path: SigmoidCurve(
            xRange: Range(begin: -pipeLength / 2.0, end: pipeLength / 2.0),
            yRange: Range(begin: 0.0, end: 1.0),
            segments: 100));
    model.beginPressure.value = 1000.0;
    model.beginSpeed.value = 4.0;
    return model;
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

  void _handleStartPressure(double value) {
    if (!mounted) return;
    setState(() {
      _model.beginPressure.value = value;
      _pressureAtStartController.text = value.toString();
    });
    _toggleCurveAnimation();
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
    final Size screenSize = MediaQuery.sizeOf(context);

    // Define breakpoints for different screen sizes
    double breakpointSmall = 600.0;

    // Choose the appropriate layout based on screen width
    Widget content;
    if (screenSize.width < breakpointSmall) {
      content = buildMobileLayout(screenSize);
    }
    else {
      content = buildDesktopLayout(screenSize);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Ogólna postać formuli Bernoulli"),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check the available width
            double width = screenSize.width < breakpointSmall ? constraints.maxWidth : constraints.maxWidth;
            return Center(
              child: Container(
                width: width,
                color: Colors.white,
                child: content,
              ),
            );
          }
        ),
      ),
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
          
          animationPlaybackPanel(Size(screenSize.width * 0.9, 250)),
          
          const Divider(),

          animationResultParametersMobileMode(),

          const Divider(),

          animationInputParametersMobileMode(),
  
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildDesktopLayout(Size screenSize) {
    final LeftPanelWidth = screenSize.width * 0.4;
    final rightPanelWidth = screenSize.width * 0.4;
    final middlePanelWidth = screenSize.width - LeftPanelWidth - rightPanelWidth;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch, // Center column content
        children: [
          DisplayExpression(
              context: context,
              expression: r'\frac{V_1^2}{2} + g \cdot h_1 + \frac{p_1}{\rho} = \frac{V_2^2}{2} + g \cdot h_2 + \frac{p_2}{\rho}', scale: 1.5),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                animationPlaybackPanel(Size(LeftPanelWidth, screenSize.height * 0.4)),
                SizedBox(width: middlePanelWidth),
                Expanded(child: animationInputParametersDesktopMode(),),
              ],
            ),
          ),
          Divider(),
          const SizedBox(height: 10),
          animationResultParametersDesktopMode(),
        ],
      ),
    );
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
              onPressed: () {
                _curveAnimationController.value  =
                    _curveAnimationController.value - animationStep;
                },
              child: Icon(Icons.skip_previous),
            ),
            ElevatedButton(
              onPressed: _toggleCurveAnimation, // Button to trigger/restart animation
              child: Icon(
                _curveAnimationController.isAnimating ? Icons.pause : Icons.play_arrow),
            ),
            ElevatedButton(
              onPressed: () {
                _curveAnimationController.value  =
                    _curveAnimationController.value + animationStep;
                },
              child: Icon(Icons.skip_next),
            ),
          ],
        ),
      ],
    );
  }

  Widget animationResultParametersMobileMode() {
    return Column(
      children: [
        displayParameterResult(r'p_2 = ', r' kPa',  _currentPressure),
        displayParameterResult(r'h_2 = ', r' m', _currentLevel),
        displayParameterResult(r'V_2 = ', r' \frac{m}{s}', _currentSpeedFlow),
      ],
    );
  }

  Widget animationResultParametersDesktopMode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            spacing: 12.0,
            children: [
              displayParameterResult(r'a_1 = ', r' m^2',  _model.area.begin),
              displayParameterResult(r'a_2 = ', r' m^2',  _model.area.end),
              displayParameterResult(r'h_1 = ', r' m', _model.levelGround.begin),
              displayParameterResult(r'h_2 = ', r' m', _currentLevel),
            ],
          ),
          Row(
            spacing: 12.0,
            children: [
              displayParameterResult(r'p_1 = ', r' kPa',  _model.beginPressure.value),
              displayParameterResult(r'p_2 = ', r' kPa',  _currentPressure),
              displayParameterResult(r'V_1 = ', r' \frac{m}{s}', -_model.beginSpeed.value),
              displayParameterResult(r'V_2 = ', r' \frac{m}{s}', _currentSpeedFlow),
            ],
          ),
        ],
      ),
    );
  }

  Widget animationInputParametersMobileMode() {
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
              DisplayExpression(context: context, expression: r'\text{Pole przekroju (100..700)} cm^2', scale: 1.2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: <Widget>[
                    FactorSlider(
                      label: r'a_1',
                      initialValue: _model.area.begin,
                      minValue: 0.1,
                      maxValue: 0.7,
                      onChanged: _handleStartArea,),
                    FactorSlider(
                      label: r'a_2',
                      initialValue: _model.area.end,
                      minValue: 0.1,
                      maxValue: 0.7,
                      onChanged: _handleEndArea,),
                  ],
                ),
              ),
              DisplayExpression(context: context, expression: r'\text{Prędkość (0.0..20)} \frac{m}{s}', scale: 1.2),
              FactorSlider(
                label: r'V_1',
                initialValue: _model.beginSpeed.value,
                minValue: 0.0,
                maxValue: 20.0,
                onChanged: _handleStartSpeed,),
              DisplayExpression(context: context, expression: r'\text{Poziom podłoża (0.0..1.0)} m', scale: 1.2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FactorInputRow(
                        label: r'h_1',
                        controller: _startHighController,
                        onSubmitted: _handleStartHighSubmit,
                      ),
                    ),
                    const SizedBox(width: 8),
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
              DisplayExpression(context: context, expression: r'\text{Ciśnienie (900..1500)} kPa', scale: 1.2),
              FactorSlider(
                label: r'p_1',
                initialValue: _model.beginPressure.value,
                minValue: 900.0,
                maxValue: 1500.0,
                onChanged: _handleStartPressure),
              //TODO::
              // display_expression(context: context, expression: r'\text{Gęstość płynu } \rho', scale: 1.0, widgetWidth: widgetWidth),
            ],
          ),
        ),
      ],
    );
  }

  Widget animationInputParametersDesktopMode() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,  // Center column content
        children: [
          Text(
            "Animation Parameters",
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.justify,
          ),
          DisplayExpression(
              context: context, expression: r'\text{Pole przekroju (1  Fa700)} cm^2',
              scale: 1.0),
          FactorSlider(label: r'a_1', initialValue: _model.area.begin,
            minValue: 0.1, maxValue: 0.7,
            onChanged: _handleStartArea),
          FactorSlider(label: r'a_2', initialValue: _model.area.end,
              minValue: 0.1, maxValue: 0.7,
              onChanged: _handleEndArea),
          Divider(),
          DisplayExpression(context: context, expression: r'\text{Prędkość (0.0..20)} \frac{m}{s}', scale: 1.0),
          FactorSlider(label: r'V_1', initialValue: _model.beginSpeed.value,
              minValue: 0.0, maxValue: 20.0,
              onChanged: _handleStartSpeed),
          Divider(),
          DisplayExpression(context: context, expression: r'\text{Poziom podłoża (0.0..1.0)} m', scale: 1.0),
          FactorInputRow(
              label: r'h_2',
              controller: _endHighController,
              onSubmitted: _handleEndHighSubmit,
          ),
          DisplayExpression(context: context, expression: r'\text{Ciśnienie (900..1500)} kPa', scale: 1.2),
          FactorSlider(
              label: r'p_1',
              initialValue: _model.beginPressure.value,
              minValue: 900.0,
              maxValue: 1500.0,
              onChanged: _handleStartPressure),
          //TODO::
          // display_expression(context: context, expression: r'\text{Gęstość płynu } \rho', scale: 1.0, widgetWidth: widgetWidth),
        ],
      ),
    );
  }
}
