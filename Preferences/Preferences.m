#import "Preferences.h"
#import "PreferencesEnhancer.h"

static Preferences *sharedPlugin;

@interface IDEPreferencesController : NSWindowController
@end

@interface Preferences()
@property (nonatomic, strong, readwrite) PreferencesEnhancer *enhancer;
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation Preferences

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    self = [super init];
    if (!self) return nil;

    _bundle = plugin;
    _enhancer = [[PreferencesEnhancer alloc] init];

    [self.enhancer swizzleWindowDidLoad];

    return self;
}

@end
