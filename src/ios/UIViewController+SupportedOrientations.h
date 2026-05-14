// UIViewController+SupportedOrientations.h
// Provide a KVC-compliant supportedOrientations property for Cordova

#import <UIKit/UIKit.h>

@interface UIViewController (SupportedOrientations)

@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

@end
