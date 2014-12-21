//
//  GGBrowserViewController.h
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GGIconArchive.h"

#import "NSKeyedUnarchiver+String.h"
#import "UIImage+String.h"
#import "UITabBar+GGExtensions.h"

#import "GGIconCollectionViewCell.h"
#import "GGMenuViewController.h"
#import "GGColorPickerTableViewCell.h"

#define GG_DEFAULT_COLOR [UIColor colorWithRed:0.000 green:0.655 blue:1.000 alpha:1.00]

@interface GGBrowserViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, GGSetSelectionDelegate, GGColorPickerDelegate>

@end
