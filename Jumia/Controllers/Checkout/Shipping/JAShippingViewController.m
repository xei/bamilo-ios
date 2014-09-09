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
#import "JAShippingInfoCell.h"
#import "JAPickupStationInfoCell.h"
#import "JAUtils.h"
#import "RICheckout.h"
#import "RIShippingMethodPickupStationOption.h"

#define kPickupStationKey @"pickupstation"

@interface JAShippingViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIPickerViewDataSource,
UIPickerViewDelegate>

// Steps
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepIconLeftConstrain;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLabelWidthConstrain;

// Shipping methods
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UICollectionView *collectionView;

// Bottom view
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

// Picker view
@property (strong, nonatomic) UIView *pickerBackgroundView;
@property (strong, nonatomic) UIToolbar *pickerToolbar;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSIndexPath *pickerIndexPath;

@property (strong, nonatomic) RICheckout *checkout;
@property (strong, nonatomic) RIShippingMethodForm* shippingMethodForm;
@property (strong, nonatomic) NSArray *shippingMethods;
@property (strong, nonatomic) NSDictionary *pickupStationRegions;
@property (strong, nonatomic) NSString *selectedRegion;
@property (strong, nonatomic) NSMutableArray *pickupStationsForRegion;
@property (strong, nonatomic) NSString *selectedShippingMethod;
@property (strong, nonatomic) NSIndexPath *collectionViewIndexSelected;
@property (strong, nonatomic) NSIndexPath *selectedPickupStationIndexPath;

@end

@implementation JAShippingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.title = @"Checkout";
    
    self.pickupStationsForRegion = [[NSMutableArray alloc] init];
    
    [self setupViews];
    
    [self showLoading];
    [RICheckout getShippingMethodFormWithSuccessBlock:^(RICheckout *checkout)
     {
         self.checkout = checkout;
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
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, self.view.frame.size.width, self.view.frame.size.height - 21.0f - 64.0f)];
    
    UICollectionViewFlowLayout* collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [collectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionViewFlowLayout setItemSize:CGSizeZero];
    [collectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    UINib *shippingListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    UINib *shippingListCellNib = [UINib nibWithNibName:@"JAShippingCell" bundle:nil];
    UINib *shippingInfoCellNib = [UINib nibWithNibName:@"JAShippingInfoCell" bundle:nil];
    UINib *pickupRegionsCellNib = [UINib nibWithNibName:@"JAPickupRegionsCell" bundle:nil];
    UINib *pickupStationInfoCellNib = [UINib nibWithNibName:@"JAPickupStationInfoCell" bundle:nil];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                             6.0f,
                                                                             self.scrollView.frame.size.width - 12.0f,
                                                                             26.0f) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.layer.cornerRadius = 5.0f;
    [self.collectionView registerNib:shippingListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"shippingListHeader"];
    [self.collectionView registerNib:shippingListCellNib forCellWithReuseIdentifier:@"shippingListCell"];
    [self.collectionView registerNib:shippingInfoCellNib forCellWithReuseIdentifier:@"shippingInfoCell"];
    [self.collectionView registerNib:pickupRegionsCellNib forCellWithReuseIdentifier:@"pickupRegionsCell"];
    [self.collectionView registerNib:pickupStationInfoCellNib forCellWithReuseIdentifier:@"pickupStationInfoCell"];
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

-(void)finishedLoadingShippingMethods
{
    if(VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        for (RIShippingMethodFormField *field in [self.shippingMethodForm fields])
        {
            if([@"shippingMethodForm[shipping_method]" isEqualToString:[field name]])
            {
                self.selectedShippingMethod = [field value];
                break;
            }
        }
        
        if(VALID_NOTEMPTY(self.selectedShippingMethod, NSString))
        {
            for(int i = 0; i < [self.shippingMethods count]; i++)
            {
                NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:i];
                NSArray *shippingMethodKeys = [shippingMethod allKeys];
                if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
                {
                    if([self.selectedShippingMethod isEqualToString:[shippingMethodKeys objectAtIndex:0]])
                    {
                        self.collectionViewIndexSelected = [NSIndexPath indexPathForItem:i inSection:0];
                        break;
                    }
                }
            }
        }
        
        [self reloadCollectionView];
    }
    [self hideLoading];
}

