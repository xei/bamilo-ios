//
//  JARecentlyViewedViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARecentlyViewedViewController.h"
#import "JACatalogListCell.h"
#import "JAButtonCell.h"
#import "JAPDVViewController.h"
#import "RIProduct.h"
#import "RIProductSimple.h"
#import "RICart.h"

@interface JARecentlyViewedViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyListView;
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray* productsArray;

// size picker view
@property (strong, nonatomic) UIView *sizePickerBackgroundView;
@property (strong, nonatomic) UIToolbar *sizePickerToolbar;
@property (strong, nonatomic) UIPickerView *sizePicker;
@property (nonatomic, strong) NSMutableArray* chosenSimpleNames;

@end

@implementation JARecentlyViewedViewController

@synthesize productsArray=_productsArray;
- (void)setProductsArray:(NSArray *)productsArray
{
    _productsArray = productsArray;
    [self.collectionView reloadData];
    if (ISEMPTY(productsArray)) {
        self.emptyListView.hidden = NO;
        self.collectionView.hidden = YES;
    } else {
        self.emptyListView.hidden = YES;
        self.collectionView.hidden = NO;
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.title = @"Recently Viewed";
    
    self.collectionView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    self.emptyListView.layer.cornerRadius = 3.0f;
    
    self.emptyListLabel.textColor = UIColorFromRGB(0xcccccc);
    self.emptyListLabel.text = @"No recently viewed products here";
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UINib *listCellNib = [UINib nibWithNibName:@"JARecentlyViewedListCell" bundle:nil];
    [self.collectionView registerNib:listCellNib forCellWithReuseIdentifier:@"recentlyViewedListCell"];
    UINib *buttonCellNib = [UINib nibWithNibName:@"JAGrayButtonCell" bundle:nil];
    [self.collectionView registerNib:buttonCellNib forCellWithReuseIdentifier:@"buttonCell"];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, JACatalogViewControllerListCellHeight);
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showLoading];
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        [self hideLoading];
        self.productsArray = recentlyViewedProducts;
        self.chosenSimpleNames = [NSMutableArray new];
        for (int i = 0; i < self.productsArray.count; i++) {
            [self.chosenSimpleNames addObject:@""];
        }
    } andFailureBlock:^(NSArray *error) {
        [self hideLoading];
    }];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productsArray.count + 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(3, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.productsArray.count == indexPath.row) {
        return CGSizeMake(self.view.frame.size.width,
                          50.0f);
    } else {
        return CGSizeMake(self.view.frame.size.width,
                          98.0f);
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.productsArray.count) {
        
        NSString *cellIdentifier = @"buttonCell";
        
        JAButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell loadWithButtonName:@"Clear Recently Viewed"];
        
        [cell.button addTarget:self
                        action:@selector(clearAllButtonPressed)
              forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
        
        NSString *cellIdentifier = @"recentlyViewedListCell";
        
        JACatalogListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell loadWithProduct:product];
        cell.addToCartButton.tag = indexPath.row;
        [cell.addToCartButton addTarget:self
                                 action:@selector(addToCartPressed:)
                       forControlEvents:UIControlEventTouchUpInside];

        NSString* chosenSimpleName = [self.chosenSimpleNames objectAtIndex:indexPath.row];
        if ([chosenSimpleName isEqualToString:@""]) {
            [cell.sizeButton setTitle:@"Size" forState:UIControlStateNormal];
        } else {
            [cell.sizeButton setTitle:[NSString stringWithFormat:@"Size: %@", chosenSimpleName] forState:UIControlStateNormal];
        }
        
        cell.sizeButton.tag = indexPath.row;
        [cell.sizeButton addTarget:self
                            action:@selector(sizeButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.productsArray.count) {
        RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
        
        NSInteger count = self.productsArray.count;
        
        if (count > 20) {
            count = 20;
        }
        
        NSMutableArray *tempArray = [NSMutableArray new];
        
        for (int i = 0 ; i < count ; i ++) {
            [tempArray addObject:[self.productsArray objectAtIndex:i]];
        }
        
        JAPDVViewController *pdv = [self.storyboard instantiateViewControllerWithIdentifier:@"pdvViewController"];
        pdv.productUrl = product.url;
        pdv.fromCatalogue = YES;
        pdv.previousCategory = @"Recently Viewed";
        pdv.arrayWithRelatedItems = [tempArray copy];
        
        [self.navigationController pushViewController:pdv
                                             animated:YES];
    }
}

#pragma mark - Button Actions

- (void)addToCartPressed:(UIButton*)button;
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    
    RIProductSimple* productSimple;
    
    if (1 == product.productSimples.count) {
        productSimple = [product.productSimples firstObject];
    } else {
        NSString* simpleName = [self.chosenSimpleNames objectAtIndex:button.tag];
        if ([simpleName isEqualToString:@""]) {
            //NOTHING SELECTED
            
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Please choose product size"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Ok", nil] show];
            
            return;
        } else {
            for (RIProductSimple* simple in product.productSimples) {
                if ([simple.attributeSize isEqualToString:simpleName] ||
                    [simple.variation isEqualToString:simpleName] ||
                    [simple.color isEqualToString:simpleName]) {
                    //found it
                    productSimple = simple;
                }
            }
        }
    }
    
    [self showLoading];
    [RICart addProductWithQuantity:@"1"
                               sku:product.sku
                            simple:productSimple.sku
                  withSuccessBlock:^(RICart *cart) {

                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      
                      [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                  message:@"Product added"
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"Ok", nil] show];
                      
                      [self hideLoading];
                      
                  } andFailureBlock:^(NSArray *errorMessages) {
                      
                      [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                  message:@"Error adding to the cart"
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"Ok", nil] show];
                      
                      [self hideLoading];
                      
                  }];
}


