
import 'dart:async';

import 'package:flutter/services.dart';

typedef ResponseHandler = Future<dynamic> Function(Map<String, dynamic> data);

typedef WxHandler = Future<bool> Function(String reqUserName, String reqPath);

class JjcodeFlutterPlugin {
  static const MethodChannel _channel = MethodChannel('jjcode_flutter_plugin');

  static final JjcodeFlutterPlugin _instance = JjcodeFlutterPlugin._internal();
  JjcodeFlutterPlugin._internal() {
    _channel.setMethodCallHandler(_onMethodHandle);
  }
  factory JjcodeFlutterPlugin.getInstance() => _getInstance();

  static _getInstance() {
    return _instance;
  }

  late ResponseHandler _verifyRespHandler;
  late WxHandler _wxHandler;

  Future _onMethodHandle(MethodCall call) async {
    if (call.method == "verifyResponse") {
      return _verifyRespHandler(call.arguments.cast<String, dynamic>());
    } else if (call.method == "wxHandler") {
      var userName = call.arguments["userName"];
      var path = call.arguments["path"];
      return _wxHandler(userName, path);
    }
  }

  void setWxHandler(WxHandler wxHandler) {
    _wxHandler = wxHandler;
  }

  void verify(String mobile, ResponseHandler responseHandler) {
    _verifyRespHandler = responseHandler;
    _channel.invokeMethod("verify", {"mobile": mobile});
  }

  void handleWxResp(String? extMsg) {
    extMsg ??= "";
    _channel.invokeMethod("handleWxResp", {"extMsg": extMsg});
    }
}
