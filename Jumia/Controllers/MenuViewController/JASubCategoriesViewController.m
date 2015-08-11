//
//  JASubCategoriesViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 29/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASubCategoriesViewController.h"
#import "RICategory.h"
#import "RICustomer.h"
#import "JAClickableView.h"

@interface JASubCategoriesViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableViewCategories;

@end

@implementation JASubCategoriesViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.A4SViewControllerAlias = @"SUBCATEGORY";
    
    self.title = @"";
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.hidesBackButton = YES;
    
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:kSideMenuShouldReload object:nil];
}

- (void)popToRoot
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

#pragma mark - Tableview delegates and datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat total = self.categories.count + 2;//add one for title and another one for backbutton
    return total;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (UIView* view in cell.subviews) {
        if ([view isKindOfClass:[JAClickableView class]] || -1 == view.tag) { //remove the clickable view or separator
            [view removeFromSuperview];
        } else {
            for (UIView* subview in view.subviews) {
                if ([subview isKindOfClass:[JAClickableView class]] || -1 == subview.tag) { //remove the clickable view or separator
                    [subview removeFromSuperview];
                }
            }
        }
    }
    //add the new clickable view
    CGFloat cellHeight = 44.0f;
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, cellHeight)];
    clickView.tag = indexPath.row;
    [clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:clickView];
    
    
    //add the new separator
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 cellHeight - 1,
                                                                 self.view.frame.size.width,
                                                                 1)];
    separator.tag = -1;
    separator.backgroundColor = JALabelGrey;
    [cell addSubview:separator];
    
    NSInteger realIndex = indexPath.row;

    CGFloat margin = 13.0f;
    
    UILabel* customTextLabel = [UILabel new];
    [clickView addSubview:customTextLabel];
    
    UIImage* backImage = [UIImage imageNamed:@"btn_back"];
    UIImage* accessoryImage = [UIImage imageNamed:@"arrow_gotoarea"];
    if (RI_IS_RTL) {
        customTextLabel.textAlignment = NSTextAlignmentRight;
        backImage = [backImage flipImageWithOrientation:UIImageOrientationUpMirrored];
        accessoryImage = [accessoryImage flipImageWithOrientation:UIImageOrientationUpMirrored];
    }
    UIImageView* customImageView = [UIImageView new];
    [customImageView setImage:backImage];
    UIImageView* customAcessoryView = [UIImageView new];
    [customAcessoryView setImage:accessoryImage];

    
    NSString* backCellTitle = STRING_BACK;
    if (VALID_NOTEMPTY(self.backTitle, NSString)) {
        backCellTitle = self.backTitle;
    }
    //ALWAYS has back cell
    if (0 == realIndex) {
        //this is the back cell
        customTextLabel.text = backCellTitle;
        customTextLabel.font = [UIFont fontWithName:kFontRegularName size:17.0f];
        customTextLabel.textColor = UIColorFromRGB(0xc8c8c8);
        [clickView addSubview:customImageView];
        
        CGFloat customImageX = margin;
        CGFloat customTextX = customImageX + accessoryImage.size.width + margin;
        CGFloat customTextWidth = self.view.frame.size.width - customTextX;
        if (RI_IS_RTL) {
            customTextX = 0.0f;
            customImageX = customTextWidth + margin;
        }
        
        [customImageView setFrame:CGRectMake(customImageX,
                                             (cellHeight - accessoryImage.size.height) / 2,
                                             accessoryImage.size.width,
                                             accessoryImage.size.height)];
        [customTextLabel setFrame:CGRectMake(customTextX,
                                             0.0f,
                                             customTextWidth,
                                             cellHeight)];
        return cell;
    }
    realIndex--;
    
    if (VALID_NOTEMPTY(self.currentCategory, RICategory)) {
        //has current category
        if (0 == realIndex) {
            //this is the current category cell
            customTextLabel.text = self.currentCategory.name;
            customTextLabel.font = [UIFont fontWithName:kFontBoldName size:14.0f];
            customTextLabel.textColor = UIColorFromRGB(0x4e4e4e);
            
            [customTextLabel setFrame:CGRectMake(margin,
                                                 0.0f,
                                                 self.view.frame.size.width - margin*2,
                                                 cellHeight)];
            
            return cell;
        }
    } else {
        //does not have current category
        if (0 == realIndex) {
            //this is the current category cell
            customTextLabel.text = [STRING_CATEGORIES uppercaseString];
            customTextLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
            customTextLabel.textColor = UIColorFromRGB(0xc8c8c8);
            
            [customTextLabel setFrame:CGRectMake(margin,
                                                 0.0f,
                                                 self.view.frame.size.width - margin*2,
                                                 cellHeight)];
            
            clickView.enabled = NO;
            return cell;
        }
    }
    
    realIndex--;
    
    RICategory* category = [self.categories objectAtIndex:realIndex];
    
    customTextLabel.text = category.name;
    customTextLabel.font = [UIFont fontWithName:kFontLightName size:17.0f];
    customTextLabel.textColor = UIColorFromRGB(0x4e4e4e);

    if (VALID_NOTEMPTY(category.children, NSOrderedSet)) {
        [cell addSubview:customAcessoryView];
    }
    
    CGFloat customTextX = margin;
    CGFloat customImageX = self.view.frame.size.width - margin - accessoryImage.size.width;
    CGFloat customTextWidth = customImageX - margin*2;
    if (RI_IS_RTL) {
        customImageX = margin;
        customTextX = customImageX + accessoryImage.size.width + margin;
    }
    
    [customAcessoryView setFrame:CGRectMake(customImageX,
                                            (cellHeight - accessoryImage.size.height) / 2,
                                            accessoryImage.size.width,
                                            accessoryImage.size.height)];
    [customTextLabel setFrame:CGRectMake(customTextX,
                                         0.0f,
                                         customTextWidth,
                                         cellHeight)];
    
    return cell;
}