- (void)clearAllButtonPressed
{
    [self showLoading];
    [RIProduct removeAllRecentlyViewedWithSuccessBlock:^{
        [self hideLoading];
        self.productsArray = nil;
    } andFailureBlock:^(NSArray *error) {
        [self hideLoading];
    }];
}

- (void)sizeButtonPressed:(UIButton*)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    NSString* simpleName = [self.chosenSimpleNames objectAtIndex:button.tag];

    self.sizePickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                 0.0f,
                                                                                 self.view.frame.size.width,
                                                                                 self.view.frame.size.height)];
    [self.sizePickerBackgroundView setBackgroundColor:[UIColor clearColor]];
    
    UITapGestureRecognizer *removePickerViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(removePickerView)];
    [self.sizePickerBackgroundView addGestureRecognizer:removePickerViewTap];
    
    self.sizePicker = [[UIPickerView alloc] init];
    [self.sizePicker setFrame:CGRectMake(self.sizePickerBackgroundView.frame.origin.x,
                                             CGRectGetMaxY(self.sizePickerBackgroundView.frame) - self.sizePicker.frame.size.height,
                                             self.sizePicker.frame.size.width,
                                             self.sizePicker.frame.size.height)];
    [self.sizePicker setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.sizePicker setAlpha:0.9];
    [self.sizePicker setShowsSelectionIndicator:YES];
    [self.sizePicker setDataSource:self];
    [self.sizePicker setDelegate:self];
    self.sizePicker.tag = button.tag;
    
    self.sizePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.sizePickerToolbar setTranslucent:NO];
    [self.sizePickerToolbar setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.sizePickerToolbar setAlpha:0.9];
    [self.sizePickerToolbar setFrame:CGRectMake(0.0f,
                                                    CGRectGetMinY(self.sizePicker.frame) - self.sizePickerToolbar.frame.size.height,
                                                    self.sizePickerToolbar.frame.size.width,
                                                    self.sizePickerToolbar.frame.size.height)];
    
    UIButton *tmpbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tmpbutton setFrame:CGRectMake(0.0, 0.0f, 0.0f, 0.0f)];
    [tmpbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [tmpbutton setTitle:@"Done" forState:UIControlStateNormal];
    [tmpbutton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [tmpbutton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [tmpbutton addTarget:self action:@selector(selectSize:) forControlEvents:UIControlEventTouchUpInside];
    [tmpbutton sizeToFit];
    tmpbutton.tag = button.tag;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithCustomView:tmpbutton];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.sizePickerToolbar setItems:[NSArray arrayWithObjects:flexibleItem, doneButton, nil]];
    
    //simple index
    NSInteger simpleIndex = 0;
    for (int i = 0; i < product.productSimples.count; i++) {
        RIProductSimple* simple = [product.productSimples objectAtIndex:i];
        if ([simple.attributeSize isEqualToString:simpleName] ||
            [simple.variation isEqualToString:simpleName] ||
            [simple.color isEqualToString:simpleName]) {
            //found it
            simpleIndex = i;
        }
    }
    
    [self.sizePicker selectRow:simpleIndex inComponent:0 animated:NO];
    [self.sizePickerBackgroundView addSubview:self.sizePicker];
    [self.sizePickerBackgroundView addSubview:self.sizePickerToolbar];
    [self.view addSubview:self.sizePickerBackgroundView];
}

- (void)selectSize:(UIButton*)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    NSInteger selectedIndex = [self.sizePicker selectedRowInComponent:0];
    
    RIProductSimple* selectedSimple = [product.productSimples objectAtIndex:selectedIndex];
    NSString* simpleName = @"";
    if (VALID_NOTEMPTY(selectedSimple.attributeSize, NSString)) {
        simpleName = selectedSimple.attributeSize;
    } else if (VALID_NOTEMPTY(selectedSimple.variation, NSString)) {
        simpleName = selectedSimple.variation;
    } else if (VALID_NOTEMPTY(selectedSimple.color, NSString)) {
        simpleName = selectedSimple.color;
    }
    
    [self.chosenSimpleNames replaceObjectAtIndex:button.tag withObject:simpleName];
    
    [self removePickerView];
    [self.collectionView reloadData];
}

- (void)removePickerView
{
    [self.sizePicker removeFromSuperview];
    self.sizePicker = nil;
    
    [self.sizePickerBackgroundView removeFromSuperview];
    self.sizePickerBackgroundView = nil;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    RIProduct* product = [self.productsArray objectAtIndex:pickerView.tag];
    return product.productSimples.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    RIProduct* product = [self.productsArray objectAtIndex:pickerView.tag];
    RIProductSimple* simple = [product.productSimples objectAtIndex:row];
    NSString* simpleName = @"";
    if (VALID_NOTEMPTY(simple.attributeSize, NSString)) {
        simpleName = simple.attributeSize;
    } else if (VALID_NOTEMPTY(simple.variation, NSString)) {
        simpleName = simple.variation;
    } else if (VALID_NOTEMPTY(simple.color, NSString)) {
        simpleName = simple.color;
    }
    NSString *title = [NSString stringWithFormat:@"%@", simpleName];
    return title;
}


@end
