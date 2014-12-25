//
//  AppDelegate.m
//  gallery
//
//  Created by Rudd Fawcett on 12/18/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import "AppDelegate.h"

#import "GGBrowserViewController.h"
#import "GGMenuViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UIView *statusBarUnderlay;

@property (strong, nonatomic) UIView *overlay;

@end

@implementation AppDelegate

+ (instancetype)sharedDelegate {
    static AppDelegate *_sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDelegate = self.new;
    });
    
    return _sharedDelegate;
}

- (float)reveal {
    return self.window.bounds.size.width > 414 ? [[UIScreen mainScreen] bounds].size.width*(.140625*4) : [[UIScreen mainScreen] bounds].size.width*(.140625);
    // could possibly do .140625*2, for a greater reveal
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.161 green:0.180 blue:0.200 alpha:1.00]];
    
    self.statusBarUnderlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, 20)];
    self.statusBarUnderlay.backgroundColor = [UIColor blackColor];
    
    GGBrowserViewController *topViewController = [GGBrowserViewController new];
    GGMenuViewController *menuController = [GGMenuViewController sharedMenu];
    menuController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
    
    UIBarButtonItem *anchorRightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-icon"] style:UIBarButtonItemStyleDone target:self action:@selector(anchorRight)];
    topViewController.navigationItem.leftBarButtonItem  = anchorRightButton;
    topViewController.view.backgroundColor = [UIColor whiteColor]; // need this line for proper height of content
    
    UIGestureRecognizer *resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTopViewAnimated)];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:topViewController];
    [self.navigationController.view addGestureRecognizer:resetTapGesture];
    
    self.slidingViewController = [ECSlidingViewController slidingWithTopViewController:self.navigationController];
    self.slidingViewController.underLeftViewController = menuController;
    self.slidingViewController.anchorRightPeekAmount = [self reveal];
    
    self.window.tintColor = [UIColor colorWithRed:0.424 green:0.471 blue:0.502 alpha:1.00];
    self.window.rootViewController = self.slidingViewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)anchorRight {
    if (self.slidingViewController.currentTopViewPosition == ECSlidingViewControllerTopViewPositionCentered) {
        [self.slidingViewController.topViewController.view addSubview:self.statusBarUnderlay];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        
        self.overlay = [[UIView alloc] initWithFrame:self.navigationController.view.frame];
        [self.navigationController.view addSubview:self.overlay];
        
        [self.slidingViewController anchorTopViewToRightAnimated:YES onComplete:nil];
    } else {
        [self resetTopViewAnimated];
    }
}

- (void)resetTopViewAnimated {
    if (self.slidingViewController.currentTopViewPosition != ECSlidingViewControllerTopViewPositionCentered) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self.statusBarUnderlay performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
        [self.slidingViewController resetTopViewAnimated:YES onComplete:nil];
        [self.overlay removeFromSuperview];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
