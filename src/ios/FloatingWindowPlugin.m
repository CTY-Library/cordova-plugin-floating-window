/********* FileUpload.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
  
#import <AVKit/AVKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

@interface FloatingWindowPlugin : CDVPlugin {
    NSString *urlString;
    NSInt *callback;
    CDVPluginResult* pluginResult;
}
 
@property(nonatomic,strong) AVPlayer * player;

@property (weak, nonatomic) IBOutlet UIView *playerView;

@property(nonatomic,strong) AVPictureInPictureController * picController;


- (void)putObject:(CDVInvokedUrlCommand*)command;
@end

@implementation FloatingWindowPlugin

- (void)pluginInitialize {
    CDVViewController *viewController = (CDVViewController *)self.viewController;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)show:(CDVInvokedUrlCommand *)command
{
     urlString = [command.arguments objectAtIndex:0];
     [self setUpPlayer];

    if (self.picController.isPictureInPicturePossible) {
        [self.picController startPictureInPicture];
    }
    else
    {
        NSLog(@"picture is not possible");
    }

  
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:successDictionary];

     //将 CDVPluginResult.keepCallback 设置为 true ,则不会销毁callback
    [pluginResult setKeepCallbackAsBool:YES];

    [self.plugin.commandDelegate sendPluginResult:pluginResult callbackId:self.callback];//主动回调给JS


}

- (void)setUpPlayer
{ 
    AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:urlString]]; 
    self.player = [AVPlayer playerWithPlayerItem:item];
    AVPlayerLayer * layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = self.playerView.bounds;
    layer.backgroundColor = [UIColor blueColor].CGColor;
    NSLog(@"%@",NSStringFromCGRect(self.view.bounds));
    [self.playerView.layer addSublayer:layer];

    NSLog(@"---------------%@",NSStringFromCGRect(layer.bounds));

    self.picController = [[AVPictureInPictureController alloc] initWithPlayerLayer:layer];
    self.picController.delegate = self;
    [self.player play];

} 


- (void)get:(CDVInvokedUrlCommand *)command
{
    
}

- (void)close:(CDVInvokedUrlCommand *)command
{
     [self.picController stopPictureInPicture];
}

#pragma mark - delegate

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    
}


- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    
}


- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error
{
    NSLog(@"%@",error);
}


- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler
{
    
}



@end
