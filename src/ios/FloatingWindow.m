/********* FileUpload.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
 

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
 

@interface FloatingWindow : CDVPlugin {
 
    CDVPluginResult* pluginResult;
}
 

- (void)putObject:(CDVInvokedUrlCommand*)command;
@end

@implementation FileUpload

- (void)pluginInitialize {
    CDVViewController *viewController = (CDVViewController *)self.viewController;
   
}
 


@end
