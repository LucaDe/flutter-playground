import 'package:flutter/material.dart';
import './GeneralVision.dart';
import './CarVision.dart';
import './NewsReader.dart';

class Overview extends StatelessWidget {

  onVisionApi(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralVision(),
      ),
    );
  }

  onCarVision(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CarVision()),
    );
  }

  onNewsReader(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewsReader()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('Overview'),
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(10.0),
            crossAxisSpacing: 15.0,
            mainAxisSpacing: 15.0,
            crossAxisCount: 2,
            children: <Widget>[
              OverviewCart(title: "General Vision", onPress: () { onVisionApi(context); },),
              OverviewCart(title: "Car Vision", gradient: 1, onPress: () { onCarVision(context); }),
              OverviewCart(title: "News Reader", gradient: 2, onPress: () { onNewsReader(context); }),
            ],
          ),
      )
    );
  }
}

class OverviewCart extends StatelessWidget {
  int gradient = 0;
  final String title;
  final Function onPress;

  OverviewCart({
    Key key,
    this.gradient = 0,
    @required this.title,
    @required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    const gradients = [
      [ const Color(0xFF17EAD9), const Color(0xFF6078EA) ],
      [ const Color(0xFFFCE38A), const Color(0xFFF38181) ],
      [ const Color(0xFF7117EA), const Color(0xFFEA6060) ],
    ];
    return GestureDetector(
        child: DecoratedBox(
          child: Center(
            child: Text(title, style: TextStyle(color: Colors.white, fontSize: 18.0))
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.centerRight,
              colors: gradients[gradient],
            )
          )
        ),
        onTap: onPress,
      );
  }
}