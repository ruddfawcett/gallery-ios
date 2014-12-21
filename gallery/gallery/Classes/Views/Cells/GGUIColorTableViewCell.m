//
//  GGUIColorTableViewCell.m
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import "GGUIColorTableViewCell.h"

@implementation GGUIColorTableViewCell

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
    return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor colorWithRed:0.239 green:0.271 blue:0.302 alpha:1.00];
        self.textLabel.textColor = [UIColor whiteColor];
        
        [self setUpPalettes];
        
        UIView *selectedColor = [UIView new];
        selectedColor.backgroundColor = [UIColor colorWithRed:0.317 green:0.358 blue:0.400 alpha:1.00];
        
        self.selectedBackgroundView = selectedColor;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(36, 0, self.contentView.bounds.size.width-36, self.contentView.bounds.size.height);
}

- (void)setUpPalettes {
    UIView *left = [self palleteWithColors:@[[UIColor whiteColor], [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.00]]];
    
    [self.contentView addSubview:left];

    CGRect newFrame = left.frame;
    newFrame.origin.x += newFrame.size.width+15;
    
    UIView *center = [self palleteWithColors:@[[UIColor colorWithRed:0.525 green:0.573 blue:0.624 alpha:1.00], [UIColor colorWithRed:0.451 green:0.490 blue:0.529 alpha:1.00]]];
    center.frame = newFrame;
    
    [self.contentView addSubview:center];
    
    newFrame.origin.x += newFrame.size.width+15;
    
    UIView *right = [self palleteWithColors:@[[UIColor colorWithRed:0.161 green:0.180 blue:0.200 alpha:1.00], [UIColor colorWithRed:0.122 green:0.137 blue:0.153 alpha:1.00]]];
    right.frame = newFrame;
    
    [self.contentView addSubview:right];
}

- (UIView *)palleteWithColors:(NSArray *)colors {
    UIView *pallete = [[UIView alloc] initWithFrame:CGRectMake(110, 14, 16, 16)];
    
    UIView *leftColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 16)];
    leftColor.backgroundColor = colors[0];
    leftColor = [self roundCornersOnView:leftColor onTopLeft:YES topRight:NO bottomLeft:YES bottomRight:NO radius:10];
    
    UIView *rightColor = [[UIView alloc] initWithFrame:CGRectMake(leftColor.bounds.size.width, 0, 8, 16)];
    rightColor.backgroundColor = colors[1];
    rightColor = [self roundCornersOnView:rightColor onTopLeft:NO topRight:YES bottomLeft:NO bottomRight:YES radius:10];
    
    [pallete addSubview:leftColor];
    [pallete addSubview:rightColor];
    
    return pallete;
}

- (UIView *)roundCornersOnView:(UIView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius {
    
    
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0; //holds the corner
        //Determine which corner(s) should be changed
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }
        
        UIView *roundedView = view;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(view.bounds.size.height/2, view.bounds.size.height/2)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = roundedView.bounds;
        maskLayer.path = maskPath.CGPath;
        roundedView.layer.mask = maskLayer;
        return roundedView;
    }
    
    return view;
}

@end
