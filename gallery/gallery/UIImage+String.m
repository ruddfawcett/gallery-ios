//
//  UIImage+String.m
//  test
//
//  Created by Rudd Fawcett on 12/16/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import "UIImage+String.h"

@implementation UIImage (String)

+ (instancetype)imageFromArchivedString:(NSString *)string {
    return [UIImage imageWithData:[NSKeyedUnarchiver unarchiveObjectWithString:string] scale:[[UIScreen mainScreen] scale]];
}

+ (instancetype)maskedImage:(UIImage *)image color:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

@end
