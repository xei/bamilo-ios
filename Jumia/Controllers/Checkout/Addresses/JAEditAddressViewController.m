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
#import "RILocale.h"
#import "UIView+Mirror.h"
#import "UIImage+Mirror.h"
#import "RIAddress.h"
#import "RIForm.h"

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
@property (assign, nonatomic) CGFloat contentScrollOriginalHeight;
@property (assign, nonatomic) CGFloat orderSummaryOriginalHeight;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIView *headerSeparator;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (assign, nonatomic) CGFloat addressViewCurrentY;
@property (strong, nonatomic) RILocale *selectedRegion;
@property (strong, nonatomic) NSArray *regionsDataset;
@property (strong, nonatomic) RILocale *selectedCity;
@property (strong, nonatomic) NSArray *citiesDataset;
@property (strong, nonatomic) RILocale *selectedPostcode;
@property (strong, nonatomic) NSArray *postcodesDataset;

// Picker view
@property (strong, nonatomic) JARadioComponent *radioComponent;
@property (strong, nonatomic) NSArray *radioComponentDataset;
@property (strong, nonatomic) JAPicker *picker;

// Create Address Button
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@property (assign, nonatomic) BOOL hasErrors;

// Order summary
@property (strong, nonatomic) JAOrderSummaryView *orderSummary;

@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAEditAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"EditAddress";    
    
    self.navBarLayout.showBackButton = YES;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard)
                                                 name:kOpenMenuNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initViews];

    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    
    [self getForm];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"NewAddress"];
}

- (void) getForm
{
    if(RIApiResponseSuccess == self.apiResponse)
    {
        [self showLoading];
    }

    self.apiResponse = RIApiResponseSuccess;
    
    [RIForm getForm:[NSString stringWithFormat:@"%@%@", RI_API_FORMS_ADDRESS_EDIT, self.editAddress.uid]
       successBlock:^(RIForm *form) {
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form values:[self getAddressValues] startingPosition:self.addressViewCurrentY hasFieldNavigation:NO];
           
           [self.dynamicForm setDelegate:self];
           
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.contentView addSubview:view];
           }
           
           [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
           [self finishedFormLoading];
       } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
           self.apiResponse = apiResponse;
           [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(getForm) objects:nil];
           [self hideLoading];
       }];
}

