//
//  JAEditAddressViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAEditAddressViewController.h"
#import "JAButtonWithBlur.h"
#import "JAUtils.h"
#import "JAOrderSummaryView.h"
#import "JAPicker.h"
#import "RICheckout.h"
#import "RIRegion.h"
#import "RICity.h"

@interface JAEditAddressViewController ()
<JADynamicFormDelegate,
JAPickerDelegate>

// Steps
@property (weak, nonatomic) IBOutlet UIImageView *stepBackground;
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

// Add Address
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (assign, nonatomic) CGRect originalFrame;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIView *headerSeparator;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (assign, nonatomic) CGFloat addressViewCurrentY;
@property (strong, nonatomic) RIRegion *selectedRegion;
@property (strong, nonatomic) RICity *selectedCity;
@property (strong, nonatomic) NSArray *citiesDataset;

// Picker view
@property (strong, nonatomic) JARadioComponent *radioComponent;
@property (strong, nonatomic) NSArray *regionsDataset;
@property (strong, nonatomic) NSArray *radioComponentDataset;
@property (strong, nonatomic) JAPicker *picker;

// Create Address Button
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@property (assign, nonatomic) BOOL hasErrors;
@property (strong, nonatomic) NSString *nextStep;
@property (strong, nonatomic) RICheckout *checkout;

// Order summary
@property (strong, nonatomic) JAOrderSummaryView *orderSummary;

@end

@implementation JAEditAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"EditAddress";
    
    self.navBarLayout.title = STRING_CHECKOUT;
    
    self.navBarLayout.showCartButton = NO;
    
    self.hasErrors = NO;
    
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showLoading];
    
    [self initViews];
    
    [RIForm getForm:@"addressedit"
       successBlock:^(RIForm *form)
     {
         self.dynamicForm = [[JADynamicForm alloc] initWithForm:form delegate:self values:[self getAddressValues] startingPosition:self.addressViewCurrentY];
         
         for(UIView *view in self.dynamicForm.formViews)
         {
             [self.contentView addSubview:view];
         }
         
         [self finishedFormLoading];
     }
       failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
     {
         [self finishedFormLoading];
         
         [self showMessage:STRING_ERROR success:NO];
     }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    [self showLoading];
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        newWidth = self.view.frame.size.width;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
    
    [self.dynamicForm resignResponder];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(void)initViews
{
    self.stepBackground.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepView.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepIcon.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepLabel.translatesAutoresizingMaskIntoConstraints = YES;
    [self.stepLabel setText:STRING_CHECKOUT_ADDRESS];
    
    [self setupStepView:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentScrollView setShowsVerticalScrollIndicator:NO];
    
    [self setupAddressView];
    
    [self.view addSubview:self.contentScrollView];
    
    self.bottomView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero
                                                  orientation:UIInterfaceOrientationPortrait];
    
    [self.bottomView setFrame:CGRectMake(0.0f,
                                         self.view.frame.size.height - self.bottomView.frame.size.height,
                                         self.view.frame.size.width,
                                         self.bottomView.frame.size.height)];
    [self.view addSubview:self.bottomView];
}

