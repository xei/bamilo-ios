//
//  JAORWaysViewController.m
//  Jumia
//
//  Created by telmopinto on 13/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORWaysViewController.h"
#import "JAProductInfoHeaderLine.h"
#import "JAButton.h"
#import "RIForm.h"
#import "UIImageView+WebCache.h"
#import "JACenterNavigationController.h"
#import "JABottomSubmitView.h"
#import "JAORProductView.h"

@interface JAORWaysViewController () <JADynamicFormDelegate>

@property (nonatomic, strong) JAProductInfoHeaderLine *titleHeaderView;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIView* itemViewsContentView;
@property (nonatomic, strong) NSArray* itemViewsArray;
@property (nonatomic, strong) UIView* formContentView;
@property (nonatomic, strong) RIForm* returnWayForm;
@property (nonatomic, strong) JADynamicForm* dynamicForm;

@property (nonatomic, assign) BOOL isLoaded;

@property (nonatomic, strong) JABottomSubmitView *submitView;

@end

@implementation JAORWaysViewController

- (JAProductInfoHeaderLine *)titleHeaderView
{
    if (!VALID(_titleHeaderView, JAProductInfoHeaderLine)) {
        _titleHeaderView = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kProductInfoHeaderLineHeight)];
        [_titleHeaderView.label setNumberOfLines:2];
        [_titleHeaderView setTitle:[STRING_QUESTION_RETURN_REASONS uppercaseString]];
        [self.view addSubview:_titleHeaderView];
    }
    return _titleHeaderView;
}

- (UIScrollView*)scrollView
{
    if (!VALID(_scrollView, UIScrollView)) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIView*)itemViewsContentView
{
    if (!VALID_NOTEMPTY(_itemViewsContentView, UIView)) {
        _itemViewsContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         CGRectGetMaxY(self.formContentView.frame),
                                                                         self.scrollView.frame.size.width,
                                                                         1.0f)];
        NSMutableArray* mutableItemViewsArray = [NSMutableArray new];
        CGFloat itemY = 0.0f;
        for (int i = 0; i<self.items.count; i++) {
            RIItemCollection* item = [self.items objectAtIndex:i];

            CGFloat currentY = itemY;
            
            JAORProductView* productView = [[JAORProductView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                             currentY,
                                                                                             self.scrollView.frame.size.width,
                                                                                             1.0f)];
            [productView setupWithItemCollection:item order:self.order];
            currentY += productView.frame.size.height;
            
            if (i != self.items.count-1) {
                //not last one
                UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, productView.frame.size.height-1.0f, self.view.frame.size.width - 16.0f*2, 1.0f)];
                separatorView.backgroundColor = JABlack400Color;
                [productView addSubview:separatorView];
            }
            
            itemY += productView.frame.size.height;
            
            [mutableItemViewsArray addObject:productView];
            
            [_itemViewsContentView setHeight:itemY];
            [_itemViewsContentView addSubview:productView];
        }
        [self.scrollView addSubview:_itemViewsContentView];
        
        self.itemViewsArray = [mutableItemViewsArray copy];
    }
    return _itemViewsContentView;
}

- (UIView*)formContentView
{
    if (!VALID(_formContentView, UIView)) {
        if (VALID_NOTEMPTY(self.returnWayForm, RIForm)) {
            _formContentView = [UIView new];
            [self.scrollView addSubview:_formContentView];
            
            CGFloat currentY = 0.0f;
            
            self.dynamicForm = [[JADynamicForm alloc] initWithForm:self.returnWayForm startingPosition:0.0f];
            self.dynamicForm.delegate = self;
            for (UIView* formView in self.dynamicForm.formViews) {
                [formView setWidth:self.scrollView.frame.size.width - 16.0f*2];
                [formView setX:16.0f];
                [_formContentView addSubview:formView];
                currentY = CGRectGetMaxY(formView.frame);
            }
            
            [_formContentView setFrame:CGRectMake(0.0f, kProductInfoHeaderLineHeight, self.scrollView.frame.size.width, currentY)];
        }
    }
    return _formContentView;
}

- (JABottomSubmitView *)submitView
{
    if (!VALID(_submitView, JABottomSubmitView)) {
        _submitView = [[JABottomSubmitView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [JABottomSubmitView defaultHeight])];
        _submitView.button = [[JAButton alloc] initButtonWithTitle:STRING_CONTINUE];
        [_submitView.button addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_submitView];
    }
    return _submitView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = NO;
    
    [self.view setBackgroundColor:JAWhiteColor];
    
    self.isLoaded = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isLoaded) {
        [self loadSubviews];
    } else {
        [self showLoading];
        [RIForm getForm:@"returnmethod" successBlock:^(RIForm *form) {
            [self hideLoading];
            self.isLoaded = YES;
            
            self.returnWayForm = form;
            
            [self loadSubviews];
        } failureBlock:^(RIApiResponse apiResponse, NSArray *errors) {
            [self hideLoading];
        }];
    }
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    
    [self.itemViewsContentView removeFromSuperview];
    self.itemViewsContentView = nil;
    self.itemViewsArray = nil;
    
    [self.formContentView removeFromSuperview];
    self.formContentView = nil;
    
    [self loadSubviews];
}

- (void)loadSubviews
{
    [self.scrollView setFrame:self.bounds];
    
    [self.titleHeaderView setFrame:CGRectMake(0.0f, 0.0f, self.scrollView.frame.size.width, self.titleHeaderView.frame.size.height)];
    
    [self.formContentView setFrame:CGRectMake(0.0f,
                                              CGRectGetMaxY(self.titleHeaderView.frame),
                                              self.scrollView.frame.size.width,
                                              self.formContentView.frame.size.height)];
    
    [self.itemViewsContentView setFrame:CGRectMake(0.0f,
                                                   CGRectGetMaxY(self.formContentView.frame),
                                                   self.scrollView.frame.size.height,
                                                   self.itemViewsContentView.frame.size.height)];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                               CGRectGetMaxY(self.itemViewsContentView.frame))];
    
    for (UIView* itemView in self.itemViewsArray) {
        if (RI_IS_RTL) {
            [itemView flipAllSubviews];
        }
    }
    
    [self.submitView setWidth:self.view.frame.size.width];
    [self.submitView setYBottomAligned:0.f];
    
    if (RI_IS_RTL) {
        [self.titleHeaderView flipAllSubviews];
    }
}

- (void)nextButtonPressed
{
    for (int i = 0; i<self.items.count; i++) {
        RIItemCollection* item = [self.items objectAtIndex:i];
        
        if ([self.dynamicForm checkErrors]) {
            
            NSArray* message;
            if (VALID_NOTEMPTY(self.dynamicForm.firstErrorInFields, NSString)) {
                message = [NSArray arrayWithObject:self.dynamicForm.firstErrorInFields];
            }
            
            [self onErrorResponse:RIApiResponseSuccess messages:message showAsMessage:YES selector:@selector(nextButtonPressed) objects:nil];
            
            return;
        }
        
        if (VALID(self.stateInfo, NSMutableDictionary))
        {
            [self.stateInfo addEntriesFromDictionary:[self.dynamicForm getValuesReplacingPlaceHolder:@"__NAME__" forString:item.sku]];
        }
    }
    [[JACenterNavigationController sharedInstance] goToOnlineReturnsConfirmScreenForItems:self.items order:self.order];
}


#pragma mark - JADynamicFormDelegate

- (void)dynamicFormChangedHeight;
{
    UIView* lastView = [self.dynamicForm.formViews lastObject];
    self.formContentView.height = CGRectGetMaxY(lastView.frame);
    
    [self loadSubviews];
}

@end
