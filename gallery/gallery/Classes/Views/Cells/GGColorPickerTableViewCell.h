//
//  GGColorPickerTableViewCell.h
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class GGColorPickerTableViewCell;

@protocol GGColorPickerCellDelegate <NSObject>

- (void)didSelectColor:(UIColor *)color hex:(NSString *)hex;

@end

@interface GGColorPickerTableViewCell : UITableViewCell <UITextFieldDelegate>

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (strong, nonatomic) id<GGColorPickerCellDelegate> glyphishCellColorDelegate;

@property (strong, nonatomic) UIView *color;

@property (strong, nonatomic) UITextField *textField;

@end
