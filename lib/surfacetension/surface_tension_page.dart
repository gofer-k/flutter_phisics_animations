import 'package:first_flutter_app/surfacetension/surface_tension_animation.dart';
import 'package:flutter/material.dart';

import '../display_expression.dart';

class SurfaceTensionPage extends StatefulWidget {
  const SurfaceTensionPage({super.key});

  @override
  State<StatefulWidget> createState() => SurfaceTensionPageState();
}

class SurfaceTensionPageState extends State<SurfaceTensionPage> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Define breakpoints for different screen sizes
    double breakpointSmall = 600.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Napięcie powierzchniowe"),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check the available width
            double width = (screenSize.width < breakpointSmall ? constraints.maxWidth : constraints.maxWidth) * 0.9;
            return Center(
              child: Column(
                children: [
                  DisplayExpression(context: context, expression: r"\gamma = \frac{F}{l} \quad [\frac{N}{m}]", scale: 1.5,),
                  SizedBox(height: 10),
                  animationContainer(Size(width, width)),
                  // TODO: Animation parameters form
                ],
              ),
            );
          }
        ),
      ),
    );
  }
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