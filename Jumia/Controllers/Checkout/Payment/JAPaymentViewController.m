//
//  JAPaymentViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPaymentViewController.h"
#import "JACartListHeaderView.h"
#import "JAButtonWithBlur.h"
#import "JAPaymentCell.h"
#import "RICheckout.h"

@interface JAPaymentViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

// Steps
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepIconLeftConstrain;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLabelWidthConstrain;

// Payment methods
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UICollectionView *collectionView;

// Bottom view
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@property (strong, nonatomic) RICheckout *checkout;
@property (strong, nonatomic) RIPaymentMethodForm* paymentMethodForm;
@property (strong, nonatomic) NSArray *paymentMethods;
@property (strong, nonatomic) NSIndexPath *collectionViewIndexSelected;
@property (strong, nonatomic) RIPaymentMethodFormOption* selectedPaymentMethod;

@end

@implementation JAPaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.title = @"Checkout";
    
    [self setupViews];
    
    [self showLoading];
    [RICheckout getPaymentMethodFormWithSuccessBlock:^(RICheckout *checkout)
     {
         self.checkout = checkout;
         self.paymentMethodForm = checkout.paymentMethodForm;
         
         // LIST OF AVAILABLE PAYMENT METHODS
         self.paymentMethods = [RIPaymentMethodForm getPaymentMethodsInForm:checkout.paymentMethodForm];
         
         [self finishedLoadingPaymentMethods];
     } andFailureBlock:^(NSArray *errorMessages)
     {
         [self finishedLoadingPaymentMethods];
     }];
}

-(void)setupViews
{
    CGFloat availableWidth = self.stepView.frame.size.width;
    
    [self.stepLabel setText:@"4. Payment"];
    [self.stepLabel sizeToFit];
    
    CGFloat realWidth = self.stepIcon.frame.size.width + 6.0f + self.stepLabel.frame.size.width;
    
    if(availableWidth >= realWidth)
    {
        CGFloat xStepIconValue = (availableWidth - realWidth) / 2;
        self.stepIconLeftConstrain.constant = xStepIconValue;
        self.stepLabelWidthConstrain.constant = self.stepLabel.frame.size.width;
    }
    else
    {
        self.stepLabelWidthConstrain.constant = (availableWidth - self.stepIcon.frame.size.width - 6.0f);
        self.stepIconLeftConstrain.constant = 0.0f;
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, self.view.frame.size.width, self.view.frame.size.height - 21.0f - 64.0f)];
    
    UICollectionViewFlowLayout* collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [collectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionViewFlowLayout setItemSize:CGSizeZero];
    [collectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    UINib *paymentListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    UINib *paymentListCellNib = [UINib nibWithNibName:@"JAPaymentCell" bundle:nil];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                             6.0f,
                                                                             self.scrollView.frame.size.width - 12.0f,
                                                                             26.0f) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.layer.cornerRadius = 5.0f;
    [self.collectionView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.collectionView registerNib:paymentListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"paymentListHeader"];
    [self.collectionView registerNib:paymentListCellNib forCellWithReuseIdentifier:@"paymentListCell"];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setScrollEnabled:NO];
    
    [self.scrollView addSubview:self.collectionView];
    [self.view addSubview:self.scrollView];
    
    self.bottomView = [[JAButtonWithBlur alloc] init];
    [self.bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - 64.0f - self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
    [self.bottomView addButton:@"Next" target:self action:@selector(nextStepButtonPressed)];
    
    [self.view addSubview:self.bottomView];
}

-(void)finishedLoadingPaymentMethods
{
    self.collectionViewIndexSelected = [NSIndexPath indexPathForItem:[RIPaymentMethodForm getSelectedPaymentMethodsInForm:self.paymentMethodForm] inSection:0];
    
    [self reloadCollectionView];
    
    [self hideLoading];
}

-(void)reloadCollectionView
{
    if(VALID_NOTEMPTY(self.paymentMethods, NSArray))
    {
        CGFloat collectionViewHeight = 26.0f + (([self.paymentMethods count] - 1) * 44.0f);
        
        if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath))
        {
            collectionViewHeight += 84.0f;
        }
        
        [UIView animateWithDuration:0.5f
                         animations:^{
                             [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                                                      self.collectionView.frame.origin.y,
                                                                      self.collectionView.frame.size.width,
                                                                      collectionViewHeight)];
                         }];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                                   self.collectionView.frame.origin.y + collectionViewHeight + self.bottomView.frame.size.height + 6.0f)];
        
    }
    
    [self.collectionView reloadData];
}

-(void)nextStepButtonPressed
{
    [self showLoading];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[RIPaymentMethodForm getParametersForForm:self.paymentMethodForm]];
    
    [RICheckout setPaymentMethod:self.paymentMethodForm
                      parameters:parameters
                    successBlock:^(RICheckout *checkout) {
                        NSLog(@"Success setting payment method");
                        [self hideLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
                        NSLog(@"Failed setting payment method");
                        [self hideLoading];        
    }];
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeForItemAtIndexPath = CGSizeZero;
    
    if(collectionView == self.collectionView)
    {
        // Payment method cell
        if(indexPath.row == self.collectionViewIndexSelected.row)
        {
            sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 84.0f);
        }
        else
        {
            sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 44.0f);
        }
    }
    
    return sizeForItemAtIndexPath;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize referenceSizeForHeaderInSection = CGSizeZero;
    if(collectionView == self.collectionView)
    {
        referenceSizeForHeaderInSection = CGSizeMake(self.collectionView.frame.size.width, 26.0f);
    }
    
    return referenceSizeForHeaderInSection;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.paymentMethods, NSArray))
    {
        numberOfItemsInSection = [self.paymentMethods count];
    }
    return numberOfItemsInSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.paymentMethods, NSArray))
    {
        // Payment method title cell
        
        RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
        if(VALID_NOTEMPTY(paymentMethod, RIPaymentMethodFormOption))
        {
            NSString *cellIdentifier = @"paymentListCell";
            JAPaymentCell *paymentListCell = (JAPaymentCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            [paymentListCell loadWithPaymentMethod:paymentMethod];
            
            [paymentListCell deselectPaymentMethod];
            if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath) && indexPath.row == self.collectionViewIndexSelected.row)
            {
                [paymentListCell selectPaymentMethod];
            }
            
            if(indexPath.row == ([self.paymentMethods count] - 1))
            {
                [paymentListCell.separator setHidden:YES];
            }
            
            cell = paymentListCell;
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"paymentListHeader" forIndexPath:indexPath];
        
        if(collectionView == self.collectionView)
        {
            [headerView loadHeaderWithText:@"Payment"];
        }
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.paymentMethods, NSArray))
    {
        if(indexPath.row != self.collectionViewIndexSelected.row && indexPath.row < [self.paymentMethods count])
        {
            // Payment method title cell
            self.selectedPaymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
            
            if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath))
            {
                JAPaymentCell *oldPaymentCell = (JAPaymentCell*) [collectionView cellForItemAtIndexPath:self.collectionViewIndexSelected];
                [oldPaymentCell deselectPaymentMethod];
            }
            
            self.collectionViewIndexSelected = indexPath;
            
            JAPaymentCell *paymentCell = (JAPaymentCell*)[collectionView cellForItemAtIndexPath:indexPath];
            [paymentCell selectPaymentMethod];
            
            [self reloadCollectionView];
        }
    }
}

@end