- (void)cellWasPressed:(UIControl*)sender
{
    [self tableView:self.tableViewCategories didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger realIndex = indexPath.row;
    
    //ALWAYS has back cell
    if (0 == realIndex) {
        //this is the back cell
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    realIndex--;
    
    if (VALID_NOTEMPTY(self.currentCategory, RICategory)) {
        //has current category
        
        if (0 == realIndex) {
            //this is the current category cell
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification
                                                                object:@{@"category":self.currentCategory}];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventTopCategory]
                                                      data:[NSDictionary dictionaryWithObject:[RICategory getTopCategory:self.currentCategory] forKey:kRIEventCategoryNameKey]];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastViewedCategory] data:[NSDictionary dictionaryWithObject:self.currentCategory.uid forKey:kRIEventLastViewedCategoryKey]];
            return;
        }
    } else {
        if (0 == realIndex) {
            //do nothing
            return;
        }
    }
    
    realIndex--;
    
    RICategory* category = [self.categories objectAtIndex:realIndex];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:category.name forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Categories" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCategories]
                                              data:[trackingDictionary copy]];

    
    if (VALID_NOTEMPTY(category.children, NSOrderedSet)) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main"
                                                        bundle:nil];
        
        JASubCategoriesViewController *newSubCategories = [story instantiateViewControllerWithIdentifier:@"subCategoriesViewController"];
        newSubCategories.categories = category.children.array;
        newSubCategories.currentCategory = category;
        if (VALID_NOTEMPTY(self.currentCategory, RICategory)) {
            newSubCategories.backTitle = self.currentCategory.name;
        } else {
            newSubCategories.backTitle = STRING_CATEGORIES;
        }
        
        [self.navigationController pushViewController:newSubCategories
                                             animated:YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification
                                                            object:@{@"category":category}];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventTopCategory]
                                                  data:[NSDictionary dictionaryWithObject:[RICategory getTopCategory:category] forKey:kRIEventCategoryNameKey]];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastViewedCategory] data:[NSDictionary dictionaryWithObject:category.uid
                                                                                                                                           forKey:kRIEventLastViewedCategoryKey]];
    }
}

@end
