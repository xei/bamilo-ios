//
//  JAAddressesViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddressesViewController.h"
#import "JACartListHeaderView.h"
#import "JAAddressCell.h"
#import "JASwitchCell.h"
#import "JAAddNewAddressCell.h"
#import "JAUtils.h"
#import "RICheckout.h"
#import "RIAddress.h"
#import "RIForm.h"
#import "RIField.h"
#import "JAButtonWithBlur.h"
#import "RICustomer.h"

@interface JAAddressesViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

// Steps
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepIconLeftConstrain;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLabelWidthConstrain;

// Addresses
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (assign, nonatomic) BOOL useSameAddressAsBillingAndShipping;
@property (strong, nonatomic) NSDictionary *addresses;
@property (strong, nonatomic) RIAddress *shippingAddress;
@property (strong, nonatomic) RIAddress *billingAddress;

@property (strong, nonatomic) UICollectionView *firstAddressesCollectionView;
@property (strong, nonatomic) NSArray *firstCollectionViewAddresses;
@property (strong, nonatomic) NSIndexPath *firstCollectionViewIndexSelected;

@property (strong, nonatomic) UICollectionView *secondAddressesCollectionView;
@property (strong, nonatomic) NSArray *secondCollectionViewAddresses;
@property (strong, nonatomic) NSIndexPath *secondCollectionViewIndexSelected;

// Bottom view
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@end

@implementation JAAddressesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Address";
    self.navBarLayout.title = STRING_CHECKOUT;
    
    self.navBarLayout.showCartButton = NO;
    
    self.firstCollectionViewAddresses = [[NSArray alloc] init];
    self.secondCollectionViewAddresses = [[NSArray alloc] init];
    
    self.firstCollectionViewIndexSelected = nil;
    self.secondCollectionViewIndexSelected = nil;
    
    self.useSameAddressAsBillingAndShipping = YES;
    
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
            [self hideLoading];
            
            self.shippingAddress = [self.addresses objectForKey:@"shipping"];
            self.billingAddress = [self.addresses objectForKey:@"billing"];
            
            if([[self.shippingAddress uid] isEqualToString:[self.billingAddress uid]])
            {
                self.useSameAddressAsBillingAndShipping = YES;
            }
            else
            {
                self.useSameAddressAsBillingAndShipping = NO;
            }
            
            [self finishedLoadingAddresses];
        }
        else
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }
        
    } andFailureBlock:^(NSArray *errorMessages) {
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"NativeCheckoutError" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutError]
                                                  data:[trackingDictionary copy]];
        
        [self showMessage:[errorMessages componentsJoinedByString:@","] success:NO];

        [self hideLoading];
        [self finishedLoadingAddresses];
    }];
}

