//
//  GGMenuViewController.m
//  gallery
//
//  Created by Rudd Fawcett on 12/19/14.
//  Copyright (c) 2014 Glyphish. All rights reserved.
//

#import "GGMenuViewController.h"

@interface GGMenuViewController ()

@property (strong, nonatomic) NSArray *contents;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIColor *selectedColor;
@property (strong, nonatomic) NSString *colorHex;

@property (strong, nonatomic) NSIndexPath *selectedBar;
@property (strong, nonatomic) NSIndexPath *selectedSet;

@end

@implementation GGMenuViewController

+ (instancetype)sharedMenu {
    static GGMenuViewController *_sharedMenu = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMenu = GGMenuViewController.new;
    });
    
    return _sharedMenu;
}

- (id)init {
    if (self = [super init]) {
        self.contents = @[
                          @[@"Icon Color"],
                          @[@"UI Color"],
                          @[@"Tab Bar", @"Nav Bar"],
                          @[@"Glyphish %d"]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [self.view addSubview:[self tableHeaderView]];
    [self setUpTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)setUpTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width-45, self.view.bounds.size.height-70) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.239 green:0.271 blue:0.302 alpha:1.00];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.tableFooterView = [self tableFooterView];
    UIEdgeInsets inset = UIEdgeInsetsZero;
    inset.bottom -= 100;
    self.tableView.contentInset = inset;
    [self.view addSubview:self.tableView];
}

- (UIView *)tableHeaderView {
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-45, 70)];
    background.backgroundColor = [UIColor colorWithRed:0.161 green:0.180 blue:0.200 alpha:1.00];
    
    UIView *statusBarUnderlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, background.bounds.size.width, 25)];
    statusBarUnderlay.backgroundColor = [UIColor blackColor];
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, background.bounds.size.width, background.bounds.size.height-statusBarUnderlay.bounds.size.height)];
    logo.contentMode = UIViewContentModeCenter;
    logo.clipsToBounds = YES;
    logo.image = [UIImage imageNamed:@"glyphish-logo"];
    
    [background addSubview:statusBarUnderlay];
    [background addSubview:logo];
    
    return background;
}

- (UIView *)tableFooterView {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-45, 100)];
    
    NSInteger offset = ((GGSectionCount * 48) + 48 * GGSetCount) > self.view.bounds.size.height ?  100 : self.view.bounds.size.height - ((GGSectionCount * 48) + 48 * GGSetCount);
    
    UILabel *credits = [[UILabel alloc] initWithFrame:CGRectMake(0, offset, footer.bounds.size.width, footer.bounds.size.height)];
    credits.font = [UIFont systemFontOfSize:12];
    credits.textAlignment = NSTextAlignmentCenter;
    credits.textColor = [UIColor lightGrayColor];
    credits.numberOfLines = 0;
    credits.text = @"Designed with \u2764\U0000FE0E in Portland.\nMade with \u2764\U0000FE0E in New York.";
    
    [footer addSubview:credits];
    
    return footer;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDelegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return GGSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == GGMenuSectionSets) {
        return GGSetCount;
    }
    
    else return [self.contents[section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 1)];
    background.backgroundColor = [UIColor colorWithRed:0.200 green:0.224 blue:0.251 alpha:1.00];
    
    return background;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == GGMenuSectionSets) {
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 1)];
        background.backgroundColor = [UIColor colorWithRed:0.200 green:0.224 blue:0.251 alpha:1.00];
        
        return background;
    }

    else return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == GGMenuSectionSets ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];

    if (indexPath.section == GGMenuSectionIconColor) {
        GGColorPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Color"];
        cell = [GGColorPickerTableViewCell cellWithReuseIdentifier:@"Color"];
        cell.textLabel.text = self.contents[indexPath.section][indexPath.row];
        
        cell.textField.text = self.colorHex ? self.colorHex : @"";
        cell.color.backgroundColor = self.selectedColor ? self.selectedColor : [UIColor colorWithRed:0.000 green:0.690 blue:1.000 alpha:1.00];
        
        cell.glyphishCellColorDelegate = self;
        
        return cell;
    }
    else if (indexPath.section == GGMenuSectionUIColor) {
        GGUIColorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UIColor"];
        cell = [GGUIColorTableViewCell cellWithReuseIdentifier:@"UIColor"];
        cell.textLabel.text = self.contents[indexPath.section][indexPath.row];
        
        return cell;
    }
    else if (indexPath.section == GGMenuSectionBar) {
        GGRadioButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Radio"];
        cell = [GGRadioButtonTableViewCell cellWithReuseIdentifier:@"Radio"];
        cell.textLabel.text = self.contents[indexPath.section][indexPath.row];
        
        if (self.selectedBar) {
            if (self.selectedBar == indexPath) {    
                [cell setOn:YES color:[UIColor colorWithRed:0.929 green:0.286 blue:0.349 alpha:1.00]];
            }
            else {
                [cell setOn:NO color:nil];
            }
        }
        else {
            if (indexPath.row == 0) {
                [cell setOn:YES color:[UIColor colorWithRed:0.929 green:0.286 blue:0.349 alpha:1.00]];
            }
        }
        
        return cell;
    }
    else if (indexPath.section == GGMenuSectionSets) {
        GGRadioButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Radio"];
        cell = [GGRadioButtonTableViewCell cellWithReuseIdentifier:@"Radio"];
        cell.textLabel.text = [NSString stringWithFormat:self.contents[indexPath.section][0], GGSetCount+2-indexPath.row];
        
        if (self.selectedSet) {
            if (self.selectedSet == indexPath) {
                [cell setOn:YES color:[UIColor colorWithRed:0.169 green:0.867 blue:0.725 alpha:1.00]];
            }
            else {
                [cell setOn:NO color:nil];
            }
        }
        else {
            if (indexPath.row == 0) {
                [cell setOn:YES color:[UIColor colorWithRed:0.169 green:0.867 blue:0.725 alpha:1.00]];
            }
        }
        
        return cell;
    }
    else {
        cell.textLabel.text = self.contents[indexPath.section][indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == GGMenuSectionBar) {
        self.selectedBar = indexPath;
        [self.tableView reloadData];
    }
    if (indexPath.section == GGMenuSectionSets) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.glyphishSetDelegate && [self.glyphishSetDelegate respondsToSelector:@selector(didSelectSet:)]) {
                [self.glyphishSetDelegate didSelectSet:GGSetCount+2-indexPath.row];
            }
        });
        
        self.selectedSet = indexPath;
        [self.tableView reloadData];
    }
}

- (void)didSelectColor:(UIColor *)color hex:(NSString *)hex {
    self.selectedColor = color;
    self.colorHex = hex;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.glyphishColorDelegate && [self.glyphishColorDelegate respondsToSelector:@selector(didSelectColor:)]) {
            [self.glyphishColorDelegate didSelectColor:color];
        }
    });
}

@end
