#import <AppKit/AppKit.h>

@protocol PreferenceHost

- (NSString *)nameForPanel;

@optional
- (NSNib *)nibForPanel;
- (NSView *)viewForPanel;

@end