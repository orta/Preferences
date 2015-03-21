//
//  Preferences.h
//  Preferences
//
//  Created by Orta on 21/03/2015.
//  Copyright (c) 2015 orta therox. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface Preferences : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end