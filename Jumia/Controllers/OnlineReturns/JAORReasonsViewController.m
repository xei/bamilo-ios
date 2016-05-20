//
//  JAORReasonsViewController.m
//  Jumia
//
//  Created by telmopinto on 10/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORReasonsViewController.h"
#import "JACenterNavigationController.h"
#import "JAProductInfoHeaderLine.h"
#import "UIImageView+WebCache.h"
#import "RIForm.h"
#import "JADynamicForm.h"
#import "JAPicker.h"
#import "RIFieldOption.h"
#import "JAButton.h"
#import "JACenterNavigationController.h"
#import "JABottomSubmitView.h"
#import "JAORProductView.h"

@interface JAORReasonsViewController () <JADynamicFormDelegate, JAPickerDelegate>

@property (nonatomic, strong) JAProductInfoHeaderLine *titleHeaderView;
@property (assign, nonatomic) CGFloat scrollOriginalHeight;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* itemViewsArray;
@property (nonatomic, strong) RIForm* returnDetailForm;
@property (nonatomic, strong) JAPicker* picker;
@property (nonatomic, strong) NSArray* dynamicForms;

@property (nonatomic, assign) BOOL isLoaded;

@property (nonatomic, strong) JAListNumberComponent* currentListNumberComponent;
@property (nonatomic, strong) JARadioComponent* currentRadioComponent;
@property (nonatomic, strong) NSArray* currentRadioComponentDataset;

@property (nonatomic, strong) JABottomSubmitView *submitView;

@property (nonatomic, strong) NSDictionary *values;

@end

@implementation JAORReasonsViewController

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

- (NSArray*)dynamicForms
{
    if (!VALID_NOTEMPTY(_dynamicForms, NSArray)) {
        NSMutableArray* dynamicFormsMutableArray = [NSMutableArray new];
        if (VALID_NOTEMPTY(self.returnDetailForm, RIForm)) {
            for (int i = 0; i<self.items.count; i++) {
                JADynamicForm* dynamicForm = [[JADynamicForm alloc] initWithForm:self.returnDetailForm startingPosition:0.0f];
                dynamicForm.delegate = self;
                [dynamicFormsMutableArray addObject:dynamicForm];
            }
        }
        _dynamicForms = [dynamicFormsMutableArray copy];
    }
    return _dynamicForms;
}

- (NSArray*)itemViewsArray
{
    if (!VALID_NOTEMPTY(_itemViewsArray, NSArray)) {
        NSMutableArray* mutableItemViewsArray = [NSMutableArray new];
        CGFloat itemY = kProductInfoHeaderLineHeight;
        for (int i = 0; i<self.items.count; i++) {
            RIItemCollection* item = [self.items objectAtIndex:i];

            UIView* itemContent = [UIView new];
            
            CGFloat currentY = 10.0f;

            JAORProductView* productView = [[JAORProductView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                             currentY,
                                                                                             self.scrollView.frame.size.width,
                                                                                             1.0f)];
            [productView setupWithItemCollection:item order:self.order];
            [itemContent addSubview:productView];
            
            currentY += productView.frame.size.height;
            
            if (VALID_NOTEMPTY(self.returnDetailForm, RIForm)) {
                JADynamicForm* dynamicForm = [self.dynamicForms objectAtIndex:i];
                [dynamicForm setFormsY:currentY - 50.0f];
                for (JADynamicField* formView in dynamicForm.formViews) {
                    [formView setX:16.0f];
                    [formView setWidth:self.scrollView.frame.size.width - 16.0f*2];
                    [itemContent addSubview:formView];
                    currentY = CGRectGetMaxY(formView.frame);
                }
                [dynamicForm setValues:self.values replacePlaceHolder:@"__NAME__" forString:item.sku];
            }
            
            currentY += 20.0f;
            
            CGFloat totalHeight = MAX(currentY, productView.height + 20.0f);
            
            itemContent.frame = CGRectMake(0.0f,
                                           itemY,
                                           self.view.frame.size.width,
                                           totalHeight);
            
            if (i != self.items.count-1) {
                //not last one
                UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, totalHeight-1.0f, self.view.frame.size.width - 16.0f*2, 1.0f)];
                separatorView.backgroundColor = JABlack400Color;
                [itemContent addSubview:separatorView];
            }

            itemY += itemContent.frame.size.height;
            
            [mutableItemViewsArray addObject:itemContent];
            
            [self.scrollView addSubview:itemContent];
        }
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                                   itemY)];
        
        self.itemViewsArray = [mutableItemViewsArray copy];
    }
    return _itemViewsArray;
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
    
    self.values = [self.stateInfoValues copy];
    
    if (self.isLoaded) {
        [self loadSubviews];
    } else {
        [self requestForm];
    }
}

- (void)requestForm
{
    [self showLoading];
    [RIForm getForm:@"returndetail" successBlock:^(RIForm *form) {
        [self hideLoading];
        self.isLoaded = YES;
        
        self.returnDetailForm = form;
        
        [self loadSubviews];
    } failureBlock:^(RIApiResponse apiResponse, NSArray *errors) {
        [self hideLoading];
        [self onErrorResponse:apiResponse messages:errors showAsMessage:NO selector:@selector(requestForm) objects:nil];
    }];
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    
    [self removePickerView];
    
    [self loadSubviews];
}

