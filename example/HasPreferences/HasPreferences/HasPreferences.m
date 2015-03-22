#import "HasPreferences.h"
#import "ExamplePreferencesViewController.h"

static HasPreferences *sharedPlugin;

@interface HasPreferences()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation HasPreferences

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] init];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

#pragma mark PreferenceHost protocol

+ (NSString *)titleForPreferences
{
    return @"Example Prefs";
}

+ (NSViewController *)viewControllerForPreferences
{
    return [[ExamplePreferencesViewController alloc] initWithNibName:@"ExamplePreferences" bundle:[NSBundle bundleForClass:self]];
}

@end
