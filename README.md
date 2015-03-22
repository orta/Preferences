# Preference support for your plugins.

![Screenshot](https://raw.github.com/orta/Preferences/master/web/screenshot.png)


Currently in Developer release, if you would like to add support for your plugin, you need to:

Add support for this protocol to one of the classes in your plugin

```objc
#import <AppKit/AppKit.h>

@protocol PreferenceHost

+ (NSString *)titleForPreferences;
+ (NSViewController *)viewControllerForPreferences;

@end
```

and return a view controller, currently the view frame is 500 by 440.

