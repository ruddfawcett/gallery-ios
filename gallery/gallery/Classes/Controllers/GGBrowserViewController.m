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

@interface GGBrowserViewController () <GGSetSelectionDelegate, GGColorPickerDelegate, GGBarSelectionDelegate>

@property (nonatomic) NSInteger selectedSet;
@property (strong, nonatomic) UIColor *selectedColor;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UITabBar *tabBar;
@property (strong, nonatomic) UITabBarItem *temporaryItem;
@property (strong, nonatomic) UITabBarItem *filler;
@property (strong, nonatomic) UITabBarItem *shift;

@property (strong, nonatomic) UIView *glow;
@property (strong, nonatomic) UIView *itemGlow;
@property (strong, nonatomic) UIView *tabBarOverlay;
@property (strong, nonatomic) UIView *collectionViewOverlay;
@property (strong, nonatomic) UIImageView *iconOverlay;

@property (nonatomic) NSInteger beginningItem;
@property (nonatomic) NSInteger endItem;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (nonatomic) BOOL itemsAnimated;

@end

@implementation GGBrowserViewController

static NSString * const reuseIdentifier = @"IconCell";

- (id)init {
    if (self = [super init]) {
        [GGMenuViewController sharedMenu].glyphishSetDelegate = self;
        [GGMenuViewController sharedMenu].glyphishColorDelegate = self;
        [GGMenuViewController sharedMenu].glyphishBarDelegate = self;
        
        self.itemsAnimated = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-65, 15)];
//    self.searchBar.placeholder = @"Search for an icon";
//    
//    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
//    self.navigationItem.rightBarButtonItem = searchBarItem;
    
    self.title = @"Glyphish Tester";
    
    [self initializeTabBar];
    [self initializeCollectionView];
    
//    NSMutableArray *test = [NSMutableArray array];
//    
//    for (int i; i <= 5; i++) {
//        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@""
//                                                           image:[UIImage imageWithCGImage:[[UIImage imageFromArchivedString:[self currentSet][i][@"archive"]] CGImage]
//                                                                                     scale:3.0
//                                                                               orientation:UIImageOrientationUp] tag:0];
//        
//        [test addObject:item];
//    }
//    
//    [self.tabBar setItems:test animated:NO];
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
    self.collectionView.backgroundColor = [UIColor whiteColor];
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
    
    [self addOverlay];
    
    if (self.tabBar.items.count == 0 || ![touch.view isEqual:self.tabBarOverlay] || !CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
        return;
    }
    
    if (self.tabBar.items.count > 0) {
        self.beginningItem = [self.tabBar itemAtPoint:location];
        UITabBarItem *tabBarItem = self.tabBar.items[self.beginningItem];
        self.temporaryItem = tabBarItem;
        [self setUpIconOverlay:tabBarItem.image indexPath:nil tabBar:YES center:location];
        
        self.shift = [[UITabBarItem alloc] initWithTitle:nil image:nil selectedImage:nil];
        
        NSMutableArray *items = [self.tabBar.items mutableCopy];
        [items replaceObjectAtIndex:self.beginningItem withObject:self.shift];
        
        [self.tabBar setItems:items animated:self.itemsAnimated];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    NSInteger currentItem = [self.tabBar itemAtPoint:location];
    
    NSMutableArray *items = [self.tabBar.items mutableCopy];
    [items removeObject:self.shift];
    [items insertObject:self.shift atIndex:currentItem];
    
    if (!CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
        [items removeObject:self.shift];
    }
    
    [self.tabBar setItems:items animated:self.itemsAnimated];
    
    [self moveIconOverlay:location];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    self.endItem = [self.tabBar itemAtPoint:location];
    
    NSMutableArray *items = [self.tabBar.items mutableCopy];
    
    if (self.endItem != self.beginningItem) {
        if (self.tabBar.items.count != 0) {
            if (self.temporaryItem != nil) {
                [items replaceObjectAtIndex:[self.tabBar.items indexOfObject:self.shift] withObject:self.temporaryItem];
            }
        }
        
        [self.tabBar setItems:items animated:NO];
    }
    else {
        
        [items replaceObjectAtIndex:self.beginningItem withObject:self.temporaryItem];
        
        [self.tabBar setItems:items animated:NO];
    }
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
        
        [items removeObject:self.temporaryItem];
        
        [self.tabBar setItems:items animated:self.itemsAnimated];
        
        return;
    }
    
    self.endItem = [self.tabBar itemAtPoint:location];
    
    NSMutableArray *items = [self.tabBar.items mutableCopy];
    
    if (self.endItem != self.beginningItem) {
        if (self.tabBar.items.count != 0) {
            if (self.temporaryItem != nil) {
                [items replaceObjectAtIndex:[self.tabBar.items indexOfObject:self.shift] withObject:self.temporaryItem];
            }
        }
        
        [self.tabBar setItems:items animated:NO];
    }
    else {
        
        [items replaceObjectAtIndex:self.beginningItem withObject:self.temporaryItem];
        
        [self.tabBar setItems:items animated:NO];
    }
}

#pragma mark - LongPressGestureRecognizer Management

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self longPressBegan:gesture];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self longPressMoved:gesture];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self longPressEnded:gesture];
    }
}

