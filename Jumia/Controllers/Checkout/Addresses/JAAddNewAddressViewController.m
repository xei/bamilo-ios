//
//  JAAddNewAddressViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 02/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddNewAddressViewController.h"
#import "JADynamicForm.h"
#import "JAUtils.h"
#import "JAButtonWithBlur.h"
#import "RIForm.h"
#import "RIRegion.h"
#import "RICity.h"
#import "RICheckout.h"

@interface JAAddNewAddressViewController ()
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

// Shipping Address
@property (strong, nonatomic) UIView *shippingContentView;
@property (strong, nonatomic) UILabel *shippingHeaderLabel;
@property (strong, nonatomic) UIView *shippingHeaderSeparator;
@property (strong, nonatomic) JADynamicForm *shippingDynamicForm;
@property (assign, nonatomic) CGFloat shippingAddressViewCurrentY;
@property (strong, nonatomic) RIRegion *shippingSelectedRegion;
@property (strong, nonatomic) RICity *shippingSelectedCity;
@property (strong, nonatomic) NSArray *shippingCitiesDataset;

// Billing Address
@property (strong, nonatomic) UIView *billingContentView;
@property (strong, nonatomic) UILabel *billingHeaderLabel;
@property (strong, nonatomic) UIView *billingHeaderSeparator;
@property (strong, nonatomic) JADynamicForm *billingDynamicForm;
@property (assign, nonatomic) CGFloat billingAddressViewCurrentY;
@property (strong, nonatomic) RIRegion *billingSelectedRegion;
@property (strong, nonatomic) RICity *billingSelectedCity;
@property (strong, nonatomic) NSArray *billingCitiesDataset;

// Picker view
@property (strong, nonatomic) JARadioComponent *radioComponent;
@property (strong, nonatomic) NSArray *regionsDataset;
@property (strong, nonatomic) NSArray *radioComponentDataset;
@property (strong, nonatomic) UIView *pickerBackgroundView;
@property (strong, nonatomic) UIToolbar *pickerToolbar;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIPickerView *pickerView;

// Create Address Button
@property (strong, nonatomic) UIButton *createAddressButton;

@property (assign, nonatomic) NSInteger numberOfRequests;
@property (assign, nonatomic) BOOL hasErrors;
@property (strong, nonatomic) NSString *nextStep;
@property (strong, nonatomic) RICheckout *checkout;

@end

@implementation JAAddNewAddressViewController

@synthesize numberOfRequests=_numberOfRequests;
-(void)setNumberOfRequests:(NSInteger)numberOfRequests
{
    _numberOfRequests=numberOfRequests;
    if (0 == numberOfRequests) {
        [self finishedRequests];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasErrors = NO;
    
    if(!self.isBillingAddress || !self.isShippingAddress)
    {
        self.navBarLayout.backButtonTitle = @"Checkout";
        self.navBarLayout.showLogo = NO;
    }
    
    [self setupViews];
    
    [RIForm getForm:@"addresscreate"
       successBlock:^(RIForm *form)
     {
         self.shippingDynamicForm = [[JADynamicForm alloc] initWithForm:form delegate:self startingPosition:self.shippingAddressViewCurrentY];
         
         for(UIView *view in self.shippingDynamicForm.formViews)
         {
             [self.shippingContentView addSubview:view];
             self.shippingAddressViewCurrentY = CGRectGetMaxY(view.frame);
         }
         
         self.billingDynamicForm = [[JADynamicForm alloc] initWithForm:form delegate:self startingPosition:self.billingAddressViewCurrentY];
         
         for(UIView *view in self.billingDynamicForm.formViews)
         {
             [self.billingContentView addSubview:view];
             self.billingAddressViewCurrentY = CGRectGetMaxY(view.frame);
         }
         
         [self finishedFormLoading];
     }
       failureBlock:^(NSArray *errorMessage)
     {
         [self finishedFormLoading];
         
         [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                     message:@"There was an error"
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil] show];
     }];
}

