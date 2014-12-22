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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.statusBarUnderlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, 20)];
    self.statusBarUnderlay.backgroundColor = [UIColor blackColor];
    
    GGBrowserViewController *topViewController = [GGBrowserViewController new];
    GGMenuViewController *menuController = [GGMenuViewController sharedMenu];
    menuController.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeLeft;
    
    UIBarButtonItem *anchorRightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-icon"] style:UIBarButtonItemStyleDone target:self action:@selector(anchorRight)];
    topViewController.navigationItem.title = @"Glyphish Gallery";
    topViewController.navigationItem.leftBarButtonItem  = anchorRightButton;
    topViewController.view.backgroundColor = [UIColor whiteColor];
    
    UIGestureRecognizer *resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTopViewAnimated)];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:topViewController];
    [self.navigationController.view addGestureRecognizer:resetTapGesture];
    
    self.slidingViewController = [ECSlidingViewController slidingWithTopViewController:self.navigationController];
    self.slidingViewController.underLeftViewController = menuController;
    self.slidingViewController.anchorRightPeekAmount = 45.0;
    
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