- (void)longPressBegan:(UILongPressGestureRecognizer *)gesture {
    self.filler = [[UITabBarItem alloc] initWithTitle:nil image:nil selectedImage:nil];
    
    CGPoint location = [gesture locationInView:self.collectionView];
    
    [self addOverlay];
    
    NSIndexPath *selectedItem = [self.collectionView indexPathForItemAtPoint:location];
    
    GGIconCollectionViewCell *cell = (GGIconCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectedItem];
    
    if (cell.imageView.image != nil) {
        [self setUpIconOverlay:cell.imageView.image indexPath:selectedItem tabBar:NO center:[gesture locationInView:self.collectionViewOverlay]];
    }
}

- (void)longPressMoved:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.collectionViewOverlay];
    NSMutableArray *items = [self.tabBar.items mutableCopy];
    
    NSInteger currentItem = [self.tabBar itemAtPoint:location];
    
    if (self.tabBar.items.count < 5 || [self.tabBar.items containsObject:self.filler]) {
        [items removeObject:self.filler];
        [items insertObject:self.filler atIndex:currentItem];
    }
    
    if (self.tabBar.items.count == 5 && ![self.tabBar.items containsObject:self.filler]) {
        [self.itemGlow removeFromSuperview];
        [self.glow removeFromSuperview];
        
        if (CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
            self.itemGlow = [[UIView alloc] initWithFrame:[self.tabBar frameForItem:currentItem]];
            
            self.glow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            self.glow.layer.cornerRadius = self.glow.frame.size.width/2;
            self.glow.backgroundColor = [UIColor whiteColor];
            self.glow.alpha = 0.6;
            self.glow.center = self.itemGlow.center;
            
            [self.tabBarOverlay addSubview:self.glow];
            [self.tabBarOverlay addSubview:self.itemGlow];
        }
    }
    
    if (!CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
        [items removeObject:self.filler];
    }
    
    [self.tabBar setItems:items animated:self.itemsAnimated];
    [self moveIconOverlay:location];
}

- (void)longPressEnded:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.collectionViewOverlay];
    
    NSMutableArray *items = [self.tabBar.items mutableCopy];
    
    if (!CGRectContainsPoint(self.tabBarOverlay.frame, location)) {
        [items removeObject:self.filler];
        
        [self.tabBar setItems:items animated:YES];
        
        [self removeOverlay];
        return;
    }
    
    self.endItem = [self.tabBar itemAtPoint:location];
    
    NSArray *components = [[self currentSet][self.iconOverlay.tag][@"name"] componentsSeparatedByString:@"_"];
    NSInteger selectedSet = self.selectedSet == 0 ? 8 : self.selectedSet;
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:[NSString stringWithFormat:@"%ld-%@",(long)selectedSet,components[0]]
                                                       image:[UIImage imageWithCGImage:[self.iconOverlay.image CGImage]
                                                                                 scale:3.0
                                                                           orientation:UIImageOrientationUp] tag:0];
    if (self.tabBar.items.count == 0) {
        items = [NSMutableArray arrayWithObject:item];
        [self.tabBar setItems:items animated:self.itemsAnimated];
    }
    else if (self.tabBar.items.count < 5) {
        [items replaceObjectAtIndex:[self.tabBar.items indexOfObject:self.filler] withObject:item];
        [self.tabBar setItems:items animated:NO];
    }
    else {
        [items replaceObjectAtIndex:self.endItem withObject:item];
        [self.tabBar setItems:items animated:NO];
    }
    
    [self removeOverlay];
}

#pragma mark - Collection View Overlay Management

- (void)addOverlay {
//    self.collectionViewOverlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.collectionViewOverlay = [[UIView alloc] initWithFrame:self.collectionView.frame];
    self.collectionViewOverlay.backgroundColor = [UIColor blackColor];
    self.collectionViewOverlay.alpha = 0;
    
    [UIView animateWithDuration:0.7 animations:^{
        self.collectionViewOverlay.alpha = 0.8;
    }];
    
    [self.navigationController.view addSubview:self.collectionViewOverlay];
}

- (void)removeOverlay {
    [UIView animateWithDuration:0.3 animations:^{
        self.collectionViewOverlay.alpha = 0;
    }];
    
    self.collectionViewOverlay = nil;
    
    [self.iconOverlay removeFromSuperview];
    self.iconOverlay = nil;
    
    [self.itemGlow removeFromSuperview];
    self.itemGlow = nil;
    
    [self.glow removeFromSuperview];
    self.glow = nil;
    
    self.filler = nil;
}

#pragma mark - Icon Overlay Management

- (void)moveIconOverlay:(CGPoint)newCenter {
    if (self.iconOverlay) {
        [self setUpIconOverlay:nil indexPath:nil tabBar:NO center:newCenter];
    }
}

- (void)setUpIconOverlay:(UIImage *)image indexPath:(NSIndexPath *)indexPath tabBar:(BOOL)tabBar center:(CGPoint)center {
    UIColor *iconColor;
    if (!tabBar) {
        iconColor = self.selectedColor ? self.selectedColor : GG_DEFAULT_COLOR;
    }
    else iconColor = self.view.tintColor;
    
    if (!self.iconOverlay) {
        self.iconOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        self.iconOverlay.contentMode = UIViewContentModeScaleAspectFit;
        self.iconOverlay.alpha = 0;
        self.iconOverlay.tag = indexPath.row;
        
        self.iconOverlay.image = [UIImage maskedImage:image color:iconColor];
        
        [UIView animateWithDuration:0.5 animations:^{
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

- (void)didSelectBar:(GGBarTypes)barType {
    
}

@end
