//
//  UITabBar+GGExtensions.m
//  gallery
//
//  Created by Rudd Fawcett on 12/21/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import "UITabBar+GGExtensions.h"

@implementation UITabBar (GGExtensions)

- (NSInteger)itemAtPoint:(CGPoint)point {
    int eachWidth = self.bounds.size.width/self.items.count;
    
    for (int i = 0; i <= self.items.count; i++) {
        CGRect itemFrame = CGRectMake(i*eachWidth, self.frame.origin.y, eachWidth, self.frame.size.height);
        
        if (CGRectContainsPoint(itemFrame, point)) {
            return i;
        }
    }
    
    return 0;
}

@end
