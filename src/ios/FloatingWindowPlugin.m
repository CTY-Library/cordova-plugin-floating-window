/********* FloatingWindowPlugin.m Cordova Plugin Implementation *******/
 
#import <Cordova/CDV.h>
  
#import <AVKit/AVKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

#import "FloatViewController.h"


@interface FloatingWindowPlugin : CDVPlugin {
    NSString *urlString;
    float times_cur; //毫秒，跳转到当前时间播放
    NSInteger landscape; //1横屏 ， 0竖屏
    NSInteger is_speed; //1可以快进
}
@property (nonatomic ,strong) NSString *callback_cur;
//@property (nonatomic ,strong) CDVPluginResult *pluginResult;
@property (nonatomic ,strong) FloatViewController *floatv1;

- (void)show:(CDVInvokedUrlCommand*)command;
- (void)get:(CDVInvokedUrlCommand*)command;
- (void)close:(CDVInvokedUrlCommand*)command;
@end

@implementation FloatingWindowPlugin

static NSString* myAsyncCallBackId = nil;
static CDVPluginResult *pluginResult = nil;
static FloatingWindowPlugin *selfplugin = nil;

- (void)pluginInitialize {
    _floatv1 = [[FloatViewController alloc] init];
}

- (void)show:(CDVInvokedUrlCommand *)command
{
    selfplugin = self;
    urlString = [command.arguments objectAtIndex:0];
    NSString *str_times_cur = [command.arguments objectAtIndex:1];
    NSString *str_landscape = [command.arguments objectAtIndex:2];
    NSString *str_is_speed = [command.arguments objectAtIndex:3];
    times_cur =  [str_times_cur  floatValue];
    landscape = [str_landscape integerValue];
    is_speed = [str_landscape integerValue];
    
    [self.floatv1 viewDidLoad];
    [self.floatv1 setUpPlayer:urlString i_times_cur:times_cur i_landscape:landscape i_is_speed:is_speed];

 
    myAsyncCallBackId = command.callbackId;
    pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId: command.callbackId];
}

-  (void)  sendCmd : (NSString *)video_times
{
    if(myAsyncCallBackId != nil)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: video_times ];
        //将 CDVPluginResult.keepCallback 设置为 true ,则不会销毁callback
        [pluginResult  setKeepCallbackAsBool:YES];
        [selfplugin.commandDelegate sendPluginResult:pluginResult callbackId: myAsyncCallBackId];

    }
}

- (void)get:(CDVInvokedUrlCommand *)command
{
    selfplugin = self;
    [self.floatv1 show];
    
    myAsyncCallBackId = command.callbackId;
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"-1" ];
    [pluginResult setKeepCallbackAsBool:YES]; //将 CDVPluginResult.keepCallback 设置为 true ,则不会销毁callback
    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
 
    
}
 

- (void)close:(CDVInvokedUrlCommand *)command
{
    selfplugin = self;
    
    [self.floatv1 close];
    
    myAsyncCallBackId = command.callbackId;
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT ];
    [pluginResult setKeepCallbackAsBool:YES]; //将 CDVPluginResult.keepCallback 设置为 true ,则不会销毁callback
    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
 
}
 
@end

