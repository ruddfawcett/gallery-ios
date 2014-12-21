//
//  GGRadioButtonTableViewCell.m
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import "GGRadioButtonTableViewCell.h"

@interface GGRadioButtonTableViewCell ()

@property (strong, nonatomic) UIView *radio;
@property (strong, nonatomic) UIView *radioFill;

@end

@implementation GGRadioButtonTableViewCell

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
    return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpRadio];
        
        self.backgroundColor = [UIColor colorWithRed:0.239 green:0.271 blue:0.302 alpha:1.00];
        self.textLabel.textColor = [UIColor whiteColor];
        
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

- (void)setUpRadio {
    _radio = [[UIView alloc] initWithFrame:CGRectMake(8, 15, 16, 16)];
    _radio.backgroundColor = [UIColor colorWithRed:0.192 green:0.216 blue:0.243 alpha:1.00];
    _radio.layer.cornerRadius = _radio.frame.size.width/2;
    
    [self.contentView addSubview:_radio];
}

- (void)setOn:(BOOL)on color:(UIColor *)color {
    if (on) {
        _radioFill = [[UIView alloc] initWithFrame:CGRectMake(12, 18, 8, 8)];
        _radioFill.center = _radio.center;
        _radioFill.backgroundColor = color;
        _radioFill.layer.cornerRadius = _radioFill.frame.size.width/2;
        
        [self.contentView insertSubview:_radioFill aboveSubview:_radio];
    }
    else {
        [_radioFill removeFromSuperview];
    }
}

@end
