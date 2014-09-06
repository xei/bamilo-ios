//
//  JAShippingViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShippingViewController.h"
#import "JAButtonWithBlur.h"
#import "JACartListHeaderView.h"
#import "JAShippingCell.h"
#import "JAUtils.h"
#import "RICheckout.h"

@interface JAShippingViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

// Steps
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepIconLeftConstrain;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLabelWidthConstrain;

// Shipping methods
@property (strong, nonatomic) UICollectionView *collectionView;

// Bottom view
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@property (strong, nonatomic) RIShippingMethodForm* shippingMethodForm;
@property (strong, nonatomic) NSArray *shippingMethods;
@property (strong, nonatomic) NSString *selectedShippingMethod;
@property (strong, nonatomic) NSIndexPath *collectionViewIndexSelected;

@end

@implementation JAShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.title = @"Checkout";
    
    [self setupViews];
    
    [self showLoading];
    [RICheckout getShippingMethodFormWithSuccessBlock:^(RICheckout *checkout)
     {
         self.shippingMethodForm = checkout.shippingMethodForm;
         
         // LIST OF AVAILABLE SHIPPING METHODS
         self.shippingMethods = [RIShippingMethodForm getShippingMethods:checkout.shippingMethodForm];
         
         [self finishedLoadingShippingMethods];
     } andFailureBlock:^(NSArray *errorMessages)
     {
         [self finishedLoadingShippingMethods];
     }];
}

- (void) setupViews
{
    CGFloat availableWidth = self.stepView.frame.size.width;
    
    [self.stepLabel setText:@"3. Shipping"];
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
    
    UICollectionViewFlowLayout* collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [collectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionViewFlowLayout setItemSize:CGSizeZero];
    [collectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    UINib *shippingListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    UINib *shippingListCellNib = [UINib nibWithNibName:@"JAShippingCell" bundle:nil];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                             27.0f,
                                                                             self.view.frame.size.width - 12.0f,
                                                                             26.0f) collectionViewLayout:collectionViewFlowLayout];
    [self.collectionView setScrollEnabled:NO];
    self.collectionView.layer.cornerRadius = 5.0f;
    [self.collectionView registerNib:shippingListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"shippingListHeader"];
    [self.collectionView registerNib:shippingListCellNib forCellWithReuseIdentifier:@"shippingListCell"];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.view addSubview:self.collectionView];
    
    self.bottomView = [[JAButtonWithBlur alloc] init];
    [self.bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - 64.0f - self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
    [self.bottomView addButton:@"Next" target:self action:@selector(nextStepButtonPressed)];
    
    [self.view addSubview:self.bottomView];
}

-(void)finishedLoadingShippingMethods
{
    if(VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                                 self.collectionView.frame.origin.y,
                                                 self.collectionView.frame.size.width,
                                                 26.0f + ([self.shippingMethods count] * 44.0f))];
        
        NSString *selectedValue = nil;
        for (RIShippingMethodFormField *field in [self.shippingMethodForm fields])
        {
            if([@"shippingMethodForm[shipping_method]" isEqualToString:[field name]])
            {
                selectedValue = [field value];
                break;
            }
        }
        
        if(VALID_NOTEMPTY(selectedValue, NSString))
        {
            for(int i = 0; i < [self.shippingMethods count]; i++)
            {
                NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:i];
                NSArray *shippingMethodKeys = [shippingMethod allKeys];
                if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
                {
                    if([selectedValue isEqualToString:[shippingMethodKeys objectAtIndex:0]])
                    {
                        self.collectionViewIndexSelected = [NSIndexPath indexPathForItem:i inSection:0];
                        break;
                    }
                }
            }
        }
        [self.collectionView reloadData];
    }
    [self hideLoading];
}

-(void)nextStepButtonPressed
{
    if(VALID_NOTEMPTY(self.selectedShippingMethod, NSString))
    {
        for (RIShippingMethodFormField *field in [self.shippingMethodForm fields])
        {
            if([@"shippingMethodForm[shipping_method]" isEqualToString:[field name]])
            {
                field.value = self.selectedShippingMethod;
            }
        }
        
        [self showLoading];
        [RICheckout setShippingMethod:self.shippingMethodForm
                         successBlock:^(RICheckout *checkout) {
                             
                             [self hideLoading];
                             
                             [JAUtils getCheckoutNextStepViewController:checkout.nextStep inStoryboard:self.storyboard];
                             
                         } andFailureBlock:^(NSArray *errorMessages) {
                             [self hideLoading];
                         }];
    }
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeForItemAtIndexPath = CGSizeZero;
    
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.shippingMethods, NSArray) && indexPath.row < [self.shippingMethods count])
    {
        NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:indexPath.row];
        NSArray *shippingMethodKeys = [shippingMethod allKeys];
        if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
        {
            NSString *shippingMethodKey = [shippingMethodKeys objectAtIndex:0];
            NSArray *options = [RIShippingMethodForm getOptionsForScenario:shippingMethodKey inForm:self.shippingMethodForm];
            if(VALID_NOTEMPTY(options, NSArray))
            {
                sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 44.0f);
            }
            else
            {
                sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 44.0f);
            }
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
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        numberOfItemsInSection = [self.shippingMethods count];
    }
    return numberOfItemsInSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.shippingMethods, NSArray) && indexPath.row < [self.shippingMethods count])
    {
        NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:indexPath.row];
        
        NSArray *shippingMethodKeys = [shippingMethod allKeys];
        if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
        {
            NSString *shippingMethodKey = [shippingMethodKeys objectAtIndex:0];
            NSString *cellIdentifier = @"shippingListCell";
            JAShippingCell *shippingCell = (JAShippingCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            [shippingCell loadWithShippingMethod:[shippingMethod objectForKey:shippingMethodKey] andOptions:nil];

            [shippingCell deselectAddress];
            if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath) && indexPath.row == self.collectionViewIndexSelected.row)
            {
                [shippingCell selectAddress];
            }
            
            if([self.shippingMethods count] == (indexPath.row + 1))
            {
                [shippingCell.separator setHidden:YES];
            }
            
            cell = shippingCell;
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"shippingListHeader" forIndexPath:indexPath];
        
        if(collectionView == self.collectionView)
        {
            [headerView loadHeaderWithText:@"Shipping Methods"];
        }
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.shippingMethods, NSArray) && indexPath.row < [self.shippingMethods count])
    {
        
        NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:indexPath.row];
        
        NSArray *shippingMethodKeys = [shippingMethod allKeys];
        if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
        {
            self.selectedShippingMethod = [shippingMethodKeys objectAtIndex:0];
            
            
            if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath))
            {
                JAShippingCell *oldShippingCell = (JAShippingCell*) [collectionView cellForItemAtIndexPath:self.collectionViewIndexSelected];
                [oldShippingCell deselectAddress];
            }
            self.collectionViewIndexSelected = indexPath;
            
            JAShippingCell *shippingCell = (JAShippingCell*)[collectionView cellForItemAtIndexPath:indexPath];
            [shippingCell selectAddress];
        }
    }
}

@end
