//
//  GGMenuViewController.h
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Color-Picker-for-iOS/HRColorPickerView.h>

#import "GGColorPickerTableViewCell.h"
#import "GGUIColorTableViewCell.h"
#import "GGRadioButtonTableViewCell.h"

#define GGSetCount 6

typedef NS_ENUM(NSUInteger, GGMenuSections) {
    GGMenuSectionIconColor,
    GGMenuSectionUIColor,
    GGMenuSectionBar,
    GGMenuSectionSets,
    GGSectionCount
};


@class GGMenuViewController;

@protocol GGSetSelectionDelegate <NSObject>

- (void)didSelectSet:(NSInteger)set;

@end

@protocol GGColorPickerDelegate <NSObject>

- (void)didSelectColor:(UIColor *)color;

@end

@interface GGMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GGColorPickerCellDelegate>

+ (instancetype)sharedMenu;

@property (weak, nonatomic) id<GGSetSelectionDelegate> glyphishSetDelegate;
@property (weak, nonatomic) id<GGColorPickerDelegate> glyphishColorDelegate;

@end
