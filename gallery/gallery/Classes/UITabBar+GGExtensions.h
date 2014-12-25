//
//  UITabBar+GGExtensions.h
//  gallery
//
//  Created by Rudd Fawcett on 12/21/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (GGExtensions)

- (NSInteger)itemAtPoint:(CGPoint)point;
- (CGRect)frameForItem:(NSUInteger)index;

@end
