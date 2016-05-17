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

@interface JAORWaysViewController () <JADynamicFormDelegate>

@property (nonatomic, strong) JAProductInfoHeaderLine *titleHeaderView;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIView* itemViewsContentView;
@property (nonatomic, strong) NSArray* itemViewsArray;
@property (nonatomic, strong) UIView* formContentView;
@property (nonatomic, strong) RIForm* returnWayForm;
@property (nonatomic, strong) JADynamicForm* dynamicForm;

@property (nonatomic, assign) BOOL isLoaded;

@property (nonatomic, strong) UIView* bottomView;
@property (nonatomic, strong) UIView* bottomSeparatorView;
@property (nonatomic, strong) JAButton* bottomButtom;


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
            
            [itemContent addSubview:imageView];
            
            CGFloat totalHeight = MAX(currentY, imageSize.height);
            
            totalHeight += 20;
            
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
            
            [_itemViewsContentView setHeight:itemY];
            [_itemViewsContentView addSubview:itemContent];
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
