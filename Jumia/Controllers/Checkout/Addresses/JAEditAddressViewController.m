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
#import "RICheckout.h"
#import "RIRegion.h"
#import "RICity.h"

@interface JAEditAddressViewController ()
<JADynamicFormDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate>

// Steps
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepIconLeftConstrain;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLabelWidthConstrain;

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
@property (strong, nonatomic) UIView *pickerBackgroundView;
@property (strong, nonatomic) UIToolbar *pickerToolbar;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIPickerView *pickerView;

// Create Address Button
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@property (assign, nonatomic) BOOL hasErrors;
@property (strong, nonatomic) NSString *nextStep;
@property (strong, nonatomic) RICheckout *checkout;

@end

@implementation JAEditAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.title = STRING_CHECKOUT;
    
    self.navBarLayout.showCartButton = NO;
    
    self.hasErrors = NO;
    
    [self setupViews];
    
    [RIForm getForm:@"addressedit"
       successBlock:^(RIForm *form)
     {
         self.dynamicForm = [[JADynamicForm alloc] initWithForm:form delegate:self values:[self getAddressValues] startingPosition:self.addressViewCurrentY];

         for(UIView *view in self.dynamicForm.formViews)
         {
             [self.contentView addSubview:view];
             self.addressViewCurrentY = CGRectGetMaxY(view.frame);
         }
         
         [self finishedFormLoading];
     }
       failureBlock:^(NSArray *errorMessage)
     {
         [self finishedFormLoading];
         
         [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                     message:@"There was an error"
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:STRING_OK, nil] show];
     }];
}

-(void)setupViews
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
    
    self.originalFrame = self.contentScrollView.frame;
    
    [self setupAddressView];
    
    [self.view addSubview:self.contentScrollView];    
    
    self.bottomView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero];
    [self.bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - 64.0f - self.bottomView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
    [self.bottomView addButton:STRING_CANCEL target:self action:@selector(cancelButtonPressed)];
    [self.bottomView addButton:STRING_SAVE_CHANGES target:self action:@selector(saveChangesButtonPressed)];
    
    [self.view addSubview:self.bottomView];
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
    self.addressViewCurrentY = 0.0f;
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.contentScrollView.frame.size.height)];
    [self.contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.contentView.layer.cornerRadius = 5.0f;
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, self.addressViewCurrentY, self.contentView.frame.size.width - 12.0f, 25.0f)];
    [self.headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.headerLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.headerLabel setText:STRING_EDIT_ADDRESS];
    [self.headerLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.headerLabel];
    self.addressViewCurrentY = CGRectGetMaxY(self.headerLabel.frame);
    
    self.headerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.addressViewCurrentY, self.contentView.frame.size.width, 1.0f)];
    [self.headerSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.contentView addSubview:self.headerSeparator];
    self.addressViewCurrentY = CGRectGetMaxY(self.headerSeparator.frame) + 6.0f;
    
    [self.contentScrollView addSubview:self.contentView];
}

-(void)finishedFormLoading
{
    self.addressViewCurrentY += 6.0f;
    
    [self.contentView setFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.addressViewCurrentY)];
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.contentView.frame.origin.y + self.contentView.frame.size.height + self.bottomView.frame.size.height)];
}

-(void)saveChangesButtonPressed
{
    [self showLoading];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self.dynamicForm getValues]];
    
    [parameters setValue:[self.editAddress uid] forKey:@"Alice_Module_Customer_Model_AddressForm[id_customer_address]"];
    [parameters setValue:[self.editAddress isDefaultShipping] forKey:@"Alice_Module_Customer_Model_AddressForm[is_default_shipping]"];
    [parameters setValue:[self.editAddress isDefaultBilling] forKey:@"Alice_Module_Customer_Model_AddressForm[is_default_billing]"];
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:parameters
        successBlock:^(id object)
     {
         self.checkout = object;
         [self.dynamicForm resetValues];
         [self finishedRequests];
         
     } andFailureBlock:^(id errorObject)
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
         
         [self finishedRequests];
     }];
}

-(void)cancelButtonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

-(void)finishedRequests
{
    [self hideLoading];
    
    if(self.hasErrors)
    {
        [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                    message:STRING_ERROR_INVALID_FIELDS
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:STRING_OK, nil] show];
        self.hasErrors = NO;
    }
    else
    {
        [JAUtils goToCheckoutNextStep:self.checkout.nextStep inStoryboard:self.storyboard];
    }
}

-(void)radioOptionChanged:(id)sender
{
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent))
    {
        NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
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
    self.datePickerView = nil;
    self.pickerBackgroundView = nil;
    self.radioComponent = nil;
    self.radioComponentDataset = nil;
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    CGPoint scrollPoint = CGPointMake(0.0, view.frame.origin.y);
    [self.contentScrollView setContentOffset:scrollPoint
                                    animated:YES];
}

- (void) lostFocus
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.contentScrollView.frame = self.originalFrame;
                     }];
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
             } andFailureBlock:^(NSArray *error)
             {
                 [self hideLoading];
             }];
        }
    }
}

-(NSInteger)getPickerSelectedRow
{
    NSString *selectedValue = [self.radioComponent getSelectedValue];
    NSInteger selectedRow = 0;
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
                        selectedRow = i;
                        break;
                    }
                }
                else if(VALID_NOTEMPTY(selectedObject, RICity))
                {
                    if([selectedValue isEqualToString:[selectedObject uid]])
                    {
                        selectedRow = i;
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
    
    [self.pickerView selectRow:[self getPickerSelectedRow] inComponent:0 animated:NO];
    
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
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [button setTitle:STRING_DONE forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(radioOptionChanged:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.pickerToolbar setItems:[NSArray arrayWithObjects:flexibleItem, doneButton, nil]];
    [self.pickerBackgroundView addSubview:self.pickerToolbar];
    
    [self.pickerBackgroundView addSubview:self.pickerView];
    [self.view addSubview:self.pickerBackgroundView];
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
                         
                     } andFailureBlock:^(NSArray *error) {
                         [self hideLoading];
                     }];
                 }
             } andFailureBlock:^(NSArray *error)
             {
                 [self hideLoading];
             }];
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
    if(VALID_NOTEMPTY(self.radioComponentDataset , NSArray))
    {
        numberOfRowsInComponent = [self.radioComponentDataset count];
    }
    return numberOfRowsInComponent;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *titleForRow = @"";
    if(VALID_NOTEMPTY(self.radioComponentDataset, NSArray) && row < [self.radioComponentDataset count])
    {
        id currentObject = [self.radioComponentDataset objectAtIndex:row];
        if(VALID_NOTEMPTY(currentObject, RIRegion))
        {
            titleForRow = ((RIRegion*) currentObject).name;
        }
        else if(VALID_NOTEMPTY(currentObject, RICity))
        {
            titleForRow = ((RICity*) currentObject).value;
        }
        
    }
    return  titleForRow;
}

@end