-(void)setupViews
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
    
    self.originalFrame = self.contentScrollView.frame;
    
    [self setupShippingAddressView];
    [self setupBillingAddressView];
    
    [self.view addSubview:self.contentScrollView];
    
    JAButtonWithBlur *bottomView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero];
    [bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - 64.0f - bottomView.frame.size.height, self.view.frame.size.width, bottomView.frame.size.height)];
    [bottomView addButton:@"Next" target:self action:@selector(createAddressButtonPressed)];
    
    [self.view addSubview:bottomView];
}

-(void)setupShippingAddressView
{
    self.shippingAddressViewCurrentY = 0.0f;
    
    self.shippingContentView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.contentScrollView.frame.size.height)];
    [self.shippingContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.shippingContentView.layer.cornerRadius = 5.0f;
    
    self.shippingHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, self.shippingAddressViewCurrentY, self.shippingContentView.frame.size.width - 12.0f, 25.0f)];
    [self.shippingHeaderLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.shippingHeaderLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.shippingHeaderLabel setText:@"Add New Address"];
    [self.shippingHeaderLabel setBackgroundColor:[UIColor clearColor]];
    [self.shippingContentView addSubview:self.shippingHeaderLabel];
    self.shippingAddressViewCurrentY = CGRectGetMaxY(self.shippingHeaderLabel.frame);
    
    self.shippingHeaderSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.shippingAddressViewCurrentY, self.shippingContentView.frame.size.width, 1.0f)];
    [self.shippingHeaderSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.shippingContentView addSubview:self.shippingHeaderSeparator];
    self.shippingAddressViewCurrentY = CGRectGetMaxY(self.shippingHeaderSeparator.frame) + 6.0f;
    
    [self.contentScrollView addSubview:self.shippingContentView];
}

-(void)setupBillingAddressView
{
    self.billingAddressViewCurrentY = 0.0f;
    
    self.billingContentView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.contentScrollView.frame.size.height)];
    [self.billingContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.billingContentView.layer.cornerRadius = 5.0f;
    [self.billingContentView setHidden:YES];
    
    self.billingHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, self.billingAddressViewCurrentY, self.billingContentView.frame.size.width - 12.0f, 25.0f)];
    [self.billingHeaderLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.billingHeaderLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.billingHeaderLabel setText:@"Billing Address"];
    [self.billingHeaderLabel setBackgroundColor:[UIColor clearColor]];
    [self.billingContentView addSubview:self.billingHeaderLabel];
    self.billingAddressViewCurrentY = CGRectGetMaxY(self.billingHeaderLabel.frame);
    
    self.billingHeaderSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.billingAddressViewCurrentY, self.billingContentView.frame.size.width, 1.0f)];
    [self.billingHeaderSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.billingContentView addSubview:self.billingHeaderSeparator];
    self.billingAddressViewCurrentY = CGRectGetMaxY(self.billingHeaderSeparator.frame) + 6.0f;
    
    [self.contentScrollView addSubview:self.billingContentView];
}

-(void)finishedFormLoading
{
    if(self.isBillingAddress && self.isShippingAddress)
    {
        JACheckBoxComponent *check = [JACheckBoxComponent getNewJACheckBoxComponent];
        [check setup];
        [check.labelText setText:@"Billing to the same address"];
        [check.switchComponent setOn:YES];
        [check.switchComponent addTarget:self action:@selector(changedAddressState:) forControlEvents:UIControlEventValueChanged];
        
        CGRect frame = check.frame;
        frame.origin.y = self.shippingAddressViewCurrentY;
        check.frame = frame;
        
        self.shippingAddressViewCurrentY = CGRectGetMaxY(check.frame);
        [self.shippingContentView addSubview:check];
    }
    
    if(!self.isBillingAddress || !self.isShippingAddress)
    {
        self.shippingAddressViewCurrentY += 12.0f;
    }
    else
    {
        self.shippingAddressViewCurrentY += 6.0f;
    }
    
    [self.shippingContentView setFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.shippingAddressViewCurrentY)];
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.shippingContentView.frame.origin.y + self.shippingContentView.frame.size.height + self.self.createAddressButton.frame.size.height + 6.0f + 10.0f)];
}

