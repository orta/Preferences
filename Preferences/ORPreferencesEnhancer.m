#import "ORPreferencesEnhancer.h"
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import "ORPreferencesEditorViewController.h"

static ORPreferencesEnhancer *staticEnhancer;

@interface NSObject (DVTViewControllerToolbarItem)

// https://github.com/neonichu/Xcode-RuntimeHeaders/blob/144b1f250454dbac6886360857fa840e3d1b6ad7/DevToolsCore/XCPluginManager.h

+ (id)defaultPlugInManager;
- (id)plugInWithIdentifier:(id)arg1;

// https://github.com/neonichu/Xcode-RuntimeHeaders/blob/master/DVTFoundation/DVTExtension.h

+ (instancetype)alloc;
- (id)initWithItemIdentifier:(NSString*)identifier;
- (NSArray *)allowedItemIdentifiers;
- (NSDictionary *)toolbarItemProviders;

// https://github.com/larsxschneider/ShowInGitHub/blob/master/Source/Libraries/XcodeFrameworks/IDEKit/IDEPreferencesController.h

+ (id)defaultPreferencesController;
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)toolbarSelectableItemIdentifiers:(id)arg1;

@end

static NSString* const DMMDerivedDataExterminatorButtonIdentifier = @"me.delisa.DMMDerivedDataExterminator";
static NSString* const DMMDerivedDataExterminatorShowButtonInTitleBar = @"DMMDerivedDataExterminatorShowButtonInTitleBar";

@implementation ORPreferencesEnhancer

- (void)swizzleWindowDidLoad
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticEnhancer = self;

        Class prefs = NSClassFromString(@"IDEPreferencesController");
        NSArray *selectors = @[@"windowDidLoad",
                               @"toolbarAllowedItemIdentifiers:",
                               @"toolbarDefaultItemIdentifiers:",
                               @"toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:",
                               @"toolbarSelectableItemIdentifiers:",
                               @"selectPreferencePaneWithIdentifier:"];

        for (NSString *selector in selectors) {
            SEL originalSelector = NSSelectorFromString(selector);
            SEL newSelector = NSSelectorFromString([@"swizzled_preferences_" stringByAppendingString:selector]);
            [self swizzleClass:prefs originalSelector:originalSelector swizzledSelector:newSelector instanceMethod:YES];
        }
    });
}

- (void)swizzleClass:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector instanceMethod:(BOOL)instanceMethod
{
    if (class) {
        Method originalMethod;
        Method swizzledMethod;
        if (instanceMethod) {
            originalMethod = class_getInstanceMethod(class, originalSelector);
            swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        } else {
            originalMethod = class_getClassMethod(class, originalSelector);
            swizzledMethod = class_getClassMethod(class, swizzledSelector);
        }

        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

- (void)resizeWindowForWindowController:(NSWindowController *)controller
{
    CGFloat additionalWidth = 60;
    CGSize fixedSize = CGSizeMake(controller.window.minSize.height, controller.window.minSize.width + additionalWidth);
    [controller.window setMinSize:fixedSize];
}

- (NSToolbarItem *)toolbarItemForPreferences
{
    Class DVTViewControllerToolbarItem = NSClassFromString(@"DVTViewControllerToolbarItem");
    NSToolbarItem *settingsItem = (NSToolbarItem *)[[DVTViewControllerToolbarItem alloc] initWithItemIdentifier:DMMDerivedDataExterminatorButtonIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSImage *image = [[NSImage alloc] initByReferencingFile:[bundle pathForResource:@"toolbar_icon" ofType:@"png"]];

    settingsItem.target = self;
    settingsItem.action = @selector(showPluginMenu:);

    settingsItem.toolTip = @"Settings for Plugins";
    settingsItem.label = @"Plugins";
    settingsItem.image = image;

    return settingsItem;
}

- (void)showPluginMenu:(NSToolbarItem *)item
{
    if (!self.preferencesViewController) {
        self.preferencesViewController = (id)[[ORPreferencesEditorViewController alloc] init];
    }

    NSWindow *window = [self.preferencesWindowController window];
    CGFloat windowHeight = 560;

    CGRect newFrame = CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, windowHeight);
    [window setFrame:newFrame display:NO animate:YES];

    for (NSView *view in [window.contentView subviews]) {
        [view setHidden:YES];
    }
    [window.contentView addSubview:self.preferencesViewController.view];
}

- (void)removePluginView
{
    [self.preferencesViewController.view removeFromSuperview];
}

- (NSWindowController *)preferencesWindowController
{
    return [NSClassFromString(@"IDEPreferencesController") defaultPreferencesController];
}

@end


@implementation NSObject (PreferencesSwizzling)

- (void)swizzled_preferences_windowDidLoad;
{
    // Call the original first
    [self swizzled_preferences_windowDidLoad];

    NSWindowController *this = (id)self;
    [staticEnhancer resizeWindowForWindowController:this];
}

- (id)swizzled_preferences_toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    NSArray *results = [self swizzled_preferences_toolbarAllowedItemIdentifiers:toolbar];
    NSString *bundleID = [[NSBundle bundleForClass:staticEnhancer.class] bundleIdentifier];
    return [results arrayByAddingObject:bundleID];
}

- (id)swizzled_preferences_toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    NSArray *results = [self swizzled_preferences_toolbarDefaultItemIdentifiers:toolbar];
    NSString *bundleID = [[NSBundle bundleForClass:staticEnhancer.class] bundleIdentifier];
    return [results arrayByAddingObject:bundleID];
}

- (id)swizzled_preferences_toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    NSArray *results = [self swizzled_preferences_toolbarSelectableItemIdentifiers:toolbar];
    NSString *bundleID = [[NSBundle bundleForClass:staticEnhancer.class] bundleIdentifier];
    return [results arrayByAddingObject:bundleID];
}

- (void)swizzled_preferences_selectPreferencePaneWithIdentifier:(NSString *)identifier
{
    [staticEnhancer removePluginView];
    [self swizzled_preferences_selectPreferencePaneWithIdentifier:identifier];
}

- (NSToolbarItem *)swizzled_preferences_toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSString *bundleID = [[NSBundle bundleForClass:staticEnhancer.class] bundleIdentifier];
    if ([itemIdentifier isEqualToString:bundleID]) {
        return [staticEnhancer toolbarItemForPreferences];
    }
    return [self swizzled_preferences_toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
}

@end
