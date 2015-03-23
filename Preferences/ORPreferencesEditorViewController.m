#import "ORPreferencesEditorViewController.h"
#import "PreferencesProtocol.h"
#import <objc/runtime.h>

@interface ORPreferencesEditorViewController()
@property (nonatomic, copy, readonly) NSArray *supportedClasses;
@property (nonatomic, strong, readwrite) NSViewController *currentViewController;
@end

@implementation ORPreferencesEditorViewController

- (instancetype)init
{
    self = [self initWithNibName:@"PreferencesMenu" bundle:[NSBundle bundleForClass:self.class]];
    if (!self) return nil;

    _supportedClasses = [self classesThatConformToPreferencesProtocol];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.sourceList setSelectedIndexPath:path];
}

- (NSUInteger)numberOfSectionsInSourceList:(ORSimpleSourceListView *)sourceList
{
    return 1;
}

- (NSUInteger)sourceList:(ORSimpleSourceListView *)sourceList numberOfRowsInSection:(NSUInteger)section
{
    return self.supportedClasses.count;
}

- (NSImage *)sourceList:(ORSimpleSourceListView *)sourceList imageForHeaderInSection:(NSUInteger)section
{
    return nil;
}

- (NSString *)sourceList:(ORSimpleSourceListView *)sourceList titleOfHeaderForSection:(NSUInteger)section
{
    return @"Supported Plugins";
}

- (ORSourceListItem *)sourceList:(ORSimpleSourceListView *)sourceList sourceListItemForIndexPath:(NSIndexPath *)indexPath
{
    Class <ORPreferenceHost> class = NSClassFromString(self.supportedClasses[indexPath.row]);

    ORSourceListItem *item = [[ORSourceListItem alloc] init];
    item.title = [class titleForPreferences];
    return item;
}

- (void)sourceList:(ORSimpleSourceListView *)sourceList selectionDidChangeToIndexPath:(NSIndexPath *)indexPath
{
    [self.currentViewController removeFromParentViewController];
    [self.currentViewController.view removeFromSuperview];

    Class <ORPreferenceHost> class = NSClassFromString(self.supportedClasses[indexPath.row]);
    self.currentViewController = [class viewControllerForPreferences];

    [self addChildViewController:self.currentViewController];
    self.currentViewController.view.frame = self.hostedView.bounds;
    [self.hostedView addSubview:self.currentViewController.view];
}

- (NSArray *)classesThatConformToPreferencesProtocol
{
    // Thanks Specta

    NSMutableArray *allClasses = [NSMutableArray array];

    int numberOfClasses = objc_getClassList(NULL, 0);
    if (numberOfClasses > 0) {
        Class *classes = (Class *)malloc(sizeof(Class) *numberOfClasses);
        numberOfClasses = objc_getClassList(classes, numberOfClasses);

        for(int classIndex = 0; classIndex < numberOfClasses; classIndex++) {
            Class aClass = classes[classIndex];

            if (class_conformsToProtocol(aClass, @protocol(ORPreferenceHost)) == YES) {
                [allClasses addObject:NSStringFromClass(aClass)];
            }
        }
        
        free(classes);
    }

    return [NSArray arrayWithArray:allClasses];
}

@end
