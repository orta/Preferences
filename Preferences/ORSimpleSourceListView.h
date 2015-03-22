//
//  ORSimpleSourceListView.h
//  GIFs
//
//  Created by orta therox on 20/01/2013.
//  Copyright (c) 2013 Orta Therox. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ORSimpleSourceListView, ORSourceListItem;

@interface NSIndexPath(SourceListExtension)
+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;
- (NSUInteger)row;
- (NSUInteger)section;
@end

@interface ORSourceListHeaderView : NSTableCellView
- (id)initWithTitle:(NSString *)title sourceList:(ORSimpleSourceListView *)sourceList;
@end

@interface ORSourceListItemView : NSTableCellView
- (id)initWithSourceListItem:(ORSourceListItem *)item sourceList:(ORSimpleSourceListView *)sourceList;
@property (assign, nonatomic) BOOL selected;
@property (strong, nonatomic) NSButton *rightImageView;
@end

@interface ORSourceListRowView : NSTableRowView
@end

@interface ORSourceListItem : NSObject
@property (strong) NSString *selectedThumbnail;
@property (strong) NSString *thumbnail;
@property (strong) NSString *title;
@property (strong) NSString *rightButtonImage;
@property (strong) NSString *rightButtonActiveImage;
@end

@protocol ORSourceListDataSource
@required
- (NSUInteger)numberOfSectionsInSourceList:(ORSimpleSourceListView *)sourceList;
- (NSUInteger)sourceList:(ORSimpleSourceListView *)sourceList numberOfRowsInSection:(NSUInteger)section;

- (NSImage *)sourceList:(ORSimpleSourceListView *)sourceList imageForHeaderInSection:(NSUInteger)section;
- (NSString *)sourceList:(ORSimpleSourceListView *)sourceList titleOfHeaderForSection:(NSUInteger)section;
- (ORSourceListItem *)sourceList:(ORSimpleSourceListView *)sourceList sourceListItemForIndexPath:(NSIndexPath *)indexPath;
@end

@protocol ORSourceListDelegate
@optional
- (void)sourceList:(ORSimpleSourceListView *)sourceList selectionDidChangeToIndexPath:(NSIndexPath *)indexPath;
- (void)sourceList:(ORSimpleSourceListView *)sourceList didClickOnRightButtonForIndexPath:(NSIndexPath *)indexPath;
@end


@interface ORSimpleSourceListView : NSTableView <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSObject <ORSourceListDelegate> *sourceListDelegate;
@property (weak) IBOutlet NSObject <ORSourceListDataSource> *sourceListDataSource;

@property (strong) NSColor *selectionColor;
@property (strong) NSColor *textColor;
@property (strong) NSColor *highlightedTextColor;


- (void)setSelectedIndexPath:(NSIndexPath *)indexPath;
- (void)selectDefaultItem;
@end
