#import <AppKit/AppKit.h>
#import "PreferencesProtocol.h"

@interface HasPreferences : NSObject <PreferenceHost>

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end