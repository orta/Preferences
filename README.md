# Add preferences for your Xcode plugins.

![Screenshot](https://raw.github.com/orta/Preferences/master/web/screenshot.png)


Currently in Developer release, if you would like to add support for your plugin, you need to:

Add support for this protocol to one of the classes in your plugin

```objc
#import <AppKit/AppKit.h>

@protocol ORPreferenceHost

+ (NSString *)titleForPreferences;
+ (NSViewController *)viewControllerForPreferences;

@end
```

and return a view controller, currently the view frame is 500 by 440. If you'd like to check if someone has the plugin installed, see if  `NSClassFromString(@"ORPreferencesEnhancer")` returns something.


### Installation


```
git clone https://github.com/orta/Preferences.git
cd Preferences
xcodebuild
```

Then restart Xcode.

### Example

There is an example plugin which has support for Preferences in the example folder.

