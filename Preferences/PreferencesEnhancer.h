#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface PreferencesEnhancer : NSObject

- (void)swizzleWindowDidLoad;

@property (nonatomic, strong, readwrite) NSViewController *preferencesViewController;

@end