-(void)showBillingAddressForm
{
    [self.shippingHeaderLabel setText:@"Shipping Address"];
    
    [self.billingContentView setHidden:NO];
    [self.billingContentView setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.shippingContentView.frame) + 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.billingAddressViewCurrentY + 12.0f)];
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.shippingContentView.frame.origin.y + self.shippingContentView.frame.size.height + 6.0f + self.billingContentView.frame.size.height + self.createAddressButton.frame.size.height + 6.0f + 10.0f)];
}

-(void)hideBillingAddressForm
{
    [self.shippingHeaderLabel setText:@"Add New Address"];
    [self.billingDynamicForm resetValues];
    
    [self.billingContentView setHidden:YES];
    [self.shippingContentView setFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.shippingAddressViewCurrentY)];
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.shippingContentView.frame.origin.y + self.shippingContentView.frame.size.height + self.createAddressButton.frame.size.height + 6.0f + 10.0f)];
}

-(void)changedAddressState:(id)sender
{
    UISwitch *switchView = sender;
    if([switchView isOn])
    {
        [self hideBillingAddressForm];
    }
    else
    {
        [self showBillingAddressForm];
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
            
            if(self.shippingContentView == [self.radioComponent superview])
            {
                if(VALID_NOTEMPTY(selectedObject, RIRegion) && ![[selectedObject uid] isEqualToString:[self.shippingSelectedRegion uid]])
                {
                    self.shippingSelectedRegion = selectedObject;
                    self.shippingSelectedCity = nil;
                    self.shippingCitiesDataset = nil;
                    
                    [self.shippingDynamicForm setRegionValue:selectedObject];
                }
                else if(VALID_NOTEMPTY(selectedObject, RICity))
                {
                    self.shippingSelectedCity = selectedObject;

                    [self.shippingDynamicForm setCityValue:selectedObject];
                }
            }
            else if(self.billingContentView == [self.radioComponent superview])
            {
                if(VALID_NOTEMPTY(selectedObject, RIRegion) && ![[selectedObject uid] isEqualToString:[self.billingSelectedRegion uid]])
                {
                    self.billingSelectedRegion = selectedObject;
                    self.billingSelectedCity = nil;
                    self.billingCitiesDataset = nil;

                    [self.billingDynamicForm setRegionValue:selectedObject];
                }
                else if(VALID_NOTEMPTY(selectedObject, RICity))
                {
                    self.billingSelectedCity = selectedObject;
                    
                    [self.billingDynamicForm setCityValue:selectedObject];
                }
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

-(void)createAddressButtonPressed
{
    [self showLoading];
    
    self.numberOfRequests = 1;
    
    NSMutableDictionary *shippingParameters = [[NSMutableDictionary alloc] initWithDictionary:[self.shippingDynamicForm getValues]];
    
    [shippingParameters setValue:@"1" forKey:@"is_default_shipping"];
    [shippingParameters setValue:@"1" forKey:@"is_default_billing"];
    
    if(![self.billingContentView isHidden])
    {
        self.numberOfRequests = 2;
        
        [shippingParameters setValue:@"0" forKey:@"is_default_billing"];
        
        NSMutableDictionary *billingParameters = [[NSMutableDictionary alloc] initWithDictionary:[self.billingDynamicForm getValues]];
        
        [billingParameters setValue:@"0" forKey:@"is_default_shipping"];
        [billingParameters setValue:@"1" forKey:@"is_default_billing"];
        
        [RIForm sendForm:[self.billingDynamicForm form]
              parameters:billingParameters
            successBlock:^(id object)
         {
             self.checkout = object;
             [self.billingDynamicForm resetValues];
             self.numberOfRequests--;
         } andFailureBlock:^(id errorObject)
         {
             self.hasErrors = YES;
             self.numberOfRequests--;
             
             if(VALID_NOTEMPTY(errorObject, NSDictionary))
             {
                 [self.billingDynamicForm validateFields:errorObject];
             }
             else if(VALID_NOTEMPTY(errorObject, NSArray))
             {
                 [self.billingDynamicForm checkErrors];
             }
         }];
    }
    
    [RIForm sendForm:[self.shippingDynamicForm form]
          parameters:shippingParameters
        successBlock:^(id object)
     {
         self.checkout = object;
         [self.shippingDynamicForm resetValues];
         self.numberOfRequests--;
     } andFailureBlock:^(id errorObject)
     {
         self.hasErrors = YES;
         self.numberOfRequests--;
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.shippingDynamicForm validateFields:errorObject];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.shippingDynamicForm checkErrors];
         }
     }];
}

