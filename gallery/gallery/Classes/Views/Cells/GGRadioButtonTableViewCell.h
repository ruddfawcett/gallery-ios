//
//  GGRadioButtonTableViewCell.h
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GGRadioButtonTableViewCell : UITableViewCell

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)setOn:(BOOL)on color:(UIColor *)color;

@end