- (void) setupViews
{
    CGFloat availableWidth = self.stepView.frame.size.width;
    
    [self.stepLabel setText:STRING_CHECKOUT_ADDRESS];
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
    
    UICollectionViewFlowLayout* firstAddressesCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [firstAddressesCollectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [firstAddressesCollectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [firstAddressesCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [firstAddressesCollectionViewFlowLayout setItemSize:CGSizeZero];
    [firstAddressesCollectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    UINib *addressListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    UINib *addressListCellNib = [UINib nibWithNibName:@"JAAddressCell" bundle:nil];
    UINib *addAddressListCellNib = [UINib nibWithNibName:@"JAAddNewAddressCell" bundle:nil];
    UINib *switchListCellNib = [UINib nibWithNibName:@"JASwitchCell" bundle:nil];
    
    self.firstAddressesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                                           6.0f,
                                                                                           self.contentScrollView.frame.size.width - 12.0f,
                                                                                           26.0f) collectionViewLayout:firstAddressesCollectionViewFlowLayout];
    [self.firstAddressesCollectionView setScrollEnabled:NO];
    self.firstAddressesCollectionView.layer.cornerRadius = 5.0f;
    [self.firstAddressesCollectionView registerNib:addressListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    [self.firstAddressesCollectionView registerNib:addressListCellNib forCellWithReuseIdentifier:@"addressListCell"];
    [self.firstAddressesCollectionView registerNib:addAddressListCellNib forCellWithReuseIdentifier:@"addAddressListCell"];
    [self.firstAddressesCollectionView registerNib:switchListCellNib forCellWithReuseIdentifier:@"switchListCell"];
    [self.firstAddressesCollectionView setDataSource:self];
    [self.firstAddressesCollectionView setDelegate:self];
    [self.contentScrollView addSubview:self.firstAddressesCollectionView];
    
    UICollectionViewFlowLayout* secondAddressesCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [secondAddressesCollectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [secondAddressesCollectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [secondAddressesCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [secondAddressesCollectionViewFlowLayout setItemSize:CGSizeZero];
    [secondAddressesCollectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    self.secondAddressesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                                            CGRectGetMaxY(self.firstAddressesCollectionView.frame) + 5.0f,
                                                                                            self.contentScrollView.frame.size.width - 12.0f,
                                                                                            26.0f) collectionViewLayout:secondAddressesCollectionViewFlowLayout];
    [self.secondAddressesCollectionView setScrollEnabled:NO];
    self.secondAddressesCollectionView.layer.cornerRadius = 5.0f;
    [self.secondAddressesCollectionView registerNib:addressListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    [self.secondAddressesCollectionView registerNib:addressListCellNib forCellWithReuseIdentifier:@"addressListCell"];
    [self.secondAddressesCollectionView registerNib:addAddressListCellNib forCellWithReuseIdentifier:@"addAddressListCell"];
    [self.secondAddressesCollectionView setDataSource:self];
    [self.secondAddressesCollectionView setDelegate:self];
    [self.contentScrollView addSubview:self.secondAddressesCollectionView];
    
    [self.view addSubview:self.contentScrollView];
    
    self.bottomView = [[JAButtonWithBlur alloc] init];
    [self.bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - 64.0f - self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
    [self.bottomView addButton:STRING_NEXT target:self action:@selector(nextStepButtonPressed)];
    
    [self.view addSubview:self.bottomView];
}

-(void)finishedLoadingAddresses
{
    NSInteger billingAddressIndex = 0;
    if(self.useSameAddressAsBillingAndShipping)
    {
        self.billingAddress = self.shippingAddress;
        self.firstCollectionViewAddresses = [NSArray arrayWithObject:self.shippingAddress];
        
        NSMutableArray *addresses = [[NSMutableArray alloc] init];
        
        RIAddress *addressToAdd = [self.addresses objectForKey:@"shipping"];
        if(VALID_NOTEMPTY(addressToAdd, RIAddress) && ![[addressToAdd uid] isEqualToString:[self.shippingAddress uid]] && ![self checkIfAddressIsAdded:addressToAdd addresses:addresses])
        {
            [addresses addObject:addressToAdd];
        }
        
        addressToAdd = [self.addresses objectForKey:@"billing"];
        if(VALID_NOTEMPTY(addressToAdd, RIAddress) && ![[addressToAdd uid] isEqualToString:[self.shippingAddress uid]] && ![self checkIfAddressIsAdded:addressToAdd addresses:addresses])
        {
            [addresses addObject:addressToAdd];
        }
        if(VALID_NOTEMPTY([self.addresses objectForKey:@"other"], NSArray))
        {
            for (RIAddress *address in [self.addresses objectForKey:@"other"]) {
                if(VALID_NOTEMPTY(address, RIAddress) && ![[address uid] isEqualToString:[self.shippingAddress uid]] && ![self checkIfAddressIsAdded:address addresses:addresses])
                {
                    [addresses addObject:address];
                }
            }
        }
        self.secondCollectionViewAddresses = [addresses copy];
    }
    else
    {
        NSMutableArray *addresses = [[NSMutableArray alloc] init];
        [addresses addObject:self.shippingAddress];
            
        if(VALID_NOTEMPTY(self.billingAddress, RIAddress) && ![self checkIfAddressIsAdded:self.billingAddress addresses:addresses])
        {
            billingAddressIndex = 1;
            [addresses addObject:self.billingAddress];
        }
      
        RIAddress *addressToAdd = [self.addresses objectForKey:@"shipping"];
        if(VALID_NOTEMPTY(addressToAdd, RIAddress) && ![self checkIfAddressIsAdded:addressToAdd addresses:addresses])
        {
            [addresses addObject:addressToAdd];
        }
        
        addressToAdd = [self.addresses objectForKey:@"billing"];
        if(VALID_NOTEMPTY(addressToAdd, RIAddress) && ![self checkIfAddressIsAdded:addressToAdd addresses:addresses])
        {
            [addresses addObject:addressToAdd];
        }
        
        if(VALID_NOTEMPTY([self.addresses objectForKey:@"other"], NSArray))
        {
            for (RIAddress *address in [self.addresses objectForKey:@"other"]) {
                if(![self checkIfAddressIsAdded:address addresses:addresses])
                {
                    [addresses addObject:address];
                }
            }
        }
        
        self.firstCollectionViewAddresses = [addresses copy];
        self.secondCollectionViewAddresses = [addresses copy];
    }
    
    self.firstCollectionViewIndexSelected = [NSIndexPath indexPathForItem:0 inSection:0];
    self.secondCollectionViewIndexSelected = nil;
    if(!self.useSameAddressAsBillingAndShipping)
    {
        self.secondCollectionViewIndexSelected = [NSIndexPath indexPathForItem:billingAddressIndex inSection:0];
    }
    
    if(VALID_NOTEMPTY(self.firstCollectionViewAddresses, NSArray))
    {
        if(self.useSameAddressAsBillingAndShipping)
        {
            [self.firstAddressesCollectionView setFrame:CGRectMake(self.firstAddressesCollectionView.frame.origin.x,
                                                                   self.firstAddressesCollectionView.frame.origin.y,
                                                                   self.firstAddressesCollectionView.frame.size.width,
                                                                   26.0f + ([self.firstCollectionViewAddresses count] * 100.0f) + 51.0f)];
        }
        else
        {
            [self.firstAddressesCollectionView setFrame:CGRectMake(self.firstAddressesCollectionView.frame.origin.x,
                                                                   self.firstAddressesCollectionView.frame.origin.y,
                                                                   self.firstAddressesCollectionView.frame.size.width,
                                                                   26.0f + ([self.firstCollectionViewAddresses count] * 100.0f) + 95.0f)];
        }
    }
    [self.firstAddressesCollectionView reloadData];
    
    if(VALID_NOTEMPTY(self.secondCollectionViewAddresses, NSArray))
    {
        [self.secondAddressesCollectionView setFrame:CGRectMake(self.secondAddressesCollectionView.frame.origin.x,
                                                                CGRectGetMaxY(self.firstAddressesCollectionView.frame) + 5.0f,
                                                                self.secondAddressesCollectionView.frame.size.width,
                                                                26.0f + ([self.secondCollectionViewAddresses count] * 100.0f) + 44.0f)];
    }
    else
    {
        [self.secondAddressesCollectionView setFrame:CGRectMake(self.secondAddressesCollectionView.frame.origin.x,
                                                                CGRectGetMaxY(self.firstAddressesCollectionView.frame) + 5.0f,
                                                                self.secondAddressesCollectionView.frame.size.width,
                                                                70.0f)];
    }
    [self.secondAddressesCollectionView reloadData];
    
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, CGRectGetMaxY(self.secondAddressesCollectionView.frame) + self.bottomView.frame.size.height)];
}

-(BOOL)checkIfAddressIsAdded:(RIAddress*)addressToAdd addresses:(NSArray*)addresses
{
    BOOL checkIfAddressIsAdded = NO;
    
    for(RIAddress *address in addresses)
    {
        if([[addressToAdd uid] isEqualToString:[address uid]])
        {
            checkIfAddressIsAdded = YES;
            break;
        }
    }
    return checkIfAddressIsAdded;
}

-(void)editAddressButtonPressed:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    
    UIView *view = [sender superview];
    if(VALID_NOTEMPTY(view, UIView))
    {
        UIView *cellView = [view superview];
        if(VALID_NOTEMPTY(cellView, UIView))
        {
            UIView *collectionView = [cellView superview];
            if(VALID_NOTEMPTY(collectionView, UIView))
            {
                RIAddress *addressToEdit = nil;
                if(self.firstAddressesCollectionView == [[[sender superview] superview] superview])
                {
                    addressToEdit = [self.firstCollectionViewAddresses objectAtIndex:tag];
                }
                else if(self.secondAddressesCollectionView == [[[sender superview] superview] superview])
                {
                    addressToEdit = [self.secondCollectionViewAddresses objectAtIndex:tag];
                }
                
                if(VALID_NOTEMPTY(addressToEdit, RIAddress))
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutEditAddressScreenNotification
                                                                        object:nil
                                                                      userInfo:[NSDictionary dictionaryWithObjects:@[addressToEdit] forKeys:@[@"address_to_edit"]]];
                }
            }
        }
    }
}

-(void)changeBillingAddressState:(id)sender
{
    UISwitch *switchView = sender;
    
    self.useSameAddressAsBillingAndShipping = switchView.isOn;
    
    [self finishedLoadingAddresses];
    
    [self.contentScrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeForItemAtIndexPath = CGSizeZero;
    
    if(collectionView == self.firstAddressesCollectionView)
    {
        if(VALID_NOTEMPTY(self.firstCollectionViewAddresses, NSArray))
        {
            if(indexPath.row < [self.firstCollectionViewAddresses count])
            {
                // Address
                sizeForItemAtIndexPath = CGSizeMake(self.firstAddressesCollectionView.frame.size.width, 100.0f);
            }
            else if(indexPath.row < ([self.firstCollectionViewAddresses count] + 1))
            {
                // Switch
                sizeForItemAtIndexPath = CGSizeMake(self.firstAddressesCollectionView.frame.size.width, 51.0f);
            }
            else if(indexPath.row < ([self.firstCollectionViewAddresses count] + 2))
            {
                // Add new address
                sizeForItemAtIndexPath = CGSizeMake(self.firstAddressesCollectionView.frame.size.width, 44.0f);
            }
        }
    }
    else if(collectionView == self.secondAddressesCollectionView)
    {
        if(VALID_NOTEMPTY(self.secondCollectionViewAddresses, NSArray) && indexPath.row < [self.secondCollectionViewAddresses count])
        {
            // Address
            sizeForItemAtIndexPath = CGSizeMake(self.secondAddressesCollectionView.frame.size.width, 100.0f);
        }
        else
        {
            // Add new address
            sizeForItemAtIndexPath = CGSizeMake(self.secondAddressesCollectionView.frame.size.width, 44.0f);
        }
    }
    
    return sizeForItemAtIndexPath;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize referenceSizeForHeaderInSection = CGSizeZero;
    if(collectionView == self.firstAddressesCollectionView)
    {
        referenceSizeForHeaderInSection = CGSizeMake(self.firstAddressesCollectionView.frame.size.width, 26.0f);
    }
    else if(collectionView == self.secondAddressesCollectionView)
    {
        referenceSizeForHeaderInSection = CGSizeMake(self.secondAddressesCollectionView.frame.size.width, 26.0f);
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
    if(collectionView == self.firstAddressesCollectionView)
    {
        if(VALID_NOTEMPTY(self.firstCollectionViewAddresses, NSArray))
        {
            numberOfItemsInSection = [self.firstCollectionViewAddresses count] + 1;
            if(!self.useSameAddressAsBillingAndShipping)
            {
                numberOfItemsInSection++;
            }
        }
    }
    else if(collectionView == self.secondAddressesCollectionView)
    {
        if(VALID_NOTEMPTY(self.secondCollectionViewAddresses, NSArray))
        {
            numberOfItemsInSection = [self.secondCollectionViewAddresses count];
        }
        
        numberOfItemsInSection++;
    }
    return numberOfItemsInSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if(collectionView == self.firstAddressesCollectionView)
    {
        if(VALID_NOTEMPTY(self.firstCollectionViewAddresses, NSArray))
        {
            if(indexPath.row < [self.firstCollectionViewAddresses count])
            {
                RIAddress *address = [self.firstCollectionViewAddresses objectAtIndex:indexPath.row];
                
                NSString *cellIdentifier = @"addressListCell";
                JAAddressCell *addressCell = (JAAddressCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                [addressCell loadWithAddress:address];
                [addressCell.editAddressButton setTag:indexPath.row];
                [addressCell.editAddressButton addTarget:self action:@selector(editAddressButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                if(VALID_NOTEMPTY(self.firstCollectionViewIndexSelected, NSIndexPath) && self.firstCollectionViewIndexSelected.row == indexPath.row)
                {
                    [addressCell selectAddress];
                }
                else
                {
                    [addressCell deselectAddress];
                }
                
                cell = addressCell;
            }
            else if(indexPath.row < ([self.firstCollectionViewAddresses count] + 1))
            {
                // Switch
                NSString *cellIdentifier = @"switchListCell";
                JASwitchCell *switchCell = (JASwitchCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                [switchCell loadWithText:STRING_BILLING_SAME_ADDRESSES isLastRow:self.useSameAddressAsBillingAndShipping];
                
                if(self.useSameAddressAsBillingAndShipping)
                {
                    [switchCell.switchView setOn:YES];
                }
                else
                {
                    [switchCell.switchView setOn:NO];
                }
                
                [switchCell.switchView addTarget:self action:@selector(changeBillingAddressState:) forControlEvents:UIControlEventValueChanged];
                cell = switchCell;
            }
            else if(indexPath.row < ([self.firstCollectionViewAddresses count] + 2))
            {
                // Add new address
                NSString *cellIdentifier = @"addAddressListCell";
                JAAddNewAddressCell *addAddressCell = (JAAddNewAddressCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                [addAddressCell loadWithText:STRING_ADD_NEW_ADDRESS];
                
                cell = addAddressCell;
            }
        }
    }
    else if(collectionView == self.secondAddressesCollectionView)
    {
        if(VALID_NOTEMPTY(self.secondCollectionViewAddresses, NSArray) && indexPath.row < [self.secondCollectionViewAddresses count])
        {
            RIAddress *address = [self.secondCollectionViewAddresses objectAtIndex:indexPath.row];
            
            NSString *cellIdentifier = @"addressListCell";
            JAAddressCell *addressCell = (JAAddressCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            [addressCell loadWithAddress:address];
            [addressCell.editAddressButton setTag:indexPath.row];
            [addressCell.editAddressButton addTarget:self action:@selector(editAddressButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            if(VALID_NOTEMPTY(self.secondCollectionViewIndexSelected, NSIndexPath) && self.secondCollectionViewIndexSelected.row == indexPath.row)
            {
                [addressCell selectAddress];
            }
            else
            {
                [addressCell deselectAddress];
            }
            
            cell = addressCell;
        }
        else
        {
            // Add new address
            NSString *cellIdentifier = @"addAddressListCell";
            JAAddNewAddressCell *addAddressCell = (JAAddNewAddressCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            [addAddressCell loadWithText:STRING_ADD_NEW_ADDRESS];
            
            cell = addAddressCell;
        }
        
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader" forIndexPath:indexPath];
        
        if(collectionView == self.firstAddressesCollectionView)
        {
            if(self.useSameAddressAsBillingAndShipping)
            {
                [headerView loadHeaderWithText:STRING_DEFAULT_SHIPPING_ADDRESSES];
            }
            else
            {
                [headerView loadHeaderWithText:STRING_SHIPPING_ADDRESSES];
            }
        }
        else if(collectionView == self.secondAddressesCollectionView)
        {
            if(self.useSameAddressAsBillingAndShipping)
            {
                [headerView loadHeaderWithText:STRING_OTHER_ADDRESSES];
            }
            else
            {
                [headerView loadHeaderWithText:STRING_BILLING_ADDRESSES];
            }
        }
        
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.firstAddressesCollectionView)
    {
        if(VALID_NOTEMPTY(self.firstCollectionViewAddresses, NSArray))
        {
            if(indexPath.row < [self.firstCollectionViewAddresses count])
            {
                self.shippingAddress = [self.firstCollectionViewAddresses objectAtIndex:indexPath.row];
                
                if(self.useSameAddressAsBillingAndShipping)
                {
                    self.billingAddress = self.shippingAddress;
                    
                    if(VALID(self.secondAddressesCollectionView , UICollectionView) && VALID_NOTEMPTY(self.secondCollectionViewIndexSelected, NSIndexPath))
                    {
                        JAAddressCell *oldAddressCell = (JAAddressCell*) [self.secondAddressesCollectionView cellForItemAtIndexPath:self.secondCollectionViewIndexSelected];
                        [oldAddressCell deselectAddress];
                        
                        self.secondCollectionViewIndexSelected = nil;
                    }
                }
                
                if(VALID_NOTEMPTY(self.firstCollectionViewIndexSelected, NSIndexPath))
                {
                    JAAddressCell *oldAddressCell = (JAAddressCell*) [collectionView cellForItemAtIndexPath:self.firstCollectionViewIndexSelected];
                    [oldAddressCell deselectAddress];
                }
                self.firstCollectionViewIndexSelected = indexPath;
                
                JAAddressCell *addressCell = (JAAddressCell*)[collectionView cellForItemAtIndexPath:indexPath];
                [addressCell selectAddress];
            }
            else if(indexPath.row < ([self.firstCollectionViewAddresses count] + 1))
            {
                // Switch - nothing to do
            }
            else if(indexPath.row < ([self.firstCollectionViewAddresses count] + 2))
            {
                // Add new address
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
        }
    }
    else if(collectionView == self.secondAddressesCollectionView)
    {
        if(VALID_NOTEMPTY(self.secondCollectionViewAddresses, NSArray) && indexPath.row < [self.secondCollectionViewAddresses count])
        {
            self.billingAddress = [self.secondCollectionViewAddresses objectAtIndex:indexPath.row];
            if(self.useSameAddressAsBillingAndShipping)
            {
                self.shippingAddress = self.billingAddress;
                
                if(VALID(self.firstAddressesCollectionView, UICollectionView) && VALID_NOTEMPTY(self.firstCollectionViewIndexSelected, NSIndexPath))
                {
                    JAAddressCell *oldAddressCell = (JAAddressCell*) [self.firstAddressesCollectionView cellForItemAtIndexPath:self.firstCollectionViewIndexSelected];
                    [oldAddressCell deselectAddress];
                    
                    self.firstCollectionViewIndexSelected = nil;
                }
            }
            
            if(VALID_NOTEMPTY(self.secondCollectionViewIndexSelected, NSIndexPath))
            {
                JAAddressCell *oldAddressCell = (JAAddressCell*) [collectionView cellForItemAtIndexPath:self.secondCollectionViewIndexSelected];
                [oldAddressCell deselectAddress];
            }
            self.secondCollectionViewIndexSelected = indexPath;
            
            JAAddressCell *addressCell = (JAAddressCell*)[collectionView cellForItemAtIndexPath:indexPath];
            [addressCell selectAddress];
        }
        else
        {
            // Add new address
            if(self.useSameAddressAsBillingAndShipping)
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
            else
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
        }
    }
}

-(void)nextStepButtonPressed
{
    [self showLoading];
    
    [RICheckout getBillingAddressFormWithSuccessBlock:^(RICheckout *checkout) {
        RIForm *billingForm = checkout.billingAddressForm;
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        for (RIField *field in [billingForm fields])
        {
            if([@"billingForm[billingAddressId]" isEqualToString:[field name]])
            {
                [parameters setValue:[self.billingAddress uid] forKey:[field name]];
            }
            else if([@"billingForm[shippingAddressId]" isEqualToString:[field name]])
            {
                [parameters setValue:[self.shippingAddress uid] forKey:[field name]];
            }
            else if([@"billingForm[shippingAddressDifferent]" isEqualToString:[field name]])
            {
                [parameters setValue:[[self.billingAddress uid] isEqualToString:[self.shippingAddress uid]] ? @"0" : @"1" forKey:[field name]];
            }
        }
        
        [RICheckout setBillingAddress:checkout.billingAddressForm parameters:parameters successBlock:^(RICheckout *checkout) {
            
            [self hideLoading];
            
            [JAUtils goToCheckout:checkout inStoryboard:self.storyboard];
        } andFailureBlock:^(NSArray *errorMessages) {
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"NativeCheckoutError" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutError]
                                                      data:[trackingDictionary copy]];
            
            [self hideLoading];
            
            [self showMessage:STRING_ERROR_SETTING_BILLING_SHIPPING_ADDRESS success:NO];
        }];
    } andFailureBlock:^(NSArray *errorMessages) {

        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"NativeCheckoutError" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutError]
                                                  data:[trackingDictionary copy]];
        
        [self hideLoading];
        
        [self showMessage:STRING_ERROR_SETTING_BILLING_SHIPPING_ADDRESS success:NO];
    }];
}

@end
