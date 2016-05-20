//
//  JAORPaymentViewController.m
//  Jumia
//
//  Created by telmopinto on 18/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORPaymentViewController.h"
#import "JAProductInfoHeaderLine.h"
#import "JAButton.h"
#import "RIForm.h"
#import "UIImageView+WebCache.h"
#import "JACenterNavigationController.h"
#import "JABottomSubmitView.h"
#import "JAORProductView.h"

@interface JAORPaymentViewController () <JADynamicFormDelegate>

@property (nonatomic, strong) NSString* titleString;
@property (nonatomic, strong) JAProductInfoHeaderLine *titleHeaderView;
@property (assign, nonatomic) CGFloat scrollOriginalHeight;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIView* itemViewsContentView;
@property (nonatomic, strong) NSArray* itemViewsArray;
@property (nonatomic, strong) UIView* formContentView;
@property (nonatomic, strong) RIForm* paymentForm;
@property (nonatomic, strong) JADynamicForm* dynamicForm;

@property (nonatomic, assign) BOOL isLoaded;

@property (nonatomic, strong) JABottomSubmitView *submitView;

@end

@implementation JAORPaymentViewController

- (JAProductInfoHeaderLine *)titleHeaderView
{
    if (!VALID(_titleHeaderView, JAProductInfoHeaderLine)) {
        _titleHeaderView = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kProductInfoHeaderLineHeight)];
        [_titleHeaderView.label setNumberOfLines:2];
        [_titleHeaderView setTitle:self.titleString];
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
            [productView setQtyToReturn:[self.stateInfoLabels objectForKey:[NSString stringWithFormat:@"return_detail[%@][quantity]", item.sku]]];
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

- (JADynamicForm*)dynamicForm
{
    if (!VALID_NOTEMPTY(_dynamicForm, JADynamicForm)) {
        if (VALID_NOTEMPTY(self.paymentForm, RIForm)) {
            for (int i = 0; i<self.items.count; i++) {
                _dynamicForm = [[JADynamicForm alloc] initWithForm:self.paymentForm startingPosition:0.0f];
                _dynamicForm.delegate = self;
            }
        }
    }
    return _dynamicForm;
}

- (UIView*)formContentView
{
    if (!VALID(_formContentView, UIView)) {
        if (VALID_NOTEMPTY(self.paymentForm, RIForm)) {
            _formContentView = [UIView new];
            [self.scrollView addSubview:_formContentView];
            
            CGFloat currentY = 0.0f;
            
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
    self.navBarLayout.title = STRING_MY_ORDERS;
    
    [self.view setBackgroundColor:JAWhiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
    self.isLoaded = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.itemViewsContentView removeFromSuperview];
    self.itemViewsContentView = nil;
    self.itemViewsArray = nil;
    
    [self.formContentView removeFromSuperview];
    self.formContentView = nil;
    
    if (self.isLoaded) {
        [self loadSubviews];
    } else {
        [self requestForm];
    }
}

- (void)requestForm
{
    [self showLoading];
    [RIForm getForm:@"refundmethod" successBlock:^(RIForm *form) {
        [self hideLoading];
        self.isLoaded = YES;
        
        self.paymentForm = form;
        
        if (VALID_NOTEMPTY(form.fields, NSOrderedSet)) {
            RIField* field = [form.fields firstObject];
            self.titleString = field.label;
        }
        
        [self loadSubviews];
    } failureBlock:^(RIApiResponse apiResponse, NSArray *errors) {
        [self hideLoading];
        [self onErrorResponse:apiResponse messages:errors showAsMessage:NO selector:@selector(requestForm) objects:nil];
    }];
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
    [self.submitView setWidth:self.view.frame.size.width];
    [self.submitView setYBottomAligned:0.f];
    
    [self.scrollView setFrame:CGRectMake(self.bounds.origin.x,
                                         self.bounds.origin.y,
                                         self.bounds.size.width,
                                         self.bounds.size.height - self.submitView.frame.size.height)];
    self.scrollOriginalHeight = self.scrollView.frame.size.height;
    
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
        
        NSDictionary *values = [self.dynamicForm getValuesReplacingPlaceHolder:@"__NAME__" forString:item.sku];
        if (VALID(self.stateInfoValues, NSMutableDictionary))
        {
            [self.stateInfoValues addEntriesFromDictionary:values];
        }
        if (VALID(self.stateInfoLabels, NSMutableDictionary))
        {
            [self.stateInfoLabels addEntriesFromDictionary:[self.dynamicForm getFieldLabelsReplacePlaceHolder:@"__NAME__" forString:item.sku]];
        }
    }
    [[JACenterNavigationController sharedInstance] goToOnlineReturnsConfirmScreenForItems:self.items order:self.order];
}


#pragma mark - JADynamicFormDelegate

- (void)dynamicFormChangedHeight;
{
    UIView* lastView = [self.dynamicForm.formViews lastObject];
    self.formContentView.height = CGRectGetMaxY(lastView.frame);
    
    [self.itemViewsContentView removeFromSuperview];
    self.itemViewsContentView = nil;
    self.itemViewsArray = nil;
    
    [self loadSubviews];
}


#pragma mark - Keyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    
    if(self.view.frame.size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    
    height -= self.submitView.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x,
                                             self.scrollView.frame.origin.y,
                                             self.scrollView.frame.size.width,
                                             self.scrollOriginalHeight - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x,
                                             self.scrollView.frame.origin.y,
                                             self.scrollView.frame.size.width,
                                             self.scrollOriginalHeight)];
    }];
}

- (void)hideKeyboard
{
    [self.dynamicForm resignResponder];
}

@end
