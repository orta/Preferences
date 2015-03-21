#import "PreferencesEnhancer.h"
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

@class IDEPreferencesController;

//@interface IDEPreferencesController(PreferencesSwizzling)
//- (void)swizzled_preferences_windowDidLoad;
//@end
//
//@implementation IDEPreferencesController (PreferencesSwizzling)
//
//- (void)swizzled_preferences_windowDidLoad;
//{
//    // Call the original first
//    [self swizzled_preferences_windowDidLoad];
//
//}
//@end

@implementation PreferencesEnhancer

- (void)swizzleWindowDidLoad
{
    Class oldClass = NSClassFromString(@"IDEPreferencesController");

    SEL oldSel = @selector(windowDidLoad);
    SEL newSel =  @selector(swizzled_preferences_windowDidLoad);

    Method oldMethod = class_getInstanceMethod(oldClass, oldSel);
    Method newMethod = class_getInstanceMethod(oldClass, newSel);

    if (class_addMethod(oldClass, oldSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(oldClass, newSel, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

@end
