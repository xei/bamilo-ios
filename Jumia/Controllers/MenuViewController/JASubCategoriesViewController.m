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
        }
    }
    //add the new clickable view
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
    clickView.tag = indexPath.row;
    [clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:clickView];
    
    
    //add the new separator
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 43.0f,
                                                                 self.view.frame.size.width,
                                                                 1)];
    separator.tag = -1;
    separator.backgroundColor = JALabelGrey;
    [cell addSubview:separator];
    
    NSInteger realIndex = indexPath.row;
    
    NSString* backCellTitle = STRING_BACK;
    if (VALID_NOTEMPTY(self.backTitle, NSString)) {
        backCellTitle = self.backTitle;
    }
    //ALWAYS has back cell
    if (0 == realIndex) {
        //this is the back cell
        cell.textLabel.text = backCellTitle;
        cell.textLabel.font = [UIFont fontWithName:kFontRegularName size:17.0f];
        cell.textLabel.textColor = UIColorFromRGB(0xc8c8c8);
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.imageView setImage:[UIImage imageNamed:@"btn_back"]];
        return cell;
    }
    realIndex--;
    
    [cell.imageView setImage:nil];
    
    if (VALID_NOTEMPTY(self.currentCategory, RICategory)) {
        //has current category
        if (0 == realIndex) {
            //this is the current category cell
            cell.textLabel.text = self.currentCategory.name;
            cell.textLabel.font = [UIFont fontWithName:kFontBoldName size:14.0f];
            cell.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
    } else {
        //does not have current category
        if (0 == realIndex) {
            //this is the current category cell
            cell.textLabel.text = [STRING_CATEGORIES uppercaseString];
            cell.textLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
            cell.textLabel.textColor = UIColorFromRGB(0xc8c8c8);
            cell.accessoryType = UITableViewCellAccessoryNone;
            clickView.enabled = NO;
            [clickView removeFromSuperview];
            return cell;
        }
    }
    
    realIndex--;
    
    RICategory* category = [self.categories objectAtIndex:realIndex];
    
    cell.textLabel.text = category.name;
    cell.textLabel.font = [UIFont fontWithName:kFontLightName size:17.0f];
    cell.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
    if (VALID_NOTEMPTY(category.children, NSOrderedSet)) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
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
    if(ISEMPTY(category.parent))
    {
        [trackingDictionary setObject:[RICategory getTopCategory:category] forKey:kRIEventTopCategoryKey];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventTopCategory]
                                                  data:[trackingDictionary copy]];
    }
    
    trackingDictionary = [[NSMutableDictionary alloc] init];
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
    }
}

@end
