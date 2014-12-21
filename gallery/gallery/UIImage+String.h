//
//  UIImage+String.h
//  test
//
//  Created by Rudd Fawcett on 12/16/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSKeyedUnarchiver+String.h"

@interface UIImage (String)

+ (instancetype)imageFromArchivedString:(NSString *)string;
+ (instancetype)maskedImage:(UIImage *)image color:(UIColor *)color;

@end
