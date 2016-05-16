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

@interface JAORReasonsViewController () <JADynamicFormDelegate, JAPickerDelegate>

@property (nonatomic, strong) JAProductInfoHeaderLine *titleHeaderView;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) NSArray* itemViewsArray;
@property (nonatomic, strong) RIForm* returnDetailForm;
@property (nonatomic, strong) JAPicker* picker;
@property (nonatomic, strong) NSArray* dynamicForms;

@property (nonatomic, assign) BOOL isLoaded;

@property (nonatomic, strong) JAListNumberComponent* currentListNumberComponent;
@property (nonatomic, strong) JARadioComponent* currentRadioComponent;
@property (nonatomic, strong) NSArray* currentRadioComponentDataset;

@property (nonatomic, strong) UIView* bottomView;
@property (nonatomic, strong) UIView* bottomSeparatorView;
@property (nonatomic, strong) JAButton* bottomButtom;

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

- (NSArray*)itemViewsArray
{
    if (!VALID_NOTEMPTY(_itemViewsArray, NSArray)) {
        NSMutableArray* mutableItemViewsArray = [NSMutableArray new];
        NSMutableArray* mutableDynamicForms = [NSMutableArray new];
        CGFloat itemY = kProductInfoHeaderLineHeight;
        for (int i = 0; i<self.items.count; i++) {
            RIItemCollection* item = [self.items objectAtIndex:i];
            UIView* itemContent = [UIView new];

            CGFloat currentY = 10.0f;
            
            CGSize imageSize = CGSizeMake(68.0f, 85.0f);
            
            //details inside itemCell
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f,
                                                                                   currentY,
                                                                                   imageSize.width,
                                                                                   imageSize.height)];
            
            [imageView setImageWithURL:[NSURL URLWithString:item.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
            
            UILabel* brandLabel = [UILabel new];
            brandLabel.font = JABodyFont;
            brandLabel.textColor = JABlack800Color;
            brandLabel.textAlignment = NSTextAlignmentLeft;
            brandLabel.text = item.brand;
            [brandLabel sizeToFit];
            brandLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 6.0f,
                                          currentY,
                                          self.view.frame.size.width - CGRectGetMaxX(imageView.frame) + 6.0f - 16.0f,
                                          brandLabel.frame.size.height);
            [itemContent addSubview:brandLabel];
            
            currentY = CGRectGetMaxY(brandLabel.frame);
            
            UILabel* nameLabel = [UILabel new];
            nameLabel.font = JAHEADLINEFont;
            nameLabel.textColor = JABlackColor;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.text = item.name;
            [nameLabel sizeToFit];
            nameLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 6.0f,
                                         currentY,
                                         self.view.frame.size.width - CGRectGetMaxX(imageView.frame) + 6.0f - 16.0f,
                                         nameLabel.frame.size.height);
            [itemContent addSubview:nameLabel];
            
            currentY = CGRectGetMaxY(nameLabel.frame);
            
            UILabel* quantityLabel = [UILabel new];
            quantityLabel.font = JABodyFont;
            quantityLabel.textColor = JABlack800Color;
            quantityLabel.textAlignment = NSTextAlignmentLeft;
            quantityLabel.text = [NSString stringWithFormat:STRING_QUANTITY, [item.quantity stringValue]];
            [quantityLabel sizeToFit];
            quantityLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 6.0f,
                                             currentY,
                                             self.view.frame.size.width - CGRectGetMaxX(imageView.frame) + 6.0f - 16.0f,
                                             quantityLabel.frame.size.height);
            [itemContent addSubview:quantityLabel];
            
            currentY = CGRectGetMaxY(quantityLabel.frame);
            
            UILabel* orderNumberLabel = [UILabel new];
            orderNumberLabel.font = JABodyFont;
            orderNumberLabel.textColor = JABlackColor;
            orderNumberLabel.text = [NSString stringWithFormat:STRING_ORDER_NO, self.order.orderId];
            orderNumberLabel.textAlignment = NSTextAlignmentLeft;
            [orderNumberLabel sizeToFit];
            orderNumberLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 6.0f,
                                                currentY,
                                                self.view.frame.size.width - CGRectGetMaxX(imageView.frame) + 6.0f - 16.0f,
                                                orderNumberLabel.frame.size.height);
            [itemContent addSubview:orderNumberLabel];
            
            currentY = CGRectGetMaxY(orderNumberLabel.frame);
            
            if (VALID_NOTEMPTY(self.returnDetailForm, RIForm)) {
                JADynamicForm* dynamicForm = [[JADynamicForm alloc] initWithForm:self.returnDetailForm startingPosition:currentY - 10.0f];
                dynamicForm.delegate = self;
                for (UIView* formView in dynamicForm.formViews) {
                    [formView setWidth:self.scrollView.frame.size.width - 16.0f*2];
                    [formView setX:16.0f];
                    [itemContent addSubview:formView];
                    currentY = CGRectGetMaxY(formView.frame);
                    if ([formView isKindOfClass:[JAListNumberComponent class]]) {
                        formView.tag = i;
                    }
                }
                [mutableDynamicForms addObject:dynamicForm];
            }
            
            currentY += 20.0f;
            
            [itemContent addSubview:imageView];
            
            CGFloat totalHeight = MAX(currentY, imageSize.height + 20.0f);
            
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
        self.dynamicForms = [mutableDynamicForms copy];
    }
    return _itemViewsArray;
}

