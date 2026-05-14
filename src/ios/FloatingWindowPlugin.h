//
//  ViewController.h
//  FDPictureInPicture
//
//  Created by noah on 2022/1/13.
//

#import <Cordova/CDV.h>

@interface FloatingWindowPlugin : CDVPlugin

- (void) sendCmd : (NSString *)video_times;

@end

