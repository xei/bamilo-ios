//
//  JAAddressesViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddressesViewController.h"
#import "JACartListHeaderView.h"
#import "JAUtils.h"
#import "RICheckout.h"
#import "RIAddress.h"
#import "RIForm.h"
#import "RIField.h"
#import "JAButtonWithBlur.h"

@interface JAAddressesViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

// Steps
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepIconLeftConstrain;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLabelWidthConstrain;

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UICollectionView *firstAddressesCollectionView;
@property (nonatomic, strong) UICollectionView *secondAddressesCollectionView;
@property (nonatomic, strong) UIButton *nextStepButton;

@property (nonatomic, strong) NSDictionary *addresses;
@property (nonatomic, strong) NSString *billingAddressId;
@property (nonatomic, strong) NSString *shippingAddressId;

@end

@implementation JAAddressesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showLoading];
    
    [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
        
        self.addresses = adressList;
        if(VALID_NOTEMPTY(self.addresses, NSDictionary))
        {
            RIAddress *billingAddress = [self.addresses objectForKey:@"billing"];
            if(VALID_NOTEMPTY(billingAddress, RIAddress))
            {
                self.billingAddressId = [billingAddress uid];
            }
            
            RIAddress *shippingAddress = [self.addresses objectForKey:@"shipping"];
            if(VALID_NOTEMPTY(shippingAddress, RIAddress))
            {
                self.shippingAddressId = [shippingAddress uid];
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddFirstAddressScreenNotification
                                                                object:nil
                                                              userInfo:nil];
        }
        
        [self finishedLoading];
    } andFailureBlock:^(NSArray *errorMessages) {
        
        [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                    message:[errorMessages componentsJoinedByString:@","]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        
        [self finishedLoading];
    }];
}

- (void) setupViews
{
    CGFloat availableWidth = self.stepView.frame.size.width;
    
    [self.stepLabel setText:@"2. Address"];
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
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f - 21.0f)];
    [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentScrollView setShowsVerticalScrollIndicator:NO];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, 90.0f);
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.contentScrollView.frame.size.width - 12.0f, 26.0f)];
    
    self.firstAddressesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                                           6.0f,
                                                                                           self.contentScrollView.frame.size.width - 12.0f,
                                                                                           26.0f) collectionViewLayout:flowLayout];
    [self.firstAddressesCollectionView setScrollEnabled:NO];
    self.firstAddressesCollectionView.layer.cornerRadius = 5.0f;
    
    UINib *cartListCellNib = [UINib nibWithNibName:@"JACartListCell" bundle:nil];
    [self.firstAddressesCollectionView registerNib:cartListCellNib forCellWithReuseIdentifier:@"cartListCell"];
    
    UINib *cartListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    [self.firstAddressesCollectionView registerNib:cartListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    
    [self.firstAddressesCollectionView setDataSource:self];
    [self.firstAddressesCollectionView setDelegate:self];
    
    [self.contentScrollView addSubview:self.firstAddressesCollectionView];
    [self.view addSubview:self.contentScrollView];
    
    self.secondAddressesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                                            CGRectGetMaxY(self.firstAddressesCollectionView.frame) + 6.0f,
                                                                                            self.contentScrollView.frame.size.width - 12.0f,
                                                                                            26.0f) collectionViewLayout:flowLayout];
    [self.secondAddressesCollectionView setScrollEnabled:NO];
    self.secondAddressesCollectionView.layer.cornerRadius = 5.0f;
    
    [self.secondAddressesCollectionView registerNib:cartListCellNib forCellWithReuseIdentifier:@"cartListCell"];
    [self.secondAddressesCollectionView registerNib:cartListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    
    [self.secondAddressesCollectionView setDataSource:self];
    [self.secondAddressesCollectionView setDelegate:self];
    
    [self.contentScrollView addSubview:self.secondAddressesCollectionView];
    [self.view addSubview:self.contentScrollView];
    
    JAButtonWithBlur *bottomView = [[JAButtonWithBlur alloc] init];
    [bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - 64.0f - bottomView.frame.size.height, bottomView.frame.size.width, bottomView.frame.size.height)];
    [bottomView addButton:@"Next" target:self action:@selector(nextStepButtonPressed)];
    
    [self.view addSubview:bottomView];
}