- (void) setupStepView:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat stepViewLeftMargin = 73.0f;
    NSString *stepBackgroundImageName = @"headerCheckoutStep2";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            stepViewLeftMargin =  389.0f;
            stepBackgroundImageName = @"headerCheckoutStep2Landscape";
        }
        else
        {
            stepViewLeftMargin = 261.0f;
            stepBackgroundImageName = @"headerCheckoutStep2Portrait";
        }
    }
    UIImage *stepBackgroundImage = [UIImage imageNamed:stepBackgroundImageName];
    
    [self.stepBackground setImage:stepBackgroundImage];
    [self.stepBackground setFrame:CGRectMake(self.stepBackground.frame.origin.x,
                                             self.stepBackground.frame.origin.y,
                                             stepBackgroundImage.size.width,
                                             stepBackgroundImage.size.height)];
    
    [self.stepView setFrame:CGRectMake(stepViewLeftMargin,
                                       (stepBackgroundImage.size.height - self.stepView.frame.size.height) / 2,
                                       self.stepView.frame.size.width,
                                       stepBackgroundImage.size.height)];
    [self.stepLabel sizeToFit];
    
    CGFloat horizontalMargin = 6.0f;
    CGFloat marginBetweenIconAndLabel = 5.0f;
    CGFloat realWidth = self.stepIcon.frame.size.width + marginBetweenIconAndLabel + self.stepLabel.frame.size.width - (2 * horizontalMargin);
    
    if(self.stepView.frame.size.width >= realWidth)
    {
        CGFloat xStepIconValue = ((self.stepView.frame.size.width - realWidth) / 2) - horizontalMargin;
        [self.stepIcon setFrame:CGRectMake(xStepIconValue,
                                           ceilf(((self.stepView.frame.size.height - self.stepIcon.frame.size.height) / 2) - 1.0f),
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            4.0f,
                                            self.stepLabel.frame.size.width,
                                            12.0f)];
    }
    else
    {
        [self.stepIcon setFrame:CGRectMake(horizontalMargin,
                                           ceilf(((self.stepView.frame.size.height - self.stepIcon.frame.size.height) / 2) - 1.0f),
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            4.0f,
                                            (self.stepView.frame.size.width - self.stepIcon.frame.size.width - marginBetweenIconAndLabel - (2 * horizontalMargin)),
                                            12.0f)];
    }
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self setupStepView:width toInterfaceOrientation:toInterfaceOrientation];
    
    [self.contentScrollView setFrame:CGRectMake(0.0f,
                                                self.stepBackground.frame.size.height,
                                                width,
                                                self.view.frame.size.height - self.stepBackground.frame.size.height)];
    self.originalFrame = self.contentScrollView.frame;
    
    self.addressViewCurrentY = CGRectGetMaxY(self.headerSeparator.frame) + 6.0f;
    
    if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
    {
        [self.orderSummary removeFromSuperview];
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)  && (width < self.view.frame.size.width))
    {
        CGFloat orderSummaryRightMargin = 6.0f;
        self.orderSummary = [[JAOrderSummaryView alloc] initWithFrame:CGRectMake(width,
                                                                                 self.stepBackground.frame.size.height,
                                                                                 self.view.frame.size.width - width - orderSummaryRightMargin,
                                                                                 self.view.frame.size.height - self.stepBackground.frame.size.height)];
        [self.orderSummary loadWithCart:self.cart];
        [self.view addSubview:self.orderSummary];
    }
    
    [self.contentView setFrame:CGRectMake(6.0f,
                                          6.0f,
                                          self.contentScrollView.frame.size.width - 12.0f,
                                          self.contentView.frame.size.height)];
    
    for(UIView *view in self.dynamicForm.formViews)
    {
        [view setFrame:CGRectMake(view.frame.origin.x,
                                  self.addressViewCurrentY,
                                  self.contentView.frame.size.width,
                                  view.frame.size.height)];
        self.addressViewCurrentY += view.frame.size.height;
    }
    
    self.addressViewCurrentY += 6.0f;
    
    [self.contentView setFrame:CGRectMake(6.0f,
                                          6.0f,
                                          self.contentScrollView.frame.size.width - 12.0f,
                                          self.addressViewCurrentY)];
    [self.contentView setHidden:NO];
    
    [self.headerLabel setFrame:CGRectMake(6.0f, 0.0f, self.contentView.frame.size.width - 12.0f, 26.0f)];
    [self.headerSeparator setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.headerLabel.frame), self.contentView.frame.size.width, 1.0f)];
    
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width,
                                                      self.contentView.frame.origin.y + self.contentView.frame.size.height + self.bottomView.frame.size.height)];
    
    [self.bottomView reloadFrame:CGRectMake(0.0f,
                                            self.view.frame.size.height - self.bottomView.frame.size.height,
                                            width,
                                            self.bottomView.frame.size.height)];
    [self.bottomView addButton:STRING_CANCEL target:self action:@selector(cancelButtonPressed)];
    [self.bottomView addButton:STRING_SAVE_CHANGES target:self action:@selector(saveChangesButtonPressed)];
}

-(NSDictionary*)getAddressValues
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    
    if(VALID_NOTEMPTY([self.editAddress firstName], NSString))
    {
        [values setObject:[self.editAddress firstName] forKey:@"first_name"];
    }
    
    if(VALID_NOTEMPTY([self.editAddress lastName], NSString))
    {
        [values setObject:[self.editAddress lastName] forKey:@"last_name"];
    }
    
    if(VALID_NOTEMPTY([self.editAddress address], NSString))
    {
        [values setObject:[self.editAddress address] forKey:@"address1"];
    }
    
    if(VALID_NOTEMPTY([self.editAddress address2], NSString))
    {
        [values setObject:[self.editAddress address2] forKey:@"address2"];
    }
    
    if(VALID_NOTEMPTY([self.editAddress city], NSString))
    {
        [values setObject:[self.editAddress city] forKey:@"city"];
    }
    
    if(VALID_NOTEMPTY([self.editAddress postcode], NSString))
    {
        [values setObject:[self.editAddress postcode] forKey:@"postcode"];
    }
    
    if(VALID_NOTEMPTY([self.editAddress phone], NSString))
    {
        [values setObject:[self.editAddress phone] forKey:@"phone"];
    }
    
    return values;
}

