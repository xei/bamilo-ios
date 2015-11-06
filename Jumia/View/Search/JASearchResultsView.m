//
//  JASearchResultsView.m
//  Jumia
//
//  Created by Telmo Pinto on 05/05/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JASearchResultsView.h"
#import "JAClickableView.h"
#import "RISearchSuggestion.h"

@interface JASearchResultsView()

@property (nonatomic, strong)UIControl* backView;
@property (nonatomic, strong)UITableView* resultsTableView;
@property (nonatomic, assign)CGRect resultsTableOriginalFrame;
@property (nonatomic, strong)NSMutableArray* resultsArray;

@property (nonatomic, assign)CGFloat currentKeyboardHeight;

@end

@implementation JASearchResultsView

@synthesize searchText=_searchText;
- (void)setSearchText:(NSString *)searchText
{
    _searchText = searchText;
    if (searchText.length > 1)
    {
        [RISearchSuggestion getSuggestionsForQuery:searchText
                                      successBlock:^(NSArray *suggestions) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              self.resultsArray = [suggestions mutableCopy];
                                              [self addResultsTableViewToView];
                                          });
                                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                      }];
    } else {
        self.resultsArray = [[RISearchSuggestion getRecentSearches] mutableCopy];
        if (VALID_NOTEMPTY(self.resultsArray, NSMutableArray)) {
            [self addResultsTableViewToView];
        } else {
            [self removeResultsTableViewFromView];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentKeyboardHeight = 0.0f;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        self.backView = [[UIControl alloc] initWithFrame:self.bounds];
        self.backView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
        [self addSubview:self.backView];
        
        [self.backView addTarget:self
                          action:@selector(popSearchResults)
                forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.backView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        }];
        
        self.resultsTableView = [[UITableView alloc] initWithFrame:self.bounds
                                                             style:UITableViewStyleGrouped];
        
        self.resultsTableView.backgroundColor = UIColorFromRGB(0xffffff);
        self.resultsTableView.delegate = self;
        self.resultsTableView.dataSource = self;
        self.resultsTableView.contentInset = UIEdgeInsetsMake(-35.0f, 0.f, 0.f, 0.f);
        [self.resultsTableView registerClass:[UITableViewCell class]
                      forCellReuseIdentifier:@"cell"];
        self.resultsTableView.separatorColor = [UIColor clearColor];

        self.resultsTableOriginalFrame = self.resultsTableView.frame;
        
        [self addSubview:self.resultsTableView];
        
        self.resultsTableView.hidden = YES;
    }
    return self;
}

- (void)reloadFrame:(CGRect)frame
{
    self.frame = frame;
    self.backView.frame = self.bounds;
    self.resultsTableView.frame = CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                             self.resultsTableOriginalFrame.origin.y,
                                             self.resultsTableOriginalFrame.size.width,
                                             self.resultsTableOriginalFrame.size.height - self.currentKeyboardHeight);
    [self.resultsTableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)popSearchResults
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchResultsViewWillPop)]) {
        [self.delegate searchResultsViewWillPop];
    }
    
    [self removeResultsTableViewFromView];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - resultsTableView

- (void)addResultsTableViewToView
{
    [self.resultsTableView reloadData];
    
    if (self.resultsTableView.hidden) {
        self.resultsTableView.hidden = NO;
        
        CGRect finalFrame = self.resultsTableView.frame;
        
        self.resultsTableView.frame = CGRectMake(self.resultsTableView.frame.origin.x,
                                                 self.resultsTableView.frame.size.height,
                                                 self.resultsTableView.frame.size.width,
                                                 self.resultsTableView.frame.size.height);
        
        [UIView animateWithDuration:0.3f animations:^{
            self.resultsTableView.frame = finalFrame;
        }];
    }
}

- (void)removeResultsTableViewFromView
{
    CGRect startFrame = self.resultsTableView.frame;
    
    CGRect finalFrame = CGRectMake(self.resultsTableView.frame.origin.x,
                                   self.resultsTableView.frame.size.height,
                                   self.resultsTableView.frame.size.width,
                                   self.resultsTableView.frame.size.height);
    
    [UIView animateWithDuration:0.3f animations:^{
        self.resultsTableView.frame = finalFrame;
    } completion:^(BOOL finished) {
        self.resultsTableView.hidden = YES;
        self.resultsTableView.frame = startFrame;
    }];
}

