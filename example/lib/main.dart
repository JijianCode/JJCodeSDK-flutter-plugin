import 'package:flutter/material.dart';
import 'dart:async';

import 'package:jjcode_flutter_plugin/jjcode_flutter_plugin.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result = "";
  late JjcodeFlutterPlugin _jjcodeFlutterPlugin;
  final TextEditingController _editingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initFluwx();
    initPlatformState();
  }

  _initFluwx() async {
    await fluwx.registerWxApi(
        appId: "wx522437950f355099",
        doOnAndroid: true,
        doOnIOS: true,
        universalLink: "https://b6e148bac5a27cad.stul.sharetrace.com/ulink/");
  }

  Future responseHandler(Map<String, dynamic> data) async {
    setState(() {
      result = "verify result: \n\n"
          + "code= " + data['code'].toString() + "\n"
          + "msg= " + data['msg'].toString() + "\n";
    });
  }

  Future<bool> wxHandler(String reqUserName, String reqPath) async {
    return fluwx.launchWeChatMiniProgram(username: reqUserName, path: reqPath);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    fluwx.weChatResponseEventHandler.listen((res) {
      if (res is fluwx.WeChatLaunchMiniProgramResponse) {
        if (mounted) {
          var extMsg = res.extMsg;
          print("WeChatLaunchMiniProgramResponse exMsg: $extMsg");
          _jjcodeFlutterPlugin.handleWxResp(extMsg);
        }
      }
    });

    _jjcodeFlutterPlugin = JjcodeFlutterPlugin.getInstance();
    _jjcodeFlutterPlugin.setWxHandler(wxHandler);

    setState(() {
      result = "Init";
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(result, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Padding(padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: TextField(
                    controller: _editingController,
                    decoration: const InputDecoration(
                        hintText: '请输入手机号'
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(padding:  const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: RaisedButton(
                      onPressed: () {
                        var phone = _editingController.text;
                        _jjcodeFlutterPlugin.verify(phone, responseHandler);
                      },
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: const Text('微信验证', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}
