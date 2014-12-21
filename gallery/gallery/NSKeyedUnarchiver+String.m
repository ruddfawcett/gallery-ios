//
//  NSKeyedUnarchiver+String.m
//  test
//
//  Created by Rudd Fawcett on 8/27/14.
//  Copyright (c) 2014 Rudd Fawcett. All rights reserved.
//

#import "NSKeyedUnarchiver+String.h"

@implementation NSKeyedUnarchiver (String)

+ (id)unarchiveObjectWithString:(NSString *)string {
    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    string = [[string componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    
    NSMutableData *data = [NSMutableData new];
    
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [string length]/2; i++) {
        byte_chars[0] = [string characterAtIndex:i*2];
        byte_chars[1] = [string characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        
        [data appendBytes:&whole_byte length:1];
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
