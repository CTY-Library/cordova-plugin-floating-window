//
//  FloatViewController.h
//
//
//  Created by noah on 2022/1/13.
//


#import <UIKit/UIKit.h>


@protocol FloatingWindowPluginCallback <NSObject>
- (void)sendCmd:(NSString *)video_times;
@end

@interface FloatViewController : UIViewController

// Plugin callback reference (set by FloatingWindowPlugin)
@property (nonatomic, weak) id<FloatingWindowPluginCallback> pluginCallBack;

// Allow KVC for supportedOrientations (used by some Cordova orientation handling)
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

- (void) setUpPlayer : (NSString *)video_url i_times_cur:(float )i_times_cur   i_landscape:(NSInteger )i_landscape  i_is_speed:(NSInteger )i_is_speed;

- (void) show;

- (void) close;

@end

