//
//  JASortingView.m
//  Jumia
//
//  Created by Telmo Pinto on 12/02/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JASortingView.h"
#import "JAClickableView.h"

@interface JASortingView()

@property (nonatomic, assign) RICatalogSorting selectedIndex;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) JAClickableView* doneClickableView;

@end

@implementation JASortingView

- (void)setupWithFrame:(CGRect)frame
       selectedSorting:(RICatalogSorting)selectedSorting;
{
    self.selectedIndex = selectedSorting;
    
    self.frame = frame;
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    
    CGFloat margin = 6.0f;
    
    CGFloat buttonHeight = 44.0f;
    self.doneClickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(margin,
                                                                               self.frame.size.height - margin - buttonHeight,
                                                                               self.frame.size.width - margin*2,
                                                                               buttonHeight)];
    self.doneClickableView.layer.cornerRadius = 5.0f;
    [self.doneClickableView setTitle:STRING_CANCEL forState:UIControlStateNormal];
    self.doneClickableView.backgroundColor = [UIColor whiteColor];
    [self.doneClickableView addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.doneClickableView];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    CGFloat tableHeight = [self tableView:self.tableView numberOfRowsInSection:0] * [self tableView:self.tableView heightForRowAtIndexPath:nil];
    [self.tableView setFrame:CGRectMake(margin,
                                        self.doneClickableView.frame.origin.y - margin - tableHeight,
                                        self.frame.size.width - margin*2,
                                        tableHeight)];
    self.tableView.layer.cornerRadius = 5.0f;
    [self addSubview:self.tableView];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kJASORTINGVIEW_OPTIONS_ARRAY.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"sortingCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    for (UIView* view in cell.subviews) {
        if ([view isKindOfClass:[JAClickableView class]] || -1 == view.tag) { //remove the clickable view or separator
            [view removeFromSuperview];
        }
    }
    //add the new clickable view
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 44.0f)];
    clickView.tag = indexPath.row;
    [clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:clickView];
    
    
    //add the new separator
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 43.0f,
                                                                 self.tableView.frame.size.width,
                                                                 1)];
    separator.tag = -1;
    separator.backgroundColor = JALabelGrey;
    [cell addSubview:separator];

    
    if (0 == indexPath.row) {
        [clickView setTitle:[STRING_SORT_BY uppercaseString] forState:UIControlStateNormal];
        [clickView setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        clickView.userInteractionEnabled = NO;
        
        return cell;
    }
    
    NSInteger realIndex = indexPath.row - 1;
    
    clickView.tag = realIndex;
    
    NSString* option = [kJASORTINGVIEW_OPTIONS_ARRAY objectAtIndex:realIndex];
    [clickView setTitle:option forState:UIControlStateNormal];
    [clickView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if (realIndex == self.selectedIndex) {
        UIImage* checkImage = [UIImage imageNamed:@"selectionCheckmark"];
        UIImageView* checkImageView = [[UIImageView alloc] initWithImage:checkImage];
        [checkImageView setFrame:CGRectMake(clickView.frame.size.width - 20.0 - checkImage.size.width,
                                            (clickView.frame.size.height - checkImage.size.height) / 2,
                                            checkImage.size.width,
                                            checkImage.size.height)];
        [clickView addSubview:checkImageView];
    }
    
    return cell;
}

- (void)cellWasPressed:(UIButton*)button
{
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedSortingMethod:)]) {
        [self.delegate selectedSortingMethod:button.tag];
    }
}


@end
