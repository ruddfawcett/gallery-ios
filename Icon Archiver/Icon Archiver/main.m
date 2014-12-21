//
//  main.m
//  Icon Archiver
//
//  Created by Rudd Fawcett on 12/17/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *glyphishComplete = [NSHomeDirectory() stringByAppendingPathComponent:@"Dropbox/Glyphish Complete/"];
        NSFileManager *localFileManager = NSFileManager.new;
        
        NSDirectoryEnumerator *directoryEnumerator = [localFileManager enumeratorAtURL:[NSURL fileURLWithPath:glyphishComplete]
                                                includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                                              errorHandler:nil];
        
        NSMutableArray *glyphishSets = [NSMutableArray array];
        
        for (NSURL *eachFolder in directoryEnumerator) {
            NSString *fileName;
            [eachFolder getResourceValue:&fileName forKey:NSURLNameKey error:NULL];

            NSNumber *isDirectory;
            [eachFolder getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            
            if ([isDirectory boolValue] == YES) {
                if ([fileName containsString:@"Glyphish"] && ![fileName containsString:@"Backgrounds"]) {
                    [glyphishSets addObject:fileName];
                    
                    [directoryEnumerator skipDescendants];
                }
            }
        }
        
        NSMutableDictionary *glyphish = [NSMutableDictionary dictionary];
        
        for (NSString *glyphishSet in glyphishSets) {
            NSMutableArray *setIcons = [NSMutableArray array];
            
            directoryEnumerator = [localFileManager enumeratorAtPath:[glyphishComplete stringByAppendingPathComponent:glyphishSet]];
            
            for (NSString *eachIcon in directoryEnumerator) {
                BOOL isDir = NO;
                
                [localFileManager fileExistsAtPath:eachIcon isDirectory:&isDir];
                
                if (([eachIcon containsString:@"Mini"] || [eachIcon containsString:@"Xtras"] || [eachIcon containsString:@"SVG"] || [eachIcon containsString:@"toolbar"])) {
                    [directoryEnumerator skipDescendants];
                }
                
                if ([eachIcon hasSuffix:@"@3x.png"]) {
                    [setIcons addObject:eachIcon];
                }
            }
            
            [setIcons sortUsingSelector:@selector(localizedStandardCompare:)];
            [glyphish setObject:setIcons forKey:glyphishSet];
        }
        
        NSMutableDictionary *finalIcons = [NSMutableDictionary dictionary];
        
        for (NSString *key in [glyphish allKeys]) {
            NSMutableArray *setIcons = [NSMutableArray array];
            
            for (NSString *path in glyphish[key]) {
                NSString *iconPath = [[glyphishComplete stringByAppendingPathComponent:key] stringByAppendingPathComponent:path];
                NSData *icon = [NSKeyedArchiver archivedDataWithRootObject:[[NSData alloc] initWithContentsOfFile:iconPath]];
                
                NSDictionary *eachIcon = @{@"name" : [[[[path lastPathComponent] stringByDeletingPathExtension]
                                                       stringByReplacingOccurrencesOfString:@"-" withString:@"_"]
                                                      stringByReplacingOccurrencesOfString:@"@3x" withString:@""], @"archive" : icon};
                
                [setIcons addObject:eachIcon];
            }
            
            [finalIcons setObject:setIcons forKey:[key stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
        }

        NSString *dictionaries = @"";
        
        for (NSString *glyphishSet in [finalIcons allKeys]) {
            dictionaries = [dictionaries stringByAppendingString:[NSString stringWithFormat:@"+ (NSArray *)%@;\n",glyphishSet]];
        }
        
        
        NSString *header = [NSString stringWithFormat:@"// \n//  GGIconArchive.h\n//\n//  Generated on %@.\n//  Copyright (c) 2014 Glyphish. All rights reserved.\n//\n\n#import <Foundation/Foundation.h>\n\n@interface GGIconArchive : NSObject\n\n%@\n@end\n", [NSDate date], dictionaries];
        
        NSMutableString *mArrays = [NSMutableString string];
        
        [mArrays appendString:[NSString stringWithFormat:@"// \n//  GGIconArchive.m\n//\n//  Generated on %@.\n//  Copyright (c) 2014 Glyphish. All rights reserved.\n//\n\n#import \"GGIconArchive.h\"\n\n@implementation GGIconArchive\n\n",[NSDate date]]];
        
        for (NSString *glyphishSet in [finalIcons allKeys]) {
            NSMutableString *eachDict = [NSMutableString string];
            [eachDict appendString:[NSString stringWithFormat:@"+ (NSArray *)%@ {\n    return @[", glyphishSet]];
            
            for (NSDictionary *eachDictionary in finalIcons[glyphishSet]) {
                [eachDict appendString:
                                       [NSString stringWithFormat:@"@{@\"name\" : @\"%@\", @\"archive\" : @\"%@\"}, ",
                                        eachDictionary[@"name"],
                                        eachDictionary[@"archive"]]];
            }
            
            [eachDict appendString:@"];\n}\n\n"];
            [mArrays appendString:eachDict];
        }
        
        [mArrays appendString:@"@end"];
        
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/GGIconArchive.h"] contents:[header dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/GGIconArchive.m"] contents:[mArrays dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    return 0;
}
