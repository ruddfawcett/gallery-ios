//
//  GGBrowserViewController
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import "GGBrowserViewController.h"

#import "GGIconArchive.h"

#import "GGIconCollectionViewCell.h"
#import "GGMenuViewController.h"
#import "GGColorPickerTableViewCell.h"

@interface GGBrowserViewController () <GGSetSelectionDelegate, GGColorPickerDelegate>

@property (nonatomic) NSInteger selectedSet;
@property (strong, nonatomic) UIColor *selectedColor;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UITabBar *tabBar;

@property (strong, nonatomic) UIView *tabBarOverlay;
@property (strong, nonatomic) UIView *collectionViewOverlay;
@property (strong, nonatomic) UIImageView *iconOverlay;

@property (nonatomic) NSInteger beginningItem;
@property (nonatomic) NSInteger endItem;

@property (nonatomic) BOOL itemsAnimated;

@end

@implementation GGBrowserViewController

static NSString * const reuseIdentifier = @"IconCell";

- (id)init {
    if (self = [super init]) {
        [GGMenuViewController sharedMenu].glyphishSetDelegate = self;
        [GGMenuViewController sharedMenu].glyphishColorDelegate = self;
        
        self.itemsAnimated = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initializeTabBar];
    [self initializeCollectionView];
}

- (void)initializeTabBar {
    self.tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-49, self.view.bounds.size.width, 49)];
    self.tabBar.userInteractionEnabled = NO;
    [self.view addSubview:self.tabBar];
    
    self.tabBarOverlay = [[UIView alloc] initWithFrame:self.tabBar.frame];
    [self.view insertSubview:self.tabBarOverlay aboveSubview:self.tabBar];
}

- (void)initializeCollectionView {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    
    int row = self.view.bounds.size.width > 414 ? 10 : 6;
    
    flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width/row, self.view.bounds.size.width/row);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-49.5) collectionViewLayout:flowLayout];
    self.collectionView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+self.tabBar.frame.size.height+20, 0, 0, 0);
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.scrollsToTop = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.3;
    longPress.numberOfTouchesRequired = 1;
    [self.collectionView addGestureRecognizer:longPress];
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[GGIconCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)currentSet {
    return self.selectedSet <= 2 ? [GGIconArchive Glyphish_8] : [GGIconArchive performSelector:NSSelectorFromString([NSString stringWithFormat:@"Glyphish_%lu",(unsigned long)self.selectedSet])];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self currentSet] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GGIconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImage *icon = [UIImage imageFromArchivedString:[self currentSet][indexPath.row][@"archive"]];
    
    cell.imageView.image = [UIImage maskedImage:icon color:(self.selectedColor ? self.selectedColor : GG_DEFAULT_COLOR)];
    
    return cell;
}

#pragma mark - Touches Management

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    if (self.tabBar.items.count == 0 || ![touch.view isEqual:self.tabBarOverlay] || !CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
        return;
    }
    
    if (self.tabBar.items.count > 0) {
        self.beginningItem = [self.tabBar itemAtPoint:location];
        UITabBarItem *tabBarItem = self.tabBar.items[self.beginningItem];
        [self setUpIconOverlay:tabBarItem.image tabBar:YES center:location];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    [self moveIconOverlay:location];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeOverlay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeOverlay];
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    if (self.tabBar.items.count == 0) {
        return;
    }
    
    if (!CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
        NSMutableArray *items = [self.tabBar.items mutableCopy];
        
        [items removeObjectAtIndex:self.beginningItem];
        
        [self.tabBar setItems:items animated:self.itemsAnimated];
        
        return;
    }
    
    self.endItem = [self.tabBar itemAtPoint:location];
    
    if (self.endItem != self.beginningItem) {
        NSMutableArray *items = [self.tabBar.items mutableCopy];

        if (self.tabBar.items.count != 0) {
            [items exchangeObjectAtIndex:self.beginningItem withObjectAtIndex:self.endItem];
        }
            
        [self.tabBar setItems:items animated:self.itemsAnimated];
    }
}

