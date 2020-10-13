import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final appTheme = ThemeData(
  primarySwatch: Colors.green,
  accentColor: Colors.amber,
  canvasColor: Color.fromRGBO(255, 250, 255, 1),
  fontFamily: 'Corben',
  textTheme: ThemeData.light().textTheme.copyWith(
        headline1: TextStyle(
          fontFamily: 'Corben',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Color.fromRGBO(255, 251, 255, 1),
        ),
        headline2: TextStyle(
          fontFamily: 'Corben',
          color: Color.fromRGBO(20, 51, 51, 1),
        ),
        bodyText1: TextStyle(
          fontSize: 16,
          fontFamily: 'Montserrat',
          color: Colors.black54,
        ),
      ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: appTheme,
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _refreshFlag = false;

  Future<Map> _getTemperature(String place) async {
    final server = '10.0.2.2';
    final url = 'http://$server:5000/temperature/$place';

    final response = await http.get(url);
    final payload = json.decode(response.body) as Map<String, dynamic>;
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    final List<Future> list = [];
    list.add(_getTemperature('Melbourne'));
    list.add(_getTemperature('Sydney'));
    list.add(_getTemperature('పసలపూడి'));
    list.add(_getTemperature('Perth'));
    list.add(_getTemperature('Hobart'));
    list.add(_getTemperature('Canberra'));
    list.add(_getTemperature('Brisbane'));
    list.add(_getTemperature('Darwin'));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather Station',
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _refreshFlag = true;
              });
            },
          ),
        ],
      ),
      body: _refreshFlag ? WeatherGrid(list) : Container(),
    );
  }
}

/// Takes a list of futures and creates a Grid.
class WeatherGrid extends StatelessWidget {
  final List<Future> list;
  const WeatherGrid(this.list);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: list
          .map((element) => Container(child: TemperatureWidget(element)))
          .toList(),
    );
  }
}

class TemperatureWidget extends StatelessWidget {
  final Future future;
  const TemperatureWidget(this.future);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      key: UniqueKey(),
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.green,
            ),
          );
        else {
          final status = snapshot.data['status'];

          if (status != 'success')
            return Text('No Data');
          else {
            final payload = snapshot.data['data'];
            final place = payload['place'];
            final currentTemp = payload['current_temperature'];

            return Container(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Container(
                  decoration: currentTemp > 25 && currentTemp < 35
                      // Show Bright sun
                      ? BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          color: Color(0xFF0099FF),
                          gradient: RadialGradient(
                            center: const Alignment(0.7, -0.5),
                            radius: 0.2,
                            colors: [
                              const Color(0xFFFFFF00),
                              const Color(0xFF0099FF)
                            ],
                            stops: [0.6, 1.0],
                          ),
                        )
                      : currentTemp <= 25
                          ? BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              color: Colors.teal,
                            )
                          : BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              color: const Color(0xFF0099FF),
                            ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          child: Text(
                            place,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                        SizedBox(
                          height: 9,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Temperature: ',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            Text(
                              currentTemp.toString(),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                        currentTemp == 0
                            ? Container(child: Snowfall())
                            : currentTemp < 35
                                ? Container()
                                : Container(
                                    height: 100,
                                    width: 200,
                                    child: ShiningSun(),
                                  ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }
}

// Creates snowfall
class Snowfall extends StatefulWidget {
  @override
  _SnowfallState createState() => _SnowfallState();
}

class _SnowfallState extends State<Snowfall> with TickerProviderStateMixin {
  AnimationController _animationController;
  AnimationController _xController;
  Animation _animation;
  Animation _xAnimation;

  @override
  void initState() {
    super.initState();

    _xController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed)
              _xController.forward(from: 0.0);
            if (status == AnimationStatus.dismissed) _xController.forward();
          });

    _xAnimation = Tween<double>(begin: 0, end: 100).animate(_xController);
    _xController.forward();

    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed)
              _animationController.forward(from: 0.0);
            if (status == AnimationStatus.dismissed)
              _animationController.forward();
          });
    _animation =
        Tween<double>(begin: 0, end: 150).animate(_animationController);
    _animationController.forward();
    _animationController.addListener(createSnowFlake);
  }

  void createSnowFlake() {
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _xController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: Snowflake(_xAnimation, _animation),
      child: Container(),
    );
  }
}

class Snowflake extends CustomPainter {
  final Animation<double> _xAnimation;
  final Animation<double> animation;
  Snowflake(this._xAnimation, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final xPos = _xAnimation.value;
    final yPos = animation.value;

    canvas.drawCircle(Offset(xPos, yPos), 2, paint);
    canvas.drawCircle(Offset(xPos + 0, yPos), 2, paint);
    canvas.drawCircle(Offset(xPos + 5, yPos), 2, paint);
    canvas.drawCircle(Offset(xPos + 25, yPos), 2, paint);
    canvas.drawCircle(Offset(xPos + 25, yPos), 2, paint);
    canvas.drawCircle(Offset(xPos + 25, yPos + 50), 2, paint);
    canvas.drawCircle(Offset(xPos + 25, yPos + 100), 2, paint);
    canvas.drawCircle(Offset(xPos + 100, yPos), 2, paint);
    canvas.drawCircle(Offset(xPos + 40, yPos), 2, paint);
    canvas.drawCircle(Offset(xPos + 80, yPos), 2, paint);
    canvas.drawCircle(Offset(xPos + 700, yPos), 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    return true;
  }
}

/// Creates a Shining Sun and moving clouds.
class ShiningSun extends StatefulWidget {
  @override
  _ShiningSunState createState() => _ShiningSunState();
}

class _ShiningSunState extends State<ShiningSun>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(seconds: 5), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed)
              _animationController.reverse(from: 1.0);
            if (status == AnimationStatus.dismissed)
              _animationController.forward(from: 0.0);
          });

    animation = Tween<double>(begin: 0, end: 100).animate(_animationController);

    _animationController.addListener(() {
      refresh();
    });
    _animationController.forward();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          CustomPaint(
            painter: Sky(_animationController.value),
            child: Container(),
          ),
          MovingCloud(animation.value, 20.0, 10.0),
          MovingCloud(animation.value, 30.0, 30.0),
          MovingCloud(animation.value, 50.0, 60.0),
        ],
      ),
    );
  }
}

/// Creates a Shining Sun.
class Sky extends CustomPainter {
  final double val;
  const Sky(this.val);

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;

    var gradient = RadialGradient(
      center: const Alignment(0.7, -0.6),
      radius: 0.2,
      colors: [const Color(0xFFFFFF00), const Color(0xFF0099FF)],
      stops: [val, 1.0], // 'val' is the animation value
    );
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(Sky oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(Sky oldDelegate) => true;
}

// Creates a moving cloud.
class MovingCloud extends StatelessWidget {
  final delta;
  final top;
  final left;
  const MovingCloud(this.delta, this.top, this.left);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Positioned(
        top: top,
        left: left + this.delta, // To animate the position
        child: Icon(
          Icons.cloud_outlined,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
