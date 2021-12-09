# jjcode_flutter_plugin

### 集成前必读：

由于微信小程序和APP交互的限制，APP调起小程序要求APP必须在微信开放平台已经认证，如果没有认证无法调起微信小程序，集成前请先前往[微信开放平台](https://open.weixin.qq.com/)进行认证。如果已经集成过微信登录、微信支付或者微信的分享则可以直接使用。

### 一、安装

#### 1.1 添加依赖

在项目的pubspec.yaml文件中添加以下内容:

``` xml
dependencies:
  jjcode_flutter_plugin: ^1.0.0
```

#### 1.2 安装

通过命令行安装

```cmd
flutter pub get
```

### 二、配置

#### Android配置
找到项目的`AndroidManifest.xml`文件，在`<application>...</application>`中增加以下配置

```xml
<meta-data
  android:name="com.jijiancode.APP_ID"
  android:value="[极简验证APP_ID]"/>
<meta-data
  android:name="com.jijiancode.WX_APP_ID"
  android:value="[微信开放平台APP_ID]"/>
```

#### iOS配置
在Info.plist中增加以下配置

```xml
<key>com.jijiancode.APP_ID</key>
<string> [极简验证APP_ID] </string>
<key>com.jijiancode.WX_APP_ID</key>
<string> [微信开放平台APP_ID] </string>
```

### 三、接口调用

这里假设当前Flutter应用使用[fluwx](https://pub.dev/packages/fluwx)来集成WechatSDK。

#### 3.1. 导入接口定义

```dart
import 'package:jjcode_flutter_plugin/jjcode_flutter_plugin.dart';
```

#### 3.2. 插件配置和接口调用

```dart
import 'package:fluwx/fluwx.dart' as fluwx;

class _MyAppState extends State<MyApp> {
    late JjcodeFlutterPlugin _jjcodeFlutterPlugin;
    @override
    void initState() {
        super.initState();
        // 1. 初始化WechatSDK
        _initFluwx();
        initPlatformState();
    }

    _initFluwx() async {
        await fluwx.registerWxApi(
            appId: "wx5224379xxxxxxx",
            doOnAndroid: true,
            doOnIOS: true,
            universalLink: "https://wwww.xxxxxx.com/ulink/");
    }

    Future<void> initPlatformState() async {
      if (!mounted) return;

      // 2. 初始化JjcodeFlutterPlugin
      _jjcodeFlutterPlugin = JjcodeFlutterPlugin.getInstance();
      _jjcodeFlutterPlugin.setWxHandler(wxHandler);

      // 3. 监听微信小程序结果回调
      fluwx.weChatResponseEventHandler.listen((res) {
        if (res is fluwx.WeChatLaunchMiniProgramResponse) {
          if (mounted) {
            var extMsg = res.extMsg;
            _jjcodeFlutterPlugin.handleWxResp(extMsg);
          }
        }
      });
    }

    // 4. 定义wxHandler方法实现，用于桥接当前WechatSDK实现
    Future<bool> wxHandler(String reqUserName, String reqPath) async {
        return fluwx.launchWeChatMiniProgram(username: reqUserName, path: reqPath);
    }

    // 5. 定义verify 接口回调
    Future responseHandler(Map<String, dynamic> data) async {
        setState(() {
          result = "verify result: \n\n"
              + "code= " + data['code'].toString() + "\n"
              + "msg= " + data['msg'].toString() + "\n";
        });
    }
}
```