#pragma mark - Tableview datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    CGFloat heightLabel = 44.0f;
    //remove the clickable view
    for (UIView* view in cell.subviews) {
        if ([view isKindOfClass:[JAClickableView class]]) { //remove the clickable view
            [view removeFromSuperview];
        } else {
            for (UIView* subview in view.subviews) {
                if ([subview isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                    [subview removeFromSuperview];
                }
            }
        }
    }
    
    //add the new clickable view
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    [cell setFrame:CGRectMake(cell.frame.origin.x,
                              cell.frame.origin.y,
                              self.resultsTableView.frame.size.width,
                              cell.frame.size.height)];
    
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                   0.0f,
                                                                                   self.resultsTableView.frame.size.width,
                                                                                   cellHeight)];
    clickView.tag = indexPath.row;
    [cell addSubview:clickView];
    
    UILabel *customTextLabel = [UILabel new];
    customTextLabel.textAlignment = NSTextAlignmentLeft;
    [clickView addSubview:customTextLabel];
    
    RISearchSuggestion *sugestion = [self.resultsArray objectAtIndex:indexPath.row];
    
    NSString *text = sugestion.item;
    NSString *searchedText = self.searchText;
    
    if (text.length == 0)
    {
        text = STRING_ERROR;
    }
    
    NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:text];
    NSInteger stringTextLenght = text.length;
    
    UIFont *stringTextFont = [UIFont fontWithName:kFontLightName size:17.0f];
    UIFont *subStringTextFont = [UIFont fontWithName:kFontRegularName size:17.0f];
    UIColor *stringTextColor = UIColorFromRGB(0x4e4e4e);
    
    
    [stringText addAttribute:NSFontAttributeName
                       value:stringTextFont
                       range:NSMakeRange(0, stringTextLenght)];
    
    [stringText addAttribute:NSStrokeColorAttributeName
                       value:stringTextColor
                       range:NSMakeRange(0, stringTextLenght)];
    
    NSRange range = [text rangeOfString:searchedText];
    
    [stringText addAttribute:NSFontAttributeName
                       value:subStringTextFont
                       range:range];
    
    customTextLabel.attributedText = stringText;
    
    UIImage *recentSearchImage;
    UIImageView *recentSearchImageView = [UIImageView new];
    
    
    if (1 == sugestion.isRecentSearch)
    {
        recentSearchImage = [UIImage imageNamed:@"ico_recentsearchsuggestion"];
    }
    else
    {
        recentSearchImage = [UIImage imageNamed:@"ico_searchsuggestion"];
    }

    [recentSearchImageView setImage:recentSearchImage];
    [clickView addSubview:recentSearchImageView];
    
    CGFloat customImageX = recentSearchImage.size.width;
    CGFloat customTextX = (recentSearchImage.size.width*2) + 18.0f;
    CGFloat separatorX = 45.0f;
    CGFloat separatorWidth = cell.frame.size.width-20;
    CGFloat customTextLabelWidth = clickView.frame.size.width - separatorX - 6.0f;
    
    [recentSearchImageView setFrame:CGRectMake(customImageX,
                                              (heightLabel - recentSearchImage.size.height)/2,
                                              recentSearchImage.size.width,
                                              recentSearchImage.size.height)];
    
    
    [customTextLabel setFrame:CGRectMake(customTextX,
                                         0.0f,
                                         customTextLabelWidth,
                                         heightLabel)];
    
    //remove the clickable view
    for (UIView* view in cell.subviews) {
        if (99 == view.tag || 98 == view.tag) {
            [view removeFromSuperview];
        }
    }
    UIImageView *line;
    if (0 == indexPath.row)
    {
        line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 1)];
        line.backgroundColor = UIColorFromRGB(0xcccccc);
        line.tag = 99;
        [clickView addSubview:line];
    }
    
    UIImageView *line2 = [[UIImageView alloc] initWithFrame:CGRectMake(separatorX, cell.frame.size.height-1, separatorWidth, 1)];
    line2.backgroundColor = UIColorFromRGB(0xcccccc);
    line2.tag = 98;
    [clickView addSubview:line2];
    
    if(RI_IS_RTL){
        
        [cell flipSubviewPositions];
        [line flipViewPositionInsideSuperview];
        [line2 flipViewPositionInsideSuperview];
        [recentSearchImageView flipViewPositionInsideSuperview];
        [customTextLabel flipViewPositionInsideSuperview];
        [customTextLabel setTextAlignment:NSTextAlignmentRight];
    }
    [clickView addTarget:self action:@selector(resultCellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)resultCellWasPressed:(UIControl*)sender
{
    [self tableView:self.resultsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RISearchSuggestion *suggestion = [self.resultsArray objectAtIndex:indexPath.row];
    
    [self searchFor:suggestion.item];
}

#pragma mark - Keyboard
- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    if(self.frame.size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    self.currentKeyboardHeight = height;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.resultsTableView setFrame:CGRectMake(self.resultsTableOriginalFrame.origin.x,
                                                   self.resultsTableOriginalFrame.origin.y,
                                                   self.resultsTableOriginalFrame.size.width,
                                                   self.resultsTableOriginalFrame.size.height - self.currentKeyboardHeight)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [self popSearchResults];
}

#pragma mark - Search Actions
- (void)searchFor:(NSString*)stringToSearch
{
    [RISearchSuggestion saveSearchSuggestionOnDB:stringToSearch
                                  isRecentSearch:YES andContext:YES];
    
    // I changed the index to 99 to know that it's to display a search result
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(99),
                                                                 @"name": STRING_SEARCH,
                                                                 @"text": stringToSearch }];
    
    [self popSearchResults];
}

@end