- (UIView*)bottomView
{
    if (!VALID(_bottomView, UIView)) {
        CGFloat bottomViewHeight = 88.0f;
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIView*)bottomSeparatorView
{
    if (!VALID(_bottomSeparatorView, UIView)) {
        _bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        self.bottomView.frame.size.width,
                                                                        1.0f)];
        _bottomSeparatorView.backgroundColor = JABlack400Color;
        [self.bottomView addSubview:_bottomSeparatorView];
    }
    return _bottomSeparatorView;
}

-(JAButton*)bottomButtom
{
    if (!VALID(_bottomButtom, JAButton)) {
        _bottomButtom = [[JAButton alloc] initButtonWithTitle:STRING_CONTINUE target:self action:@selector(nextButtonPressed)];
        [_bottomButtom setFrame:CGRectMake(16.0f, 20.0f, self.view.frame.size.width - 16.0f*2, 48.0f)];
        [self.bottomView addSubview:_bottomButtom];
    }
    return _bottomButtom;
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
        [RIForm getForm:@"returndetail" successBlock:^(RIForm *form) {
            [self hideLoading];
            self.isLoaded = YES;
            
            self.returnDetailForm = form;
            
            [self loadSubviews];
        } failureBlock:^(RIApiResponse apiResponse, NSArray *errors) {
            [self hideLoading];
        }];
    }
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    
    [self removePickerView];
    for (UIView* itemView in self.itemViewsArray) {
        [itemView removeFromSuperview];
    }
    self.itemViewsArray = nil;
    
    [self loadSubviews];
}

- (void)loadSubviews
{
    [self.scrollView setFrame:self.bounds];
    
    [self.titleHeaderView setFrame:CGRectMake(0.0f, 0.0f, self.scrollView.frame.size.width, self.titleHeaderView.frame.size.height)];
    
    for (UIView* itemView in self.itemViewsArray) {
        if (RI_IS_RTL) {
            [itemView flipAllSubviews];
        }
    }
    
    [self.bottomView setWidth:self.view.frame.size.width];
    [self.bottomView setY:self.view.frame.size.height - self.bottomView.frame.size.height];
    [self.bottomSeparatorView setWidth:self.bottomView.frame.size.width];
    [self.bottomButtom setWidth:self.bottomView.frame.size.width];
    
    if (RI_IS_RTL) {
        [self.titleHeaderView flipAllSubviews];
    }
}

- (void)nextButtonPressed
{
    NSMutableDictionary* results = [NSMutableDictionary new];
    for (int i = 0; i<self.items.count; i++) {
        RIItemCollection* item = [self.items objectAtIndex:i];
        JADynamicForm* dynamicForm = [self.dynamicForms objectAtIndex:i];
        
        if ([dynamicForm checkErrors]) {
            
            NSArray* message;
            if (VALID_NOTEMPTY(dynamicForm.firstErrorInFields, NSString)) {
                message = [NSArray arrayWithObject:dynamicForm.firstErrorInFields];
            }
            
            [self onErrorResponse:RIApiResponseSuccess messages:message showAsMessage:YES selector:@selector(nextButtonPressed) objects:nil];
            
            results = nil;
            break;
        }
        
        [results setObject:[dynamicForm getValues] forKey:item.sku];
    }
    
    if (VALID_NOTEMPTY(results, NSMutableDictionary)) {
        [[JACenterNavigationController sharedInstance] goToOnlineReturnsWaysScreenForItems:self.items order:self.order];
    }
}

#pragma mark - PICKER

- (void)openPicker:(JARadioComponent *)radioComponent
{
    [self showLoading];
    [RIFieldOption getFieldOptionsForApiCall:[radioComponent getApiCallUrl] successBlock:^(NSArray * fieldOptions) {
        [self hideLoading];
        
        self.currentRadioComponent = radioComponent;
        
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



@end
