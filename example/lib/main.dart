import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ffmpeg_basic/ffmpeg_basic.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _externalLibs;
  List<String> testAssetsPath = new List();
  int rc = 0;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String externalLibs;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      externalLibs = await FfmpegBasic.getExternalLibs();
    } on PlatformException {
      externalLibs = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _externalLibs = externalLibs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: _externalLibs == null
              ? CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Running on: $_externalLibs\n'),
                    ),
                    FlatButton(
                      onPressed: () async {
                        if (testAssetsPath.length > 2) return;
                        testAssetsPath.add(await exportAssets("logo.png"));
                        testAssetsPath.add(await exportAssets("sample.png"));
                        testAssetsPath.add(await exportAssets("sample2.mp4"));
                        for (String path in testAssetsPath) print(path);
                      },
                      child: Text("Export assets"),
                    ),
                    FlatButton(
                      onPressed: () async {
                        StreamSubscription streamSubscription;
                        FfmpegBasic.registerStreamListener(
                            subscription: streamSubscription,
                            fn: (rc) => print(rc));
                        if (testAssetsPath.length != 3) return;
                        String target = await getOutputFile();
                        List<String> cmd = new List();
                        cmd.add("-y");
                        cmd.add("-i");
                        cmd.add(testAssetsPath[1]);
                        cmd.add("-i");
                        cmd.add(testAssetsPath[2]);
                        cmd.add("-i");
                        cmd.add(testAssetsPath[0]);
                        cmd.add("-filter_complex");
                        cmd.add(
                            "[2:v]scale=iw/2.5:ih/2.5[logo],[1:v]scale=iw/4:ih/4[ovrl],[0:v]pad=ceil(iw/2)*2:ceil(ih/2)*2[bg],[bg][ovrl]overlay=W-w-W/65:H-h-H/65[f1],[f1][logo]overlay=W/50:H-h-H/50");
                        cmd.add(target);
                        await FfmpegBasic.execList(cmd);
                        print(target);
                        print("Returned: " + rc.toString());
                      },
                      child: Text("Test encode"),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

Future<String> exportAssets(String assetName) async {
  Directory directory = await getApplicationDocumentsDirectory();
  var dbPath = join(directory.path, assetName);
  ByteData data = await rootBundle.load("assets/$assetName");
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await File(dbPath).writeAsBytes(bytes);
  return dbPath;
}

Future<String> getOutputFile() async {
  Directory directory = await getApplicationDocumentsDirectory();
  return join(directory.path, "output.mp4");
}