-(void)setupAddressView
{
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, 27.0f)];
    [self.contentView setHidden:YES];
    [self.contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.contentView.layer.cornerRadius = 5.0f;
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 0.0f, self.contentView.frame.size.width, 26.0f)];
    [self.headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.headerLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.headerLabel setText:STRING_EDIT_ADDRESS];
    [self.headerLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.headerLabel];
    
    self.headerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.headerLabel.frame), self.contentView.frame.size.width, 1.0f)];
    [self.headerSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.contentView addSubview:self.headerSeparator];
    
    [self.contentScrollView addSubview:self.contentView];
}

-(void)finishedFormLoading
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
    
    [self hideLoading];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
}

-(void)saveChangesButtonPressed
{
    [self showLoading];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self.dynamicForm getValues]];
    
    [parameters setValue:[self.editAddress uid] forKey:[self.dynamicForm getFieldNameForKey:@"id_customer_address"]];
    [parameters setValue:[self.editAddress isDefaultShipping] forKey:[self.dynamicForm getFieldNameForKey:@"is_default_shipping"]];
    [parameters setValue:[self.editAddress isDefaultBilling] forKey:[self.dynamicForm getFieldNameForKey:@"is_default_billing"]];
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:parameters
        successBlock:^(id object)
     {
         self.checkout = object;
         [self.dynamicForm resetValues];
         [JAUtils goToCheckout:self.checkout];
         [self hideLoading];
         
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         self.hasErrors = YES;
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.dynamicForm validateFields:errorObject];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.dynamicForm checkErrors];
         }
         
         if (RIApiResponseNoInternetConnection == apiResponse)
         {
             [self showMessage:STRING_NO_NEWTORK success:NO];
         } else {
             [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
         }
         
         self.hasErrors = NO;
         [self hideLoading];
     }];
}

-(void)cancelButtonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

