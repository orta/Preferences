#import "PreferencesEnhancer.h"
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

static PreferencesEnhancer *staticEnhancer;

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

- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)toolbarSelectableItemIdentifiers:(id)arg1;

@end

static NSString* const DMMDerivedDataExterminatorButtonIdentifier = @"me.delisa.DMMDerivedDataExterminator";
static NSString* const DMMDerivedDataExterminatorShowButtonInTitleBar = @"DMMDerivedDataExterminatorShowButtonInTitleBar";

@implementation PreferencesEnhancer

- (void)swizzleWindowDidLoad
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticEnhancer = self;

        Class prefs = NSClassFromString(@"IDEPreferencesController");
        for (NSString *selector in @[@"windowDidLoad", @"toolbarAllowedItemIdentifiers:", @"toolbarDefaultItemIdentifiers:", @"toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:"]) {
            SEL originalSelector = NSSelectorFromString(selector);
            SEL newSelector = NSSelectorFromString([@"swizzled_preferences_" stringByAppendingString:selector]);
            [self swizzleClass:prefs originalSelector:originalSelector swizzledSelector:newSelector instanceMethod:YES];
        }

        //        [self swizzleClass:prefs originalSelector:@selector(windowDidLoad) swizzledSelector:@selector(swizzled_preferences_windowDidLoad) instanceMethod:YES];
//        [self swizzleClass:prefs originalSelector:@selector(toolbarAllowedItemIdentifiers:) swizzledSelector:@selector(swizzled_preferences_toolbarAllowedItemIdentifiers:) instanceMethod:YES];
//        [self swizzleClass:prefs originalSelector:@selector(toolbarDefaultItemIdentifiers:) swizzledSelector:@selector(swizzled_preferences_toolbarDefaultItemIdentifiers:) instanceMethod:YES];
//        [self swizzleClass:prefs originalSelector:@selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:) swizzledSelector:@selector(swizzled_preferences_toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:) instanceMethod:YES];


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
    NSRect frame = [controller.window frame];
    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width + additionalWidth, frame.size.height);
    [controller.window setFrame:newFrame display:YES animate:NO];
}

- (void)setupToolbarForWindowController:(NSWindowController *)controller
{
    NSObject<NSToolbarDelegate> *delegate = controller.window.toolbar.delegate;
    NSArray *allowedIdentifiers = [delegate toolbarAllowedItemIdentifiers:nil];
    id manager = [NSClassFromString(@"DVTPlugInManager") defaultPlugInManager];

    
    NSString *bundleID = [[NSBundle bundleForClass:self.class] bundleIdentifier];
        id other = [manager plugInWithIdentifier:bundleID];

//    [controller toolbar:controller.window.toolbar itemForItemIdentifier:bundleID willBeInsertedIntoToolbar:YES];

//    NSMutableDictionary *providers = [delegate toolbarItemProviders].mutableCopy;
//    if (![allowedIdentifiers containsObject:DMMDerivedDataExterminatorButtonIdentifier]) {
//        allowedIdentifiers = [allowedIdentifiers arrayByAddingObject:DMMDerivedDataExterminatorButtonIdentifier];
//        providers[DMMDerivedDataExterminatorButtonIdentifier] = self;
//        [delegate setValue:allowedIdentifiers forKey:@"_allowedItemIdentifiers"];
//        [delegate setValue:providers forKey:@"_toolbarItemProviders"];
//    }

}

- (void)insertToolbarButtonForWindow:(NSWindow*)window
{
    for (NSToolbarItem *item in window.toolbar.items) {
        if ([item.itemIdentifier isEqualToString:DMMDerivedDataExterminatorButtonIdentifier])
            return;
    }

    NSInteger index = MAX(0, window.toolbar.items.count - 1);
    [window.toolbar insertItemWithItemIdentifier:DMMDerivedDataExterminatorButtonIdentifier atIndex:index];
}


- (NSToolbarItem *)toolbarItemForPreferences
{
    Class DVTViewControllerToolbarItem = NSClassFromString(@"DVTViewControllerToolbarItem");
    NSToolbarItem *settingsItem = (NSToolbarItem *)[[DVTViewControllerToolbarItem alloc] initWithItemIdentifier:DMMDerivedDataExterminatorButtonIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSImage *image = [[NSImage alloc] initByReferencingFile:[bundle pathForResource:@"toolbar_icon" ofType:@"png"]];
    image.template = YES;

    settingsItem.target = self;
    settingsItem.action = @selector(showPluginMenu);

    settingsItem.toolTip = @"Settings for Plugins";
    settingsItem.label = @"Plugins";
    return settingsItem;
}

- (void)showPluginMenu
{

}

@end


@implementation NSObject (PreferencesSwizzling)

- (void)swizzled_preferences_windowDidLoad;
{
    // Call the original first
    [self swizzled_preferences_windowDidLoad];

    NSWindowController *this = (id)self;
    [staticEnhancer resizeWindowForWindowController:this];
    [staticEnhancer setupToolbarForWindowController:this];
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

- (NSToolbarItem *)swizzled_preferences_toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSString *bundleID = [[NSBundle bundleForClass:staticEnhancer.class] bundleIdentifier];
    if ([itemIdentifier isEqualToString:bundleID]) {
        return [staticEnhancer toolbarItemForPreferences];
    }
    return [self swizzled_preferences_toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
}

@end
