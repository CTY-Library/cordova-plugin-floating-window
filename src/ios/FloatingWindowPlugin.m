/********* FloatingWindowPlugin.m Cordova Plugin Implementation *******/
 
#import <Cordova/CDV.h>
  
#import <AVKit/AVKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

#import "FloatViewController.h"


@interface FloatingWindowPlugin : CDVPlugin {
    NSString *urlString;
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
     urlString = [command.arguments objectAtIndex:0];
    
    [self.floatv1 viewDidLoad];
    [self.floatv1 setUpPlayer:urlString];

 
    myAsyncCallBackId = command.callbackId;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT  ];
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
     
}
 
@end
