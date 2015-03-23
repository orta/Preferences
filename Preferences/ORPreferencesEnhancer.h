#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface ORPreferencesEnhancer : NSObject

- (void)swizzleWindowDidLoad;

@property (nonatomic, strong, readwrite) NSViewController *preferencesViewController;

@end
