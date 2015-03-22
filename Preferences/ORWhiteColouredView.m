#import "ORWhiteColouredView.h"

@implementation ORWhiteColouredView

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
