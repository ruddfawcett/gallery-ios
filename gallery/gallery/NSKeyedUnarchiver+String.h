//
//  NSKeyedUnarchiver+String.h
//  test
//
//  Created by Rudd Fawcett on 8/27/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSKeyedUnarchiver (String)

+ (id)unarchiveObjectWithString:(NSString *)string;

@end