- (void) hideKeyboard
{
    [self.dynamicForm resignResponder];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    [self showLoading];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && self.fromCheckout)
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
    if(self.fromCheckout)
    {
        self.stepBackground.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepView.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepIcon.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepLabel.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepLabel.font = [UIFont fontWithName:kFontBoldName size:self.stepLabel.font.pointSize];
        [self.stepLabel setText:STRING_CHECKOUT_ADDRESS];
        [self setupStepView:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    }
    else
    {
        [self.stepBackground removeFromSuperview];
        [self.stepView removeFromSuperview];
        [self.stepIcon removeFromSuperview];
        [self.stepLabel removeFromSuperview];
    }
    
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
    
    if(RI_IS_RTL){
        [self.stepBackground setImage:[stepBackgroundImage flipImageWithOrientation:UIImageOrientationUpMirrored]];
    }
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat scrollViewStartY = 0.0f;
    if(self.fromCheckout)
    {
        [self setupStepView:width toInterfaceOrientation:toInterfaceOrientation];
        scrollViewStartY = self.stepBackground.frame.size.height;
    }
    
    [self.contentScrollView setFrame:CGRectMake(0.0f,
                                                scrollViewStartY,
                                                width,
                                                self.view.frame.size.height - scrollViewStartY)];
    self.contentScrollOriginalHeight = self.contentScrollView.frame.size.height;
    
    self.addressViewCurrentY = CGRectGetMaxY(self.headerSeparator.frame) + 6.0f;
    
    if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
    {
        [self.orderSummary removeFromSuperview];
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)  && (width < self.view.frame.size.width) && self.fromCheckout)
    {
        CGFloat orderSummaryRightMargin = 6.0f;
        self.orderSummary = [[JAOrderSummaryView alloc] initWithFrame:CGRectMake(width,
                                                                                 scrollViewStartY,
                                                                                 self.view.frame.size.width - width - orderSummaryRightMargin,
                                                                                 self.view.frame.size.height - scrollViewStartY)];
        [self.orderSummary loadWithCart:self.cart];
        [self.view addSubview:self.orderSummary];
        self.orderSummaryOriginalHeight = self.orderSummary.frame.size.height;
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
    
    self.headerLabel.textAlignment = NSTextAlignmentLeft;
    [self.headerLabel setFrame:CGRectMake(6.0f, 0.0f, self.contentView.frame.size.width - 12.0f, 26.0f)];
    [self.headerSeparator setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.headerLabel.frame), self.contentView.frame.size.width, 1.0f)];
    
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width,
                                                      self.contentView.frame.origin.y + self.contentView.frame.size.height + self.bottomView.frame.size.height)];
    
    [self.bottomView reloadFrame:CGRectMake(0.0f,
                                            self.view.frame.size.height - self.bottomView.frame.size.height,
                                            width,
                                            self.bottomView.frame.size.height)];
    if(self.fromCheckout)
    {
        [self.bottomView addButton:STRING_CANCEL target:self action:@selector(cancelButtonPressed)];
    }
    [self.bottomView addButton:STRING_SAVE_CHANGES target:self action:@selector(saveChangesButtonPressed)];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
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
    [self.headerLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
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
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && self.fromCheckout)
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
    if ([self.dynamicForm checkErrors]) {
        [self onErrorResponse:RIApiResponseSuccess messages:@[self.dynamicForm.firstErrorInFields] showAsMessage:YES selector:@selector(saveChangesButtonPressed) objects:nil];
        [self hideLoading];
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self.dynamicForm getValues]];
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:parameters
        successBlock:^(id object, NSArray* successMessages)
     {
         [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
         [self.dynamicForm resetValues];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                             object:nil
                                                           userInfo:nil];
         [self hideLoading];
         
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         self.hasErrors = YES;
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.dynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(saveChangesButtonPressed) objects:nil];
             }];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.dynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(saveChangesButtonPressed) objects:nil];
             }];
         }else{
             [self onErrorResponse:apiResponse messages:@[STRING_ERROR_INVALID_FIELDS] showAsMessage:YES selector:@selector(saveChangesButtonPressed) objects:nil];
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

- (NSDictionary*)getRequestParametersForRadioComponent:(JARadioComponent*)component
{
    NSMutableDictionary* requestParameters = [NSMutableDictionary new];
    
    NSDictionary* parameterMap = [component getApiCallParameters];
    
    if (VALID_NOTEMPTY(parameterMap, NSDictionary)) {
        [parameterMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //look for value of field corresponding to key
            for (JADynamicField* field in self.dynamicForm.formViews) {
                if ([field isKindOfClass:[JARadioComponent class]]) {
                    //found the right class, so cast it
                    JARadioComponent* relatedComponent = (JARadioComponent*)field;
                    
                    //check for key
                    if ([relatedComponent isComponentWithKey:key]) {
                        //found the component, so look for value and add it to the request parameters
                        // using the object from the parameter map as the key
                        [requestParameters setValue:[relatedComponent getSelectedValue] forKey:obj];
                        break;
                    }
                }
            }
            //use the obj as the key in the request parameters
        }];
    }
    
    return [requestParameters copy];
}

