#import <AppKit/AppKit.h>

@protocol PreferenceHost

+ (NSString *)titleForPreferences;
+ (NSViewController *)viewControllerForPreferences;

@end