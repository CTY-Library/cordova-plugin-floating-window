// UIViewController+SupportedOrientations.m

#import "UIViewController+SupportedOrientations.h"
#import <objc/runtime.h>

static const char *kSupportedOrientationsKey = "kSupportedOrientationsKey";

@implementation UIViewController (SupportedOrientations)

- (void)setSupportedOrientations:(UIInterfaceOrientationMask)supportedOrientations {
    objc_setAssociatedObject(self, kSupportedOrientationsKey, @(supportedOrientations), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIInterfaceOrientationMask)supportedOrientations {
    NSNumber *n = objc_getAssociatedObject(self, kSupportedOrientationsKey);
    if (n) return (UIInterfaceOrientationMask)[n unsignedIntegerValue];
    return UIInterfaceOrientationMaskAll;
}

@end