- (void)openPicker:(JARadioComponent *)radioComponent
{
    [self removePickerView];
    
    self.radioComponent = radioComponent;
    
    if (VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString)) {
        
        
        NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent];

        if (VALID_NOTEMPTY([radioComponent getApiCallParameters], NSDictionary) && ISEMPTY(requestParameters)) {
            //if there is a map but the request parameters are empty, it means the prior fields were
            // not filled
            return;
        }
        [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                        parameters:requestParameters
                      successBlock:^(NSArray *locales) {
                          self.radioComponentDataset = locales;
                          [self setupPickerView];
                      } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                          
                      }];
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
                RILocale* selectedObject = [self.radioComponentDataset objectAtIndex:i];
                if(VALID_NOTEMPTY(selectedObject, RILocale))
                {
                    if([selectedValue isEqualToString:selectedObject.value])
                    {
                        selectedRow = selectedObject.label;
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
        for(RILocale* currentObject in self.radioComponentDataset)
        {
            NSString *title = @"";
            if(VALID_NOTEMPTY(currentObject, RILocale))
            {
                title = currentObject.label;
            }
            [dataSource addObject:title];
        }
    }
    
    if (VALID_NOTEMPTY(dataSource, NSMutableArray)) {
        [self.picker setDataSourceArray:[dataSource copy]
                           previousText:[self getPickerSelectedRow]
                        leftButtonTitle:nil];
        
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
}

- (void)downloadLocalesForComponents:(NSDictionary *)componentDictionary
{
    JARadioComponent* regionComponent = [componentDictionary objectForKey:@"regionComponent"];
    JARadioComponent* cityComponent = [componentDictionary objectForKey:@"cityComponent"];
    JARadioComponent* postcodeComponent = [componentDictionary objectForKey:@"postcodeComponent"];
    
    if(VALID_NOTEMPTY(regionComponent, JARadioComponent) )
    {
        if(!VALID_NOTEMPTY(self.regionsDataset, NSArray))
        {
            [self showLoading];
            [RILocale getLocalesForUrl:[regionComponent getApiCallUrl] parameters:nil successBlock:^(NSArray *regions)
             {
                 self.regionsDataset = [regions copy];
                 
                 NSString *selectedRegionId = regionComponent.field.value;
                 
                 if (VALID_NOTEMPTY(regions, NSArray)) {
                     if(VALID_NOTEMPTY(selectedRegionId, NSString))
                     {
                         for(RILocale *region in regions)
                         {
                             if([selectedRegionId isEqualToString:region.value])
                             {
                                 self.selectedRegion = region;
                                 [self.dynamicForm setRegionValue:region];
                                 break;
                             }
                             
                         }
                         
                         if(!VALID_NOTEMPTY(self.selectedRegion, RILocale))
                         {
                             self.selectedRegion =  [regions objectAtIndex:0];
                             [self.dynamicForm setRegionValue:self.selectedRegion];
                         }
                     }
                     else
                     {
                         self.selectedRegion = [regions objectAtIndex:0];
                         [self.dynamicForm setRegionValue:self.selectedRegion];
                     }
                 }
                 
                 if(VALID_NOTEMPTY(self.selectedRegion, RILocale) && VALID_NOTEMPTY(cityComponent, JARadioComponent))
                 {
                     NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:cityComponent];
                     [RILocale getLocalesForUrl:[cityComponent getApiCallUrl]
                                     parameters:requestParameters
                                   successBlock:^(NSArray *cities) {
                         self.citiesDataset = [cities copy];
                         
                         NSString *selectedCityId = cityComponent.field.value;
                         if (VALID_NOTEMPTY(cities, NSArray)) {
                             if(VALID_NOTEMPTY(selectedCityId, NSString))
                             {
                                 for(RILocale *city in cities)
                                 {
                                     if([selectedCityId isEqualToString:city.value])
                                     {
                                         self.selectedCity = city;
                                         [self.dynamicForm setCityValue:self.selectedCity];
                                         break;
                                     }
                                 }
                                 
                                 if(!VALID_NOTEMPTY(self.selectedCity, RILocale))
                                 {
                                     self.selectedCity =  [cities objectAtIndex:0];
                                     [self.dynamicForm setCityValue:self.selectedCity];
                                 }
                             }
                             else
                             {
                                 self.selectedCity = [cities objectAtIndex:0];
                                 [self.dynamicForm setCityValue:self.selectedCity];
                             }
                         }
                         
                         if (VALID_NOTEMPTY(self.selectedCity, RILocale) && VALID_NOTEMPTY(postcodeComponent, JARadioComponent)) {
                             
                             NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:postcodeComponent];
                             [RILocale getLocalesForUrl:[postcodeComponent getApiCallUrl]
                                             parameters:requestParameters
                                           successBlock:^(NSArray *postcodes) {
                                 self.postcodesDataset = [postcodes copy];
                                 
                                 NSString *selectedPostcodeId = postcodeComponent.field.value;
                                 if (VALID_NOTEMPTY(postcodes, NSArray)) {
                                     if(VALID_NOTEMPTY(selectedPostcodeId, NSString))
                                     {
                                         for(RILocale *postcode in postcodes)
                                         {
                                             if([selectedPostcodeId isEqualToString:postcode.value])
                                             {
                                                 self.selectedPostcode = postcode;
                                                 [self.dynamicForm setPostcodeValue:self.selectedPostcode];
                                                 break;
                                             }
                                         }
                                         
                                         if(!VALID_NOTEMPTY(self.selectedPostcode, RILocale))
                                         {
                                             self.selectedPostcode =  [postcodes objectAtIndex:0];
                                             [self.dynamicForm setPostcodeValue:self.selectedPostcode];
                                         }
                                     }
                                     else
                                     {
                                         self.selectedPostcode =  [postcodes objectAtIndex:0];
                                         [self.dynamicForm setPostcodeValue:self.selectedPostcode];
                                     }
                                 }
                                 
                                 [self hideLoading];
                             } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                                 [self hideLoading];
                             }];
                         } else {
                             [self hideLoading];
                         }
                     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                         [self hideLoading];
                     }];
                 }
                 else
                 {
                     [self hideLoading];
                 }
             } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error)
             {
                 [self hideLoading];
             }];
        }
    }
}