#pragma mark - LongPressGestureRecognizer Management

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self longPressBegan:gesture];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self moveIconOverlay:[gesture locationInView:self.collectionViewOverlay]];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self longPressEnded:gesture];
    }
}

- (void)longPressBegan:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.collectionView];
    
    [self addOverlay];
    
    NSIndexPath *selectedItem = [self.collectionView indexPathForItemAtPoint:location];
    
    GGIconCollectionViewCell *cell = (GGIconCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectedItem];
    
    if (cell.imageView.image != nil) {
        [self setUpIconOverlay:cell.imageView.image tabBar:NO center:[gesture locationInView:self.collectionViewOverlay]];
    }
}

- (void)longPressEnded:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.collectionViewOverlay];
    
    if (!CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
        [self removeOverlay];
        return;
    }
    
    self.endItem = [self.tabBar itemAtPoint:location];
    
    NSMutableArray *items = [self.tabBar.items mutableCopy];
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Title" image:[UIImage imageWithCGImage:[self.iconOverlay.image CGImage]
                                                                                                scale:3.0
                                                                                          orientation:UIImageOrientationUp] tag:0];
    if (self.tabBar.items.count == 0) {
        items = [NSMutableArray arrayWithObject:item];
    }
    else if (self.tabBar.items.count < 5) {
        [items insertObject:item atIndex:self.endItem+1];
    }
    else {
        [items replaceObjectAtIndex:self.endItem withObject:item];
    }
    
    [self.tabBar setItems:items animated:self.itemsAnimated];
    
    [self removeOverlay];
}

#pragma mark - Collection View Overlay Management

- (void)addOverlay {
    self.collectionViewOverlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.navigationController.view addSubview:self.collectionViewOverlay];
}

- (void)removeOverlay {
    [self.collectionViewOverlay removeFromSuperview];
    self.collectionViewOverlay = nil;
    
    [self.iconOverlay removeFromSuperview];
    self.iconOverlay = nil;
}

#pragma mark - Icon Overlay Management

- (void)moveIconOverlay:(CGPoint)newCenter {
    if (self.iconOverlay) {
        [self setUpIconOverlay:nil tabBar:NO center:newCenter];
    }
}

- (void)setUpIconOverlay:(UIImage *)image tabBar:(BOOL)tabBar center:(CGPoint)center {
    UIColor *iconColor;
    if (!tabBar) {
        iconColor = self.selectedColor ? self.selectedColor : GG_DEFAULT_COLOR;
    }
    else iconColor = self.view.tintColor;
    
    if (!self.iconOverlay) {
        self.iconOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        self.iconOverlay.contentMode = UIViewContentModeScaleAspectFit;
        self.iconOverlay.alpha = 0;
        
        self.iconOverlay.image = [UIImage maskedImage:image color:iconColor];
        
        [UIView animateWithDuration:1 animations:^{
            self.iconOverlay.alpha = 1;
        }];
    }
    
//    if (CGRectContainsPoint(self.tabBar.frame, center)) {
//        self.iconOverlay.image = [UIImage maskedImage:self.iconOverlay.image color:self.view.tintColor];
//    }
//    else {
//        self.iconOverlay.image = [UIImage maskedImage:self.iconOverlay.image color:(self.selectedColor ? self.selectedColor : GG_DEFAULT_COLOR)];
//    }

    self.iconOverlay.center = center;
    
    [self.navigationController.view addSubview:self.iconOverlay];
}

#pragma mark - Delegates

- (void)didSelectSet:(NSInteger)set {
    self.selectedSet = set;
    [self reload];
}

- (void)didSelectColor:(UIColor *)color {
    self.selectedColor = color;
    self.tabBar.tintColor = color;
    [self reload];
}

- (void)reload {
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(-self.collectionView.contentInset.left, -self.collectionView.contentInset.top) animated:YES];
}

@end