- (void)loadSubviews
{
    for (UIView* itemView in self.itemViewsArray) {
        [itemView removeFromSuperview];
    }
    self.itemViewsArray = nil;
    
    for (int i = 0; i<self.items.count; i++) {
        RIItemCollection* item = [self.items objectAtIndex:i];
        self.values = [[self.dynamicForms objectAtIndex:i] getValuesReplacingPlaceHolder:@"__NAME__" forString:item.sku];
    }
    
    [self.submitView setWidth:self.view.frame.size.width];
    [self.submitView setYBottomAligned:0.f];
    
    [self.scrollView setFrame:CGRectMake(self.bounds.origin.x,
                                         self.bounds.origin.y,
                                         self.bounds.size.width,
                                         self.bounds.size.height - self.submitView.frame.size.height)];
    self.scrollOriginalHeight = self.scrollView.frame.size.height;
    
    [self.titleHeaderView setFrame:CGRectMake(0.0f, 0.0f, self.scrollView.frame.size.width, self.titleHeaderView.frame.size.height)];
    
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
        JADynamicForm* dynamicForm = [self.dynamicForms objectAtIndex:i];
        
        if ([dynamicForm checkErrors]) {
            
            NSArray* message;
            if (VALID_NOTEMPTY(dynamicForm.firstErrorInFields, NSString)) {
                message = [NSArray arrayWithObject:dynamicForm.firstErrorInFields];
            }
            
            [self onErrorResponse:RIApiResponseSuccess messages:message showAsMessage:YES selector:@selector(nextButtonPressed) objects:nil];
            
            return;
        }
        NSDictionary *values = [dynamicForm getValuesReplacingPlaceHolder:@"__NAME__" forString:item.sku];
        if (VALID(self.stateInfoValues, NSMutableDictionary))
        {
            [self.stateInfoValues addEntriesFromDictionary:values];
        }
        if (VALID(self.stateInfoLabels, NSMutableDictionary))
        {
            [self.stateInfoLabels addEntriesFromDictionary:[dynamicForm getFieldLabelsReplacePlaceHolder:@"__NAME__" forString:item.sku]];
        }
    }
    [[JACenterNavigationController sharedInstance] goToOnlineReturnsWaysScreenForItems:self.items order:self.order];
}

#pragma mark - PICKER

- (void)openPicker:(JARadioComponent *)radioComponent
{
    [self showLoading];
    [RIFieldOption getFieldOptionsForApiCall:[radioComponent getApiCallUrl] successBlock:^(NSArray * fieldOptions) {
        [self hideLoading];
        
        self.currentRadioComponent = radioComponent;
        [radioComponent.field setOptions:[NSOrderedSet orderedSetWithArray:fieldOptions]];
        
        NSMutableArray* dataset = [NSMutableArray new];
        
        self.currentRadioComponentDataset = fieldOptions;
        for (RIFieldOption* option in fieldOptions) {
            [dataset addObject:option.label];
        }
        
        NSDictionary* valuesDic = [radioComponent getValues];
        
        [self setupPickerView:dataset selectedRow:[valuesDic objectForKey:radioComponent.field.name]];
    } failureBlock:^(RIApiResponse apiResponse, NSArray * errors) {
        [self hideLoading];
        
    }];
}

- (void)openNumberPicker:(JAListNumberComponent *)listNumberComponent
{
    NSInteger index = listNumberComponent.tag;
    if (index < self.items.count) {
        self.currentListNumberComponent = listNumberComponent;
        
        RIItemCollection* item = [self.items objectAtIndex:index];
        
        NSMutableArray* dataSource = [NSMutableArray new];
        for (int i = 1; i <= [item.quantity integerValue]; i++) {
            [dataSource addObject:[NSString stringWithFormat:@"%ld",(long)i]];
        }
        
        NSDictionary* values = [listNumberComponent getValues];
        [self setupPickerView:dataSource selectedRow:[values objectForKey:listNumberComponent.field.name]];
    }
}

-(void) setupPickerView:(NSArray*)dataSource
            selectedRow:(NSString*)selectedRow
{
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:selectedRow
                    leftButtonTitle:nil];
    
    CGFloat pickerViewHeight = self.view.frame.size.height;
    CGFloat pickerViewWidth = self.view.frame.size.width;
    [self.picker setFrame:CGRectMake(0.0f,
                                     pickerViewHeight,
                                     pickerViewWidth,
                                     pickerViewHeight)];
    [self.view addSubview:self.picker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f,
                                                          0.0f,
                                                          pickerViewWidth,
                                                          pickerViewHeight)];
                     }];
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    if (VALID_NOTEMPTY(self.currentRadioComponent, JARadioComponent)
        && VALID_NOTEMPTY(self.currentRadioComponentDataset, NSArray)
        && selectedRow < [self.currentRadioComponentDataset count]) {
        
        RIFieldOption* selectedObject = [self.currentRadioComponentDataset objectAtIndex:selectedRow];
        
        [self.currentRadioComponent setValue:selectedObject];
        
    } else if(VALID_NOTEMPTY(self.currentListNumberComponent, JAListNumberComponent)) {
        
        [self.currentListNumberComponent setValue:[NSString stringWithFormat:@"%ld", (long)selectedRow+1]];
    }
    
    [self removePickerView];
}

-(void)removePickerView
{
    if(VALID_NOTEMPTY(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }
    
    self.currentRadioComponentDataset = nil;
    self.currentRadioComponent = nil;
    self.currentListNumberComponent = nil;
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
    for (JADynamicForm* dynamicForm in self.dynamicForms) {
        [dynamicForm resignResponder];
    }
}



@end
