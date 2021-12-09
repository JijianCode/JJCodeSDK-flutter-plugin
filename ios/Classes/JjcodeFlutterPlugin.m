#import "JjcodeFlutterPlugin.h"
#import "JJCode.h"

@interface JjcodeFlutterPlugin ()<JJCodeDelegate>

@property (strong, nonatomic) FlutterMethodChannel * flutterMethodChannel;

@end

@implementation JjcodeFlutterPlugin

static NSString * const key_code = @"code";
static NSString * const key_msg = @"msg";
static NSString * const key_mobile = @"mobile";
static NSString * const key_token = @"token";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
      FlutterMethodChannel* channel = [FlutterMethodChannel
                                           methodChannelWithName:@"jjcode_flutter_plugin"
                                           binaryMessenger:[registrar messenger]];

     JjcodeFlutterPlugin* instance = [[JjcodeFlutterPlugin alloc] init];
     [registrar addApplicationDelegate:instance];
     instance.flutterMethodChannel = channel;
     [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [JJCode startInit:self];
    }
    return self;
}

- (void)jjCodeDidLaunchMiniProgram:(NSString *)reqUserName
                           reqPath:(NSString *)reqPath
                     reqCompletion:(void (^)(BOOL))reqCompletion {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"userName"] = reqUserName;
    dict[@"path"] = reqPath;
    [self.flutterMethodChannel invokeMethod:@"wxHandler" arguments:dict result:^(id  _Nullable result) {
        if (result == nil) {
            reqCompletion(NO);
        } else {
            reqCompletion(YES);
        }
    }];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"verify" isEqualToString:call.method]) {
        NSString* phone = @"";
        if (call.arguments != nil) {
            id mobile = call.arguments[@"mobile"];
            if (mobile != nil && [mobile isKindOfClass:[NSString class]]) {
                phone = (NSString*)mobile;
            }
        }
        
        [JJCode verify:phone success:^(NSString * _Nonnull mobile, NSString * _Nonnull token) {
            NSDictionary *ret = [JjcodeFlutterPlugin parseToResultDict:200 :@"ok" :mobile :token];
            [self response:ret];
        } fail:^(NSInteger code, NSString * _Nonnull message) {
            NSDictionary *ret = [JjcodeFlutterPlugin parseToResultDict:code :message :nil :nil];
            [self response:ret];
        }];
        
    } else if ([@"handleWxResp" isEqualToString:call.method]) {
        NSString* extMsg = @"";
        if (call.arguments != nil) {
            id extMsgParams = call.arguments[@"extMsg"];
            if (extMsgParams != nil && [extMsgParams isKindOfClass:[NSString class]]) {
                extMsg = (NSString*)extMsgParams;
            }
        }
        [JJCode handleWXResp:extMsg];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)response:(NSDictionary *) ret {
    [self.flutterMethodChannel invokeMethod:@"verifyResponse" arguments:ret];
}

+ (NSDictionary*)parseToResultDict:(NSInteger)code :(NSString*)msg :(NSString*)mobile :(NSString*)token {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[key_code] = [NSNumber numberWithInteger:code];
    dict[key_msg] = msg;
    if (mobile != nil) {
        dict[key_mobile] = mobile;
    }
    if (token != nil) {
        dict[key_token] = token;
    }

    return dict;
}


- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
    [JJCode handleSchemeLinkURL:url];
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [JJCode handleSchemeLinkURL:url];
    return NO;
}

- (BOOL)application:(UIApplication*)application continueUserActivity:(NSUserActivity*)userActivity restorationHandler:(void (^)(NSArray*))restorationHandler {
    [JJCode handleUniversalLink:userActivity];
    return NO;
}

@end