- (void) finishedLoading
{
    [self hideLoading];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    //    if(VALID_NOTEMPTY(self.cart, RICart))
    //    {
    //        numberOfItemsInSection = [[self.cart cartCount] integerValue];
    //    }
    
    return numberOfItemsInSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    //    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSDictionary) && indexPath.row < [self.cart.cartCount integerValue])
    //    {
    //        NSArray *cartItemsKeys = [self.cart.cartItems allKeys];
    //        NSString *key = [cartItemsKeys objectAtIndex:indexPath.row];
    //        RICartItem *product = [self.cart.cartItems objectForKey:key];
    //
    //        NSString *cellIdentifier = @"cartListCell";
    //
    //        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //
    //        [cell loadWithCartItem:product];
    //
    //        cell.quantityButton.tag = indexPath.row;
    //        [cell.quantityButton addTarget:self
    //                                action:@selector(quantityPressed:)
    //                      forControlEvents:UIControlEventTouchUpInside];
    //
    //        cell.deleteButton.tag = indexPath.row;
    //        [cell.deleteButton addTarget:self
    //                              action:@selector(removeFromCartPressed:)
    //                    forControlEvents:UIControlEventTouchUpInside];
    //
    //        [cell.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
    //
    //        if(indexPath.row < ([self.cart.cartCount integerValue] - 1))
    //        {
    //            [cell.separator setHidden:NO];
    //        }
    //    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader" forIndexPath:indexPath];
        
        [headerView loadHeaderWithText:@"Items"];
        
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSDictionary) && indexPath.row < [self.cart.cartCount integerValue])
    //    {
    //        NSArray *cartItemsKeys = [self.cart.cartItems allKeys];
    //        NSString *key = [cartItemsKeys objectAtIndex:indexPath.row];
    //        RICartItem *product = [self.cart.cartItems objectForKey:key];
    //
    //        JAPDVViewController *pdv = [self.storyboard instantiateViewControllerWithIdentifier:@"pdvViewController"];
    //        pdv.productUrl = product.productUrl;
    //        pdv.fromCatalogue = NO;
    //        pdv.previousCategory = @"Cart";
    //
    //        [self.navigationController pushViewController:pdv
    //                                             animated:YES];
    //    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(6.0f, 0.0f, 0.0f, 0.0f);
}

-(void)nextStepButtonPressed
{
    
}

- (void) chooseBillingAndShippingAddressesAndGoToNextStepAction
{
    [self showLoading];
    
    [RICheckout getBillingAddressFormWithSuccessBlock:^(RICheckout *checkout) {
        NSLog(@"Get billing address form with success");
        RIForm *billingForm = checkout.billingAddressForm;
        
        for (RIField *field in [billingForm fields])
        {
            if([@"billingForm[billingAddressId]" isEqualToString:[field name]])
            {
                field.value = self.billingAddressId;
            }
            else if([@"billingForm[shippingAddressId]" isEqualToString:[field name]])
            {
                field.value = self.shippingAddressId;
            }
            else if([@"billingForm[shippingAddressDifferent" isEqualToString:[field name]])
            {
                field.value = [self.billingAddressId isEqualToString:self.shippingAddressId] ? @"0" : @":1";
            }
        }
        
        [RICheckout setBillingAddress:billingForm successBlock:^(RICheckout *checkout) {
            NSLog(@"Set billing address form with success");
            
            UIViewController *controller = [JAUtils getCheckoutNextStepViewController:checkout.nextStep inStoryboard:self.storyboard];
            [self.navigationController pushViewController:controller
                                                 animated:YES];
            [self hideLoading];
        } andFailureBlock:^(NSArray *errorMessages) {
            NSLog(@"Failed to set billing address form");
            [self hideLoading];
        }];
    } andFailureBlock:^(NSArray *errorMessages) {
        NSLog(@"Failed to get billing address form");
        [self hideLoading];
    }];
}

@end