-(void)reloadCollectionView
{
    if(VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        CGFloat collectionViewHeight = 26.0f + ([self.shippingMethods count] * 44.0f);
        
        if(VALID_NOTEMPTY(self.selectedShippingMethod, NSString))
        {
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                collectionViewHeight += 50.0f;
                collectionViewHeight += ([self.pickupStationsForRegion count] * 120.0f);
            }
            else
            {
                collectionViewHeight += 36.0f;
            }
        }
        
        [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                                 self.collectionView.frame.origin.y,
                                                 self.collectionView.frame.size.width,
                                                 collectionViewHeight)];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                                   self.collectionView.frame.origin.y + collectionViewHeight + self.bottomView.frame.size.height + 6.0f)];
    }
    
    [self.collectionView reloadData];
}

- (void)openPicker
{
    [self removePickerView];
    
    self.pickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    UITapGestureRecognizer *removePickerViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(removePickerView)];
    [self.pickerBackgroundView addGestureRecognizer:removePickerViewTap];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.pickerView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.pickerView setAlpha:0.9];
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    
    NSInteger selectedRow = 0;
    if(VALID_NOTEMPTY(self.pickupStationRegions, NSDictionary) && VALID_NOTEMPTY(self.pickerIndexPath, NSIndexPath))
    {
        NSArray *allKeys = [self.pickupStationRegions allKeys];
        if(VALID_NOTEMPTY(allKeys, NSArray))
        {
            for (int i = 0; i < [allKeys count]; i++)
            {
                NSString *key = [allKeys objectAtIndex:i];
                if([self.selectedRegion isEqualToString:[self.pickupStationRegions objectForKey:key]])
                {
                    selectedRow = i;
                    break;
                }
            }
        }
    }
    
    //    [self.pickerView selectedRowInComponent:selectedRow];
    [self.pickerView setFrame:CGRectMake(0.0f,
                                         (self.pickerBackgroundView.frame.size.height - self.pickerView.frame.size.height),
                                         self.pickerView.frame.size.width,
                                         self.pickerView.frame.size.height)];
    
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.pickerToolbar setTranslucent:NO];
    [self.pickerToolbar setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.pickerToolbar setAlpha:0.9];
    [self.pickerToolbar setFrame:CGRectMake(0.0f,
                                            CGRectGetMinY(self.pickerView.frame) - 44.0f,
                                            320.0f,
                                            44.0f)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0f, 0.0f, 0.0f)];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(regionSelected:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.pickerToolbar setItems:[NSArray arrayWithObjects:flexibleItem, doneButton, nil]];
    [self.pickerBackgroundView addSubview:self.pickerToolbar];
    
    [self.pickerBackgroundView addSubview:self.pickerView];
    [self.view addSubview:self.pickerBackgroundView];
}

-(void)removePickerView
{
    if(VALID_NOTEMPTY(self.pickerToolbar, UIToolbar))
    {
        [self.pickerToolbar removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.pickerView, UIPickerView))
    {
        [self.pickerView removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.pickerBackgroundView, UIView))
    {
        [self.pickerBackgroundView removeFromSuperview];
    }
    
    self.pickerView = nil;
    self.pickerBackgroundView = nil;
}

