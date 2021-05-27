import 'package:flutter/material.dart';
import 'package:roslib/roslib.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROS Sample',
      home: new RosArea(),
    );
  }
}

class RosArea extends StatefulWidget {
  RosArea({Key key}) : super(key: key);

  _RosAreaState createState() => _RosAreaState();
}

class _RosAreaState extends State<RosArea> {
  // ROSの変数
  Ros ros;
  Topic rosOutTopic;
  Topic helloTopic;
  String rosLogLine;

  @override
  void initState() {
    ros = Ros(url: 'ws://192.168.11.7:9090');
    rosOutTopic = Topic(
        ros: ros,
        name: '/hello_to_flutter',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);

    helloTopic = Topic(
        ros: ros,
        name: '/hello_from_flutter',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);

    super.initState();
  }

  void order() {
    helloTopic.publish({"data": "Hello from flutter"});
  }

  void initConnection() async {
    ros.connect();
    await rosOutTopic.subscribe();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ROS Sample'),
        ),
        body: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(20.0),
              child: StreamBuilder<Object>(
                  stream: ros.statusStream,
                  builder: (context, snapshot) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ActionChip(
                            label: Text(snapshot.data == Status.CONNECTED
                                ? 'Disconnect'
                                : 'Connect'),
                            backgroundColor: snapshot.data == Status.CONNECTED
                                ? Colors.green[300]
                                : Colors.grey[300],
                            onPressed: () {
                              if (snapshot.data == Status.CONNECTED)
                                ros.close();
                              else
                                initConnection();
                            },
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            Container(
                child: StreamBuilder(
              stream: rosOutTopic.subscription,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data["msg"]["data"]);
                } else {
                  return Text('');
                }
              },
            )),
            Positioned(
              bottom: 150,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: MaterialButton(
                  minWidth: 200,
                  onPressed: () {
                    order();
                  },
                  color: Colors.white70,
                  child: new Text(
                    "Hello",
                    style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