-(void)removePickerView
{
    if(VALID_NOTEMPTY(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }
    
    self.radioComponent = nil;
    self.radioComponentDataset = nil;
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    //    CGPoint scrollPoint = CGPointMake(0.0, view.frame.origin.y);
    //    [self.contentScrollView setContentOffset:scrollPoint
    //                                    animated:YES];
}

- (void) lostFocus
{
    //    [UIView animateWithDuration:0.5f
    //                     animations:^{
    //                         self.contentScrollView.frame = self.originalFrame;
    //                     }];
}

- (void)openPicker:(JARadioComponent *)radioComponent
{
    [self removePickerView];
    
    self.radioComponent = radioComponent;
    
    if([radioComponent isComponentWithKey:@"fk_customer_address_region"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
    {
        self.radioComponentDataset = self.regionsDataset;
        
        [self setupPickerView];
    }
    else if([radioComponent isComponentWithKey:@"fk_customer_address_city"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
    {
        if(VALID_NOTEMPTY(self.citiesDataset, NSArray))
        {
            self.radioComponentDataset = self.citiesDataset;
            
            [self setupPickerView];
        }
        else
        {
            NSString *url = [radioComponent getApiCallUrl];
            [self showLoading];
            [RICity getCitiesForUrl:url region:[self.selectedRegion uid] successBlock:^(NSArray *regions)
             {
                 self.citiesDataset = [regions copy];
                 self.radioComponentDataset = [regions copy];
                 
                 [self hideLoading];
                 [self setupPickerView];
             } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error)
             {
                 [self hideLoading];
             }];
        }
    }
}

-(NSString*)getPickerSelectedRow
{
    NSString *selectedValue = [self.radioComponent getSelectedValue];
    NSString *selectedRow = @"";
    if(VALID_NOTEMPTY(selectedValue, NSString))
    {
        if(VALID_NOTEMPTY(self.radioComponentDataset, NSArray))
        {
            for (int i = 0; i < [self.radioComponentDataset count]; i++)
            {
                id selectedObject = [self.radioComponentDataset objectAtIndex:i];
                if(VALID_NOTEMPTY(selectedObject, RIRegion))
                {
                    if([selectedValue isEqualToString:[selectedObject uid]])
                    {
                        selectedRow = ((RIRegion*)selectedObject).name;
                        break;
                    }
                }
                else if(VALID_NOTEMPTY(selectedObject, RICity))
                {
                    if([selectedValue isEqualToString:[selectedObject uid]])
                    {
                        selectedRow = ((RICity*)selectedObject).value;
                        break;
                    }
                }
            }
        }
    }
    return selectedRow;
}

-(void) setupPickerView
{
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY(self.radioComponentDataset, NSArray))
    {
        for(id currentObject in self.radioComponentDataset)
        {
            NSString *title = @"";
            if(VALID_NOTEMPTY(currentObject, RIRegion))
            {
                title = ((RIRegion*) currentObject).name;
            }
            else if(VALID_NOTEMPTY(currentObject, RICity))
            {
                title = ((RICity*) currentObject).value;
            }
            [dataSource addObject:title];
        }
    }
    
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:[self getPickerSelectedRow]];
    
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

- (void)downloadRegions:(JARadioComponent *)regionComponent cities:(JARadioComponent*) citiesComponent
{
    if(VALID_NOTEMPTY(regionComponent, JARadioComponent) && VALID_NOTEMPTY(citiesComponent, JARadioComponent))
    {
        if(!VALID_NOTEMPTY(self.regionsDataset, NSArray))
        {
            [self showLoading];
            [RIRegion getRegionsForUrl:[regionComponent getApiCallUrl] successBlock:^(NSArray *regions)
             {
                 self.regionsDataset = [regions copy];
                 
                 NSString *selectedValue = [self.editAddress customerAddressRegionId];
                 
                 if(VALID_NOTEMPTY(selectedValue, NSString) && VALID_NOTEMPTY(regions, NSArray))
                 {
                     for(RIRegion *region in regions)
                     {
                         if([selectedValue isEqualToString:[region uid]])
                         {
                             self.selectedRegion = region;
                             [self.dynamicForm setRegionValue:region];
                             break;
                         }
                         
                     }
                 }
                 else if(VALID_NOTEMPTY(regions, NSArray))
                 {
                     self.selectedRegion = [regions objectAtIndex:0];
                     [regionComponent setRegionValue:self.selectedRegion];
                 }
                 
                 if(VALID_NOTEMPTY(self.selectedRegion, RIRegion))
                 {
                     [RICity getCitiesForUrl:[citiesComponent getApiCallUrl] region:[self.selectedRegion uid] successBlock:^(NSArray *cities) {
                         self.citiesDataset = [cities copy];
                         
                         NSString *selectedValue = [self.editAddress customerAddressCityId];
                         if(VALID_NOTEMPTY(cities, NSArray))
                         {
                             if(VALID_NOTEMPTY(selectedValue, NSString))
                             {
                                 for(RICity *city in cities)
                                 {
                                     if([selectedValue isEqualToString:[city uid]])
                                     {
                                         self.selectedCity = city;
                                         [self.dynamicForm setCityValue:self.selectedCity];
                                         break;
                                     }
                                 }
                             }
                             
                             if(!VALID_NOTEMPTY(self.selectedCity, RICity))
                             {
                                 self.selectedCity =  [cities objectAtIndex:0];
                                 [self.dynamicForm setCityValue:self.selectedCity];
                             }
                         }
                         
                         [self hideLoading];
                         
                     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                         [self hideLoading];
                     }];
                 }
             } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error)
             {
                 [self hideLoading];
             }];
        }
    }
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent))
    {
        if(VALID_NOTEMPTY(self.radioComponentDataset, NSArray) && selectedRow < [self.radioComponentDataset count])
        {
            id selectedObject = [self.radioComponentDataset objectAtIndex:selectedRow];
            
            if(VALID_NOTEMPTY(selectedObject, RIRegion) && ![[selectedObject uid] isEqualToString:[self.selectedRegion uid]])
            {
                self.selectedRegion = selectedObject;
                self.selectedCity = nil;
                self.citiesDataset = nil;
                
                [self.dynamicForm setRegionValue:selectedObject];
            }
            else if(VALID_NOTEMPTY(selectedObject, RICity))
            {
                self.selectedCity = selectedObject;
                
                [self.dynamicForm setCityValue:selectedObject];
            }
        }
    }
    
    [self removePickerView];
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
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView setFrame:CGRectMake(self.originalFrame.origin.x,
                                                    self.originalFrame.origin.y,
                                                    self.originalFrame.size.width,
                                                    self.originalFrame.size.height - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView setFrame:self.originalFrame];
    }];
}

@end
