//
//  GGIconCollectionViewCell.m
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import "GGIconCollectionViewCell.h"

@interface GGIconCollectionViewCell ()

@end

@implementation GGIconCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // .60976 is 50 percent on an iPhone 6 when the width of the cell = bounds.width/5.
        // .54878 is 45 percent on an iPhone 6 when the width of the cell = bounds.width/5.
        // .48780 is 40 percent on an iPhone 6 when the width of the cell = bounds.width/5.
        // .36585 is 30 percent on an iPhone 6 when the width of the cell = bounds.width/5.
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*.54878, frame.size.width*.54878)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.center = self.contentView.center;
        [self.contentView addSubview:_imageView];
    }
    
    return self;
}

- (void)addLines:(NSInteger)tag {
    NSLog(@"%ld",(long)tag);
    
    UIView *_lines = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 9)];
    _lines.tag = tag;
    
    UIView *one = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
    one.backgroundColor = [UIColor colorWithRed:0.920 green:0.870 blue:0.910 alpha:1.00];
    
    UIView *two = [[UIView alloc] initWithFrame:CGRectMake(0, 3, self.bounds.size.width, 1)];
    two.backgroundColor = [UIColor colorWithRed:0.920 green:0.870 blue:0.910 alpha:1.00];
    
    UIView *three = [[UIView alloc] initWithFrame:CGRectMake(0, 6, self.bounds.size.width, 1)];
    three.backgroundColor = [UIColor colorWithRed:0.920 green:0.870 blue:0.910 alpha:1.00];
    
    [_lines addSubview:one];
    [_lines addSubview:two];
    [_lines addSubview:three];
    
    _lines.center = self.center;
    
    [self insertSubview:_lines belowSubview:_imageView];
}

- (void)setIcon:(UIImage *)icon {
    _imageView.image = icon;
}

@end
