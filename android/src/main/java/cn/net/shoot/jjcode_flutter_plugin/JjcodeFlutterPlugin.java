package cn.net.shoot.jjcode_flutter_plugin;

import android.app.Application;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import cn.net.shoot.jijiancodesdk.JJCode;
import cn.net.shoot.jijiancodesdk.VerifyCallback;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/** JjcodeFlutterPlugin */
public class JjcodeFlutterPlugin implements FlutterPlugin, MethodCallHandler {

  private static MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "jjcode_flutter_plugin");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    JJCode.init((Application) context);
  }

  public static void registerWith(PluginRegistry.Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), "sharetrace_flutter_plugin");
    channel.setMethodCallHandler(new JjcodeFlutterPlugin());
    JJCode.init((Application) registrar.context());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("verify")) {
      result.success("call verify method success.");
//      Log.e("JjcodeFlutterPlugin", "verify start... ");
      JJCode.verify(context, call.argument("mobile"), new VerifyCallback() {
        @Override
        public void onSuccess(String mobile, String token) {
//          Log.e("JjcodeFlutterPlugin", "onSuccess....token: " + token);
          if (channel == null){
            return;
          }
//          Log.e("JjcodeFlutterPlugin", "验证完成");

          Map<String, Object> map = new HashMap<>();
          map.put("code", 200);
          map.put("msg", "ok");
          map.put("mobile", mobile);
          map.put("token", token);
          channel.invokeMethod("verifyResponse", map);
        }

        @Override
        public void onFailure(int code, String msg) {
//          Log.e("JjcodeFlutterPlugin", "onFailure....code: " + code);
          if (channel == null){
            return;
          }
//          Log.e("JjcodeFlutterPlugin", "验证失败");
          Map<String, Object> map = new HashMap<>();
          map.put("code", code);
          map.put("msg", msg);
          channel.invokeMethod("verifyResponse", map);
        }
      });
    } else if(call.method.equals("handleWxResp")){
      result.success("call handleWxResp method success.");
      JJCode.handleWXResp(call.argument("extMsg"));
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
