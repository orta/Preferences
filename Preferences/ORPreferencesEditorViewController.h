#import <Cocoa/Cocoa.h>
#import "ORSimpleSourceListView.h"

@interface ORPreferencesEditorViewController : NSViewController <ORSourceListDelegate, ORSourceListDataSource>

@property (weak) IBOutlet ORSimpleSourceListView *sourceList;
@property (weak) IBOutlet NSView *hostedView;

@end