-(void)finishedRequests
{
    [self hideLoading];
    
    if(self.hasErrors)
    {
        [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                    message:@"Invalid Fields"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        self.hasErrors = NO;
    }
    else
    {
        [JAUtils getCheckoutNextStepViewController:self.checkout.nextStep inStoryboard:self.storyboard];
    }
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    CGPoint scrollPoint = CGPointMake(0.0, view.frame.origin.y);
    
    if(self.billingContentView == [view superview])
    {
        scrollPoint = CGPointMake(0.0, 6.0f + CGRectGetMaxY(self.shippingContentView.frame) + 6.0f + view.frame.origin.y);
    }
    
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
        if(self.shippingContentView == [radioComponent superview])
        {
            if(VALID_NOTEMPTY(self.shippingCitiesDataset, NSArray))
            {
                self.radioComponentDataset = self.shippingCitiesDataset;
                
                [self setupPickerView];
            }
            else
            {
                NSString *url = [radioComponent getApiCallUrl];
                [self showLoading];
                [RICity getCitiesForUrl:url region:[self.shippingSelectedRegion uid] successBlock:^(NSArray *regions)
                 {
                     self.shippingCitiesDataset = [regions copy];
                     self.radioComponentDataset = [regions copy];
                    
                     [self hideLoading];
                     [self setupPickerView];
                 } andFailureBlock:^(NSArray *error)
                 {
                     [self hideLoading];
                 }];
            }
        }
        else if(self.billingContentView == [radioComponent superview])
        {
            if(VALID_NOTEMPTY(self.billingCitiesDataset, NSArray))
            {
                self.radioComponentDataset = self.billingCitiesDataset;
                
                [self setupPickerView];
            }
            else
            {
                NSString *url = [radioComponent getApiCallUrl];
                [self showLoading];
                [RICity getCitiesForUrl:url region:[self.shippingSelectedRegion uid] successBlock:^(NSArray *regions)
                 {
                     self.billingCitiesDataset = [regions copy];
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
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [button setTitle:@"Done" forState:UIControlStateNormal];
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
                 
                 NSString *selectedValue = [regionComponent getSelectedValue];
                 
                 if(VALID_NOTEMPTY(selectedValue, NSString) && VALID_NOTEMPTY(regions, NSArray))
                 {
                     for(RIRegion *region in regions)
                     {
                         if([selectedValue isEqualToString:[region uid]])
                         {
                             self.shippingSelectedRegion = region;
                             self.billingSelectedRegion = region;

                             [self.shippingDynamicForm setRegionValue:region];
                             [self.billingDynamicForm setRegionValue:region];
                             
                             break;
                         }
                         
                     }
                 }
                 else if(VALID_NOTEMPTY(regions, NSArray))
                 {
                     self.shippingSelectedRegion = [regions objectAtIndex:0];
                     self.billingSelectedRegion = [regions objectAtIndex:0];
                     [regionComponent setRegionValue:self.shippingSelectedRegion];
                 }
                 
                 if(VALID_NOTEMPTY(self.shippingSelectedRegion, RIRegion))
                 {
                     [RICity getCitiesForUrl:[citiesComponent getApiCallUrl] region:[self.shippingSelectedRegion uid] successBlock:^(NSArray *cities) {
                         self.shippingCitiesDataset = [cities copy];
                         self.billingCitiesDataset = [cities copy];
                         
                         if(VALID_NOTEMPTY(cities, NSArray))
                         {
                             RICity *city = [cities objectAtIndex:0];
                             
                             self.shippingSelectedCity = city;
                             self.billingSelectedCity = city;
                             
                             [self.shippingDynamicForm setCityValue:city];
                             [self.billingDynamicForm setCityValue:city];
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
