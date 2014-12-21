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
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.center = self.contentView.center;
        [self.contentView addSubview:_imageView];
    }
    
    return self;
}

- (void)setIcon:(UIImage *)icon {
    _imageView.image = icon;
}

@end
