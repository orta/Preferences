#import <AppKit/AppKit.h>

@protocol ORPreferenceHost

+ (NSString *)titleForPreferences;
+ (NSViewController *)viewControllerForPreferences;

@end