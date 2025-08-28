// import 'dart:ffi';

import 'package:first_flutter_app/surfacetension/surface_tension_animation.dart';
import 'package:first_flutter_app/widgets/display_parameter.dart';
import 'package:flutter/material.dart';

import '../widgets/display_expression.dart';

class SurfaceTensionPage extends StatefulWidget {
  const SurfaceTensionPage({super.key});

  @override
  State<StatefulWidget> createState() => SurfaceTensionPageState();
}

class SurfaceTensionPageState extends State<SurfaceTensionPage> with TickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimationParameters;
  bool _isInputParametersExpanded = true;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Define breakpoints for different screen sizes
    double breakpointSmall = 600.0;
    final isMobileMode = screenSize.width < breakpointSmall;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Napięcie powierzchniowe"),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check the available width
            double width = (isMobileMode ? constraints.maxWidth : constraints.maxWidth) * 0.9;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    initParameters(isMobileMode),
                    SizedBox(height: 10),
                    animationContainer(Size(width, width)),
                    // TODO: Animation parameters form
                    SizedBox(height: 10),
                    resultPane(),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget initParameters(bool isMobileMode) {
    return Column(
      children: [
        InkWell(
          onTap: _toggleExpandParameters,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Parametry wzburzowania tafli tafli:",
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
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Masa obiektu"),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child:  DisplayExpression(
                            context: context,
                            expression: isMobileMode ?
                            r"m = \frac{4}{3}*\pi*R_0^3" :
                            r"m = \frac{4}{3}*\pi*R_0^3 \quad kg",
                            scale: 1.2,),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Prędkość uderzeniu obiektu"),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child:  DisplayExpression(
                            context: context,
                            expression: isMobileMode ?
                            r"V = \sqrt{2*g*h}" :
                            r"V = \sqrt{2*g*h} \quad \frac{m}{s}",
                            scale: 1.2,),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Energia kinemaczna obiektu"),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child:  DisplayExpression(
                            context: context,
                            expression: isMobileMode ?
                            r"E_0 = \frac{1}{2}*m*V^2" :
                            r"E_0 = \frac{1}{2}*m*V^2 \quad \frac{kg*m^2}{s^2}",
                            scale: 1.2,),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Promień wzburzowania tafli wody"),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child:  DisplayExpression(
                            context: context,
                            expression: isMobileMode ?
                            r"R_{max} = \sqrt{R_0^2 + \frac{E_0}{\pi\,\gamma}}" :
                            r"\R_{max} = \sqrt{R_0^2 + \frac{E_0}{\pi\,\gamma}} \quad m",
                            scale: 1.2,),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Pole zmaszczoconej tafli wody"),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: DisplayExpression(
                            context: context,
                            expression: isMobileMode ?
                            r"A_spread = \pi*\R_{max}^2" :
                            r"A_spread = \pi*\R_{max}^2 \quad m^2",
                            scale: 1.2,),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Siła wzburzowania tafli wody"),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child:  DisplayExpression(
                            context: context,
                            expression: isMobileMode ?
                            r"F_\gamma = \gamma*l = \gamma*2*\pi*R" :
                            r"F_\gamma = \gamma*l = \gamma*2*\pi*R \quad N",
                            scale: 1.2,),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget animationContainer(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.grey.shade200, // Light background for the graph
        // color: Color(0xFF87CEEB),
      ),
      clipBehavior: Clip.hardEdge,
      child: SurfaceTensionAnimation(size),
    );
  }

  Widget resultPane() {
    return Column(
      children: [
        DisplayParameter(label: r"\gamma = \quad", value: 0.0, unit: r"\quad \frac{N}{m}", scale: 1.2,),
        DisplayParameter(label: r"m = \quad", value: 0.0, unit: r"\quad kg", scale: 1.2,),
        DisplayParameter(label: r"V = \quad", value: 0.0, unit: r"\quad \frac{m}{s}", scale: 1.2,),
        DisplayParameter(label: r"E_0 = \quad", value: 0.0, unit: r"\quad \frac{kg*m^2}{s^2}", scale: 1.2,),
        DisplayParameter(label: r"R_{max} = \quad", value: 0.0, unit: r"\quad m", scale: 1.2,),
        DisplayParameter(label: r"A_spread = \quad", value: 0.0, unit: r"\quad m^2", scale: 1.2,),
        DisplayParameter(label: r"F_\gamma = \quad", value: 0.0, unit: r"\quad N", scale: 1.2,),
      ],
    );
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
} // SurfaceTensionPageState