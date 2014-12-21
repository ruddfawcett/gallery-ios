//
//  GGColorPickerTableViewCell.m
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import "GGColorPickerTableViewCell.h"

@interface GGColorPickerTableViewCell ()

@property (strong, nonatomic) UIView *colorWell;

@end

@implementation GGColorPickerTableViewCell

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
    return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpColorWell];
        [self setUpTextField];
        
        self.backgroundColor = [UIColor colorWithRed:0.239 green:0.271 blue:0.302 alpha:1.00];
        self.textLabel.textColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(36, 0, self.contentView.bounds.size.width-36, self.contentView.bounds.size.height);
    _textField.frame = CGRectMake(self.frame.size.width-100, 9, 90, self.frame.size.height-18);
}

- (void)setUpColorWell {
    _colorWell = [[UIView alloc] initWithFrame:CGRectMake(8, 15, 17, 17)];
    _colorWell.backgroundColor = [UIColor colorWithRed:0.192 green:0.216 blue:0.243 alpha:1.00];
    _colorWell.layer.cornerRadius = 5;
    
    _color = [[UIView alloc] initWithFrame:CGRectMake(12, 18, 12, 12)];
    _color.center = _colorWell.center;
    _color.backgroundColor = [UIColor colorWithRed:0.000 green:0.690 blue:1.000 alpha:1.00];
    _color.layer.cornerRadius = 3;
    
    [self.contentView addSubview:_colorWell];
    [self.contentView insertSubview:_color aboveSubview:_colorWell];
}

- (void)setUpTextField {
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(self.frame.size.width-100, 9, 90, self.frame.size.height-18)];
    _textField.layer.cornerRadius = 5;
    _textField.backgroundColor = [UIColor colorWithRed:0.200 green:0.224 blue:0.251 alpha:1.00];
    _textField.textColor = [UIColor lightGrayColor];
    _textField.delegate = self;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *leftView = [[UILabel alloc] initWithFrame:CGRectMake(5, -1, 15, _textField.frame.size.height)];
    leftView.text = @"#";
    leftView.textAlignment = NSTextAlignmentRight;
    leftView.textColor = [UIColor lightGrayColor];
    leftView.backgroundColor = _textField.backgroundColor;
    _textField.leftView = leftView;
    
    [self addSubview:_textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if (newLength <= 6) {
        NSString *hex = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (hex.length == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIColor *selectedColor = [UIColor colorWithRed:0.000 green:0.690 blue:1.000 alpha:1.00];
                _color.backgroundColor = selectedColor;
                
                if (self.glyphishCellColorDelegate && [self.glyphishCellColorDelegate respondsToSelector:@selector(didSelectColor:hex:)]) {
                    [self.glyphishCellColorDelegate didSelectColor:selectedColor hex:hex];
                }
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIColor *selectedColor = [self colorFromHexString:hex];
                _color.backgroundColor = selectedColor;
                
                if (self.glyphishCellColorDelegate && [self.glyphishCellColorDelegate respondsToSelector:@selector(didSelectColor:hex:)]) {
                    [self.glyphishCellColorDelegate didSelectColor:selectedColor hex:hex];
                }
            });
        }
    }
    
    return (newLength > 6) ? NO : YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
