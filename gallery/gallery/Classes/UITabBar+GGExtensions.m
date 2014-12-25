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

- (CGRect)frameForItem:(NSUInteger)index {
    NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:[self.items count]];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIControl class]] && [view respondsToSelector:@selector(frame)]) {
            // check for the selector -frame to prevent crashes in the very unlikely case that in the future
            // objects thar don't implement -frame can be subViews of an UIView
            [tabBarItems addObject:view];
        }
    }
    if ([tabBarItems count] == 0) {
        // no tabBarItems means either no UITabBarButtons were in the subView, or none responded to -frame
        // return CGRectZero to indicate that we couldn't figure out the frame
        return CGRectZero;
    }
    
    // sort by origin.x of the frame because the items are not necessarily in the correct order
    [tabBarItems sortUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        if (view1.frame.origin.x < view2.frame.origin.x) {
            return NSOrderedAscending;
        }
        if (view1.frame.origin.x > view2.frame.origin.x) {
            return NSOrderedDescending;
        }
        NSAssert(NO, @"%@ and %@ share the same origin.x. This should never happen and indicates a substantial change in the framework that renders this method useless.", view1, view2);
        return NSOrderedSame;
    }];
    
    CGRect frame = CGRectZero;
    if (index < [tabBarItems count]) {
        // viewController is in a regular tab
        UIView *tabView = tabBarItems[index];
        if ([tabView respondsToSelector:@selector(frame)]) {
            frame = tabView.frame;
        }
    }
    else {
        // our target viewController is inside the "more" tab
        UIView *tabView = [tabBarItems lastObject];
        if ([tabView respondsToSelector:@selector(frame)]) {
            frame = tabView.frame;
        }
    }
    
    return frame;
}

@end