- (IBAction)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent))
    {
        if(VALID_NOTEMPTY(self.radioComponentDataset, NSArray) && selectedRow < [self.radioComponentDataset count])
        {
            RILocale* selectedObject = [self.radioComponentDataset objectAtIndex:selectedRow];
            
            if (VALID_NOTEMPTY(selectedObject, RILocale)) {
                
                if ([self.radioComponent isComponentWithKey:@"region"] && ![selectedObject.value isEqualToString:self.selectedRegion.value]) {
                    
                    self.selectedRegion = selectedObject;
                    self.selectedCity = nil;
                    self.citiesDataset = nil;
                    
                    [self.dynamicForm setRegionValue:selectedObject];
                    
                } else if ([self.radioComponent isComponentWithKey:@"city"] && ![selectedObject.value isEqualToString:self.selectedCity.value]) {
                    
                    self.selectedCity = selectedObject;
                    self.selectedPostcode = nil;
                    self.postcodesDataset = nil;
                    
                    [self.dynamicForm setCityValue:selectedObject];
                    
                } else if ([self.radioComponent isComponentWithKey:@"postcode"] && ![selectedObject.value isEqualToString:self.selectedPostcode.value])
                {
                    self.selectedPostcode = selectedObject;
                    
                    [self.dynamicForm setPostcodeValue:selectedObject];
                }
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
        [self.contentScrollView setFrame:CGRectMake(self.contentScrollView.frame.origin.x,
                                                    self.contentScrollView.frame.origin.y,
                                                    self.contentScrollView.frame.size.width,
                                                    self.contentScrollOriginalHeight - height)];
        
        if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
        {
            [self.orderSummary setFrame:CGRectMake(self.orderSummary.frame.origin.x,
                                                   self.orderSummary.frame.origin.y,
                                                   self.orderSummary.frame.size.width,
                                                   self.orderSummaryOriginalHeight - height)];
        }
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView setFrame:CGRectMake(self.contentScrollView.frame.origin.x,
                                                    self.contentScrollView.frame.origin.y,
                                                    self.contentScrollView.frame.size.width,
                                                    self.contentScrollOriginalHeight)];
        
        if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
        {
            [self.orderSummary setFrame:CGRectMake(self.orderSummary.frame.origin.x,
                                                   self.orderSummary.frame.origin.y,
                                                   self.orderSummary.frame.size.width,
                                                   self.orderSummaryOriginalHeight)];
        }
    }];
}

@end
