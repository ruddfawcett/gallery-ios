//
//  AppDelegate.h
//  gallery
//
//  Created by Rudd Fawcett on 12/18/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ECSlidingViewController/ECSlidingViewController.h>

@class GGBrowserViewController;
@class GGMenuViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) ECSlidingViewController *slidingViewController;

@property (strong, nonatomic) UIWindow *window;


@end

