//
//  FloatViewController.h
//
//
//  Created by noah on 2022/1/13.
//

#import <UIKit/UIKit.h>

@interface FloatViewController : UIViewController

- (void) viewDidLoad;

- (void) setUpPlayer : (NSString *)video_url i_times_cur:(float )i_times_cur   i_landscape:(NSInteger )i_landscape  i_is_speed:(NSInteger )i_is_speed;

- (void) show;

- (void) close;

@end

