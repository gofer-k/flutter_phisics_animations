import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SurfaceTensionPage extends StatefulWidget {
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
              double width = screenSize.width < breakpointSmall ? constraints.maxWidth : constraints.maxWidth;
              return Center(
                child: Container(
                  width: width,
                  color: Colors.white,
                  // TODO: design the page here
                  child: Text("Surface tension"),
                ),
              );
            }
        ),
      ),
    );
  }
}