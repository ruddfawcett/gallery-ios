//
//  GGBrowserViewController
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import "GGBrowserViewController.h"

@interface GGBrowserViewController ()

@property (nonatomic) NSInteger selectedSet;
@property (strong, nonatomic) UIColor *selectedColor;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UITabBar *tabBar;

@property (strong, nonatomic) UIView *tabBarOverlay;
@property (strong, nonatomic) UIView *collectionViewOverlay;
@property (strong, nonatomic) UIImageView *iconOverlay;

@property (nonatomic) NSInteger beginningItem;
@property (nonatomic) NSInteger endItem;

@end

@implementation GGBrowserViewController

static NSString * const reuseIdentifier = @"IconCell";

- (id)init {
    if (self = [super init]) {
        [GGMenuViewController sharedMenu].glyphishSetDelegate = self;
        [GGMenuViewController sharedMenu].glyphishColorDelegate = self;
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
    flowLayout.itemSize = CGSizeMake(50, 50);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-49.5) collectionViewLayout:flowLayout];
    self.collectionView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+self.tabBar.frame.size.height+20, 0, 0, 0);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.scrollsToTop = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.3;
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
        [self setUpIconOverlay:tabBarItem.image center:location];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    if (![touch.view isEqual:self.tabBarOverlay] || !CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
        return;
    }
    
    [self moveIconOverlay:location];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeOverlay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeOverlay];
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    if (![touch.view isEqual:self.tabBarOverlay] || self.tabBar.items.count == 0) {
        return;
    }
    
    if (!CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
        NSMutableArray *items = [self.tabBar.items mutableCopy];
        
        [self.tabBar setItems:items animated:YES];
        
        return;
    }
    
    self.endItem = [self.tabBar itemAtPoint:location];
    
    if (self.endItem != self.beginningItem) {
        NSMutableArray *items = [self.tabBar.items mutableCopy];

        if (self.tabBar.items.count != 0) {
            [items exchangeObjectAtIndex:self.beginningItem withObjectAtIndex:self.endItem];
        }
            
        [self.tabBar setItems:items animated:YES];
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
    
    [self setUpIconOverlay:cell.imageView.image center:[gesture locationInView:self.collectionViewOverlay]];
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
    
    [self.tabBar setItems:items animated:YES];
    
    [self removeOverlay];
}

#pragma mark - Collection View Overlay Management

- (void)addOverlay {
    self.collectionViewOverlay = [[UIView alloc] initWithFrame:self.collectionView.frame];
    
    [self.view insertSubview:self.collectionViewOverlay aboveSubview:self.collectionView];
}

- (void)removeOverlay {
    [self.collectionViewOverlay removeFromSuperview];
    self.collectionViewOverlay = nil;
    
    [self.iconOverlay removeFromSuperview];
    self.iconOverlay = nil;
}

#pragma mark - Icon Overlay Management

- (void)moveIconOverlay:(CGPoint)newCenter {
    [self setUpIconOverlay:nil center:newCenter];
}

- (void)setUpIconOverlay:(UIImage *)image center:(CGPoint)center {
    if (!self.iconOverlay) {
        self.iconOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        self.iconOverlay.contentMode = UIViewContentModeScaleAspectFit;
        self.iconOverlay.image = image;
    }

    self.iconOverlay.center = center;
    
    [self.view addSubview:self.iconOverlay];
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