-(void)regionSelected:(id)sender
{
    NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
    if(VALID_NOTEMPTY(self.pickupStationRegions, NSDictionary) && VALID_NOTEMPTY(self.pickerIndexPath, NSIndexPath))
    {
        NSArray *allKeys = [self.pickupStationRegions allKeys];
        if(VALID_NOTEMPTY(allKeys, NSArray) && selectedRow < [self.pickupStationRegions count])
        {
            NSString *key = [allKeys objectAtIndex:selectedRow];
            self.selectedRegion = [self.pickupStationRegions objectForKey:key];
            
            self.pickupStationsForRegion = [[NSMutableArray alloc] initWithArray:[RIShippingMethodForm getPickupStationsForRegion:key shippingMethod:self.selectedShippingMethod inForm:self.shippingMethodForm]];
        }
    }
    
    [self removePickerView];
    
    [self reloadCollectionView];
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
    
    if(collectionView == self.collectionView)
    {
        if(indexPath.row <= self.collectionViewIndexSelected.row || indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
        {
            // Shipping method title cell
            sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 44.0f);
        }
        else if(indexPath.row == (self.collectionViewIndexSelected.row + 1))
        {
            // Shipping method info cell
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 50.0f);
            }
            else
            {
                sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 36.0f);
            }
        }
        else
        {
            // Shipping method option cell
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 120.0f);
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
        
        // Add options
        numberOfItemsInSection += [self.pickupStationsForRegion count] + 1;
    }
    return numberOfItemsInSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        if(indexPath.row <= self.collectionViewIndexSelected.row || indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
        {
            // Shipping method title cell
            NSInteger index = indexPath.row;
            if(indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
            {
                index = indexPath.row - ([self.pickupStationsForRegion count] + 1);
            }
            
            NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:index];
            
            NSArray *shippingMethodKeys = [shippingMethod allKeys];
            if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
            {
                NSString *shippingMethodKey = [shippingMethodKeys objectAtIndex:0];
                NSString *cellIdentifier = @"shippingListCell";
                JAShippingCell *shippingCell = (JAShippingCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                [shippingCell loadWithShippingMethod:[shippingMethod objectForKey:shippingMethodKey]];
                
                [shippingCell deselectAddress];
                if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath) && indexPath.row == self.collectionViewIndexSelected.row)
                {
                    [shippingCell selectAddress];
                }
                
                if(([self.shippingMethods count] - 1) == index || self.collectionViewIndexSelected.row == index)
                {
                    [shippingCell.separator setHidden:YES];
                }
                
                cell = shippingCell;
            }
        }
        else if(indexPath.row == (self.collectionViewIndexSelected.row + 1))
        {
            // Shipping method info cell
            
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                NSString *cellIdentifier = @"pickupRegionsCell";
                JAShippingInfoCell *shippingInfoCell = (JAShippingInfoCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                [shippingInfoCell loadWithPickupStation];
                
                if(VALID_NOTEMPTY(self.selectedRegion, NSString))
                {
                    [shippingInfoCell setPickupStationRegion:self.selectedRegion];
                }
                
                if(([self.shippingMethods count] - 1) == self.collectionViewIndexSelected.row ||
                   VALID_NOTEMPTY(self.pickupStationsForRegion, NSMutableArray))
                {
                    [shippingInfoCell.separator setHidden:YES];
                }
                else
                {
                    [shippingInfoCell.separator setHidden:NO];
                }
                
                cell = shippingInfoCell;
            }
            else
            {
                NSString *cellIdentifier = @"shippingInfoCell";
                JAShippingInfoCell *shippingInfoCell = (JAShippingInfoCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                NSString *shippingFee = [[self.checkout cart] shippingValueFormatted];
                if(0 == [[[self.checkout cart] shippingValue] integerValue])
                {
                    shippingFee = @"Free";
                }
                [shippingInfoCell loadWithShippingFee:shippingFee];
                
                if(([self.shippingMethods count] - 1) == self.collectionViewIndexSelected.row)
                {
                    [shippingInfoCell.separator setHidden:YES];
                }
                else
                {
                    [shippingInfoCell.separator setHidden:NO];
                }
                
                cell = shippingInfoCell;
            }
        }
        else
        {
            // Shipping method option cell
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                NSString *cellIdentifier = @"pickupStationInfoCell";
                JAPickupStationInfoCell *pickupStationInfoCell = (JAPickupStationInfoCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                
                if(VALID_NOTEMPTY(self.pickupStationsForRegion, NSMutableArray))
                {
                    NSInteger index = indexPath.row - self.collectionViewIndexSelected.row - 2;
                    [pickupStationInfoCell loadWithPickupStation:[self.pickupStationsForRegion objectAtIndex:index]];
                    if(index == ([self.pickupStationsForRegion count] - 1))
                    {
                        [pickupStationInfoCell.separator setHidden:YES];
                        [pickupStationInfoCell.lastSeparator setHidden:NO];
                    }
                    else
                    {
                        [pickupStationInfoCell.separator setHidden:NO];
                        [pickupStationInfoCell.lastSeparator setHidden:YES];
                    }
                }
                
                [pickupStationInfoCell deselectPickupStation];
                if(indexPath.row == self.selectedPickupStationIndexPath.row)
                {
                    [pickupStationInfoCell selectPickupStation];
                }
                
                cell = pickupStationInfoCell;
            }
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
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.shippingMethods, NSArray))
    {
        if(indexPath.row <= self.collectionViewIndexSelected.row || indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
        {
            // Shipping method title cell
            NSInteger index = indexPath.row;
            if(indexPath.row > (self.collectionViewIndexSelected.row + [self.pickupStationsForRegion count] + 1))
            {
                index = indexPath.row - ([self.pickupStationsForRegion count] + 1);
            }
            
            NSDictionary *shippingMethod = [self.shippingMethods objectAtIndex:index];
            NSArray *shippingMethodKeys = [shippingMethod allKeys];
            if(VALID_NOTEMPTY(shippingMethodKeys, NSArray))
            {
                self.selectedShippingMethod = [shippingMethodKeys objectAtIndex:0];
                
                if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath))
                {
                    JAShippingCell *oldShippingCell = (JAShippingCell*) [collectionView cellForItemAtIndexPath:self.collectionViewIndexSelected];
                    [oldShippingCell deselectAddress];
                }
                self.collectionViewIndexSelected = [NSIndexPath indexPathForItem:index inSection:indexPath.section];
                
                JAShippingCell *shippingCell = (JAShippingCell*)[collectionView cellForItemAtIndexPath:indexPath];
                [shippingCell selectAddress];
                
                self.pickupStationRegions = [RIShippingMethodForm getRegionsForShippingMethod:self.selectedShippingMethod inForm:self.shippingMethodForm];
                self.pickerIndexPath = nil;
                self.selectedPickupStationIndexPath = nil;

                [self reloadCollectionView];
            }
        }
        else if(indexPath.row == (self.collectionViewIndexSelected.row + 1))
        {
            // Shipping method info cell
            if([kPickupStationKey isEqualToString:[self.selectedShippingMethod lowercaseString]])
            {
                [self openPicker];
                self.pickerIndexPath = indexPath;
            }
        }
        else
        {
            // Shipping method option cell
            if(VALID_NOTEMPTY(self.selectedPickupStationIndexPath, NSIndexPath))
            {
                JAPickupStationInfoCell *oldPickupStationInfoCell = (JAPickupStationInfoCell*) [collectionView cellForItemAtIndexPath:self.selectedPickupStationIndexPath];
                [oldPickupStationInfoCell deselectPickupStation];
            }
            
            JAPickupStationInfoCell *pickupStationInfoCell = (JAPickupStationInfoCell*)[collectionView cellForItemAtIndexPath:indexPath];
            [pickupStationInfoCell selectPickupStation];
           
            self.selectedPickupStationIndexPath = indexPath;
        }
    }
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberOfRowsInComponent = 0;
    if(VALID_NOTEMPTY(self.pickupStationRegions , NSDictionary))
    {
        numberOfRowsInComponent = [self.pickupStationRegions count];
    }
    return numberOfRowsInComponent;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *titleForRow = @"";
    if(VALID_NOTEMPTY(self.pickupStationRegions, NSDictionary))
    {
        NSArray *allKeys = [self.pickupStationRegions allKeys];
        if(VALID_NOTEMPTY(allKeys, NSArray) && row < [allKeys count])
        {
            NSString *key = [allKeys objectAtIndex:row];
            titleForRow = [self.pickupStationRegions objectForKey:key];
        }
    }
    return  titleForRow;
}

@end
