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
#import "JAOrderSummaryView.h"
#import "JAPicker.h"
#import "RIForm.h"
#import "RILocale.h"
#import "RICustomer.h"
#import "UIView+Mirror.h"
#import "UIImage+Mirror.h"
#import "RIFieldOption.h"
#import "JAProductInfoHeaderLine.h"
#import "JAButton.h"

@interface JAAddNewAddressViewController ()
<JADynamicFormDelegate,
JAPickerDelegate>
{}

// Add Address
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (assign, nonatomic) CGFloat contentScrollOriginalHeight;
@property (assign, nonatomic) CGFloat orderSummaryOriginalHeight;

// Shipping Address
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) JAProductInfoHeaderLine* headerLine;
@property (strong, nonatomic) UIView *headerSeparator;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (assign, nonatomic) CGFloat addressViewCurrentY;
@property (strong, nonatomic) RILocale *selectedRegion;
@property (strong, nonatomic) RILocale *selectedCity;
@property (strong, nonatomic) NSArray *citiesDataset;
@property (strong, nonatomic) RILocale *selectedPostcode;
@property (strong, nonatomic) NSArray *postcodesDataset;

@property (strong, nonatomic) NSArray *regionsDataset;

// Picker view
@property (strong, nonatomic) JARadioComponent *radioComponent;
@property (strong, nonatomic) NSArray *radioComponentDataset;
@property (strong, nonatomic) JAPicker *picker;

// Create Address Button
@property (strong, nonatomic) JAButton *bottomButton;

@property (assign, nonatomic) BOOL hasErrors;

// Order summary
@property (strong, nonatomic) JAOrderSummaryView *orderSummary;

@property (strong, nonatomic) NSDictionary *extraParameters;

@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAAddNewAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    
    if (self.fromCheckout) {
        self.navBarLayout.showCartButton = NO;
        self.navBarLayout.title = STRING_CHECKOUT;
    } else {
        self.navBarLayout.title = STRING_MY_ADDRESSES;
    }
    
    self.hasErrors = NO;
    self.extraParameters = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:kOpenMenuNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initViews];
    [self getForms];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"NewAddress"];
}

- (void)getForms {
    if(RIApiResponseSuccess == self.apiResponse) {
        [self showLoading];
    }
    self.apiResponse = RIApiResponseSuccess;
    [RIForm getForm:@"addresscreate" forceRequest:YES successBlock:^(RIForm *form) {
        self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.addressViewCurrentY widthSize:self.contentView.frame.size.width hasFieldNavigation:NO];
        [self.dynamicForm setDelegate:self];
        [self getLocales];
        
        for(UIView *view in self.dynamicForm.formViews) {
            [self.contentView addSubview:view];
        }
        
        [self finishedFormLoading];
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"CheckoutMyAddress" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutAddresses]
                                                  data:[trackingDictionary copy]];
    } failureBlock:^(RIApiResponse apiResponse, NSArray *errorsArray) {
        self.apiResponse = apiResponse;
        
        [self onErrorResponse:self.apiResponse messages:nil showAsMessage:NO selector:@selector(getForms) objects:nil];
        [self hideLoading];
    }];
}

- (void)getLocales {
    for (JADynamicField* field in self.dynamicForm.formViews) {
        if ([field isKindOfClass:[JARadioComponent class]]) {
            JARadioComponent* radioComponent = (JARadioComponent*)field;
            
            if([radioComponent isComponentWithKey:@"region"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString)) {
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl] parameters:nil successBlock:^(NSArray *regions) {
                    self.regionsDataset = [regions copy];
                    
                    for (RILocale* region in self.regionsDataset) {
                        if ([region.value isEqualToString:[radioComponent getSelectedValue]]) {
                            [self.dynamicForm setRegionValue:region];
                            self.selectedRegion = region;
                            break;
                        }
                    }
                } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                }];
            } else if([radioComponent isComponentWithKey:@"city"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString)) {
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.dynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *cities) {
                                  self.citiesDataset = [cities copy];
                                  
                                  for (RILocale* city in self.citiesDataset) {
                                      if ([city.value isEqualToString:[radioComponent getSelectedValue]]) {
                                          [self.dynamicForm setCityValue:city];
                                          self.selectedCity = city;
                                          break;
                                      }
                                  }
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                              }];
            } else if([radioComponent isComponentWithKey:@"postcode"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString)) {
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.dynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *postcodes) {
                                  self.postcodesDataset = [postcodes copy];

                                  for (RILocale* postcode in self.postcodesDataset) {
                                      if ([postcode.value isEqualToString:[radioComponent getSelectedValue]]) {
                                          [self.dynamicForm setPostcodeValue:postcode];
                                          self.selectedPostcode = postcode;
                                          break;
                                      }
                                  }
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        }
    }
}


- (void)hideKeyboard {
    [self.dynamicForm resignResponder];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if(VALID(self.picker, JAPicker)) {
        [self.picker removeFromSuperview];
    }
    [self showLoading];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         CGFloat newWidth = self.view.frame.size.width;
         if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(orientation) && self.fromCheckout) {
             newWidth = self.view.frame.size.height + self.view.frame.origin.y;
         }
         
         [self setupViews:newWidth toInterfaceOrientation:orientation];
         
         [self.dynamicForm resignResponder];
         
         [self hideLoading];
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

-(void)initViews {
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.contentScrollView.backgroundColor = JAWhiteColor;
    [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentScrollView setShowsVerticalScrollIndicator:NO];
    
    [self initAddressView];
    
    [self.view addSubview:self.contentScrollView];

    self.bottomButton = [[JAButton alloc] initButtonWithTitle:STRING_SAVE_LABEL target:self action:@selector(createAddressButtonPressed)];
    [self.bottomButton setFrame:CGRectMake(0.0f,
                                           self.view.frame.size.height - 48.0f,
                                           self.view.frame.size.width,
                                           48.0f)];
    [self.view addSubview:self.bottomButton];
}

-(void)initAddressView {
    self.headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.contentScrollView.frame.size.width, 38.0f)];
    [self.headerLine.label setText:[STRING_ADD_NEW_ADDRESS uppercaseString]];
    [self.contentScrollView addSubview:self.headerLine];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.headerLine.frame), self.contentScrollView.frame.size.width, 27.0f)];
    [self.contentView setHidden:YES];
    [self.contentView setBackgroundColor:JAWhiteColor];
    [self.contentScrollView addSubview:self.contentView];
}

-(void)finishedFormLoading {
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) && self.fromCheckout)
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    [self hideLoading];
    
    [self publishScreenLoadTime];
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    CGFloat scrollViewStartY = 0.0f;
    
    if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
    {
        [self.orderSummary removeFromSuperview];
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && (width < self.view.frame.size.width) && self.fromCheckout)
    {
        CGFloat orderSummaryRightMargin = 0.0f;
        self.orderSummary = [[JAOrderSummaryView alloc] initWithFrame:CGRectMake(width,
                                                                                 scrollViewStartY,
                                                                                 self.view.frame.size.width - width - orderSummaryRightMargin,
                                                                                 self.view.frame.size.height - scrollViewStartY)];
        [self.orderSummary loadWithCart:self.cart];
        [self.view addSubview:self.orderSummary];
        self.orderSummaryOriginalHeight = self.orderSummary.frame.size.height;
    }
    
    [self.bottomButton setFrame:CGRectMake(0.0f,
                                           self.view.frame.size.height - 48.0f,
                                           self.view.frame.size.width,
                                           48.0f)];
    [self.view bringSubviewToFront:self.bottomButton];
    
    [self.contentScrollView setFrame:CGRectMake(0.0f,
                                                scrollViewStartY,
                                                width,
                                                self.view.frame.size.height - scrollViewStartY - self.bottomButton.frame.size.height)];
    
    [self.headerLine setFrame:CGRectMake(0.0f, 0.0f, self.contentScrollView.frame.size.width, 48.0f)];
    
    [self.contentView setFrame:CGRectMake(0.0f,
                                          CGRectGetMaxY(self.headerLine.frame),
                                          self.contentScrollView.frame.size.width,
                                          self.contentView.frame.size.height)];
    
    self.addressViewCurrentY = 0.0f;
    
    for(UIView *view in self.dynamicForm.formViews)
    {
        [view setFrame:CGRectMake(16.0f,
                                  self.addressViewCurrentY,
                                  self.contentView.frame.size.width - 32.0f,
                                  view.frame.size.height)];
        self.addressViewCurrentY += view.frame.size.height;
    }
    
    self.addressViewCurrentY += 6.0f;
    
    [self.contentView setFrame:CGRectMake(0.0f,
                                          CGRectGetMaxY(self.headerLine.frame),
                                          self.contentScrollView.frame.size.width,
                                          self.addressViewCurrentY)];
    [self.contentView setHidden:NO];
    self.contentScrollOriginalHeight = self.contentScrollView.frame.size.height;
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.contentView.frame.origin.y + self.contentView.frame.size.height)];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
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

-(void)createAddressButtonPressed
{
    self.hasErrors = NO;
    
    [self showLoading];
    if ([self.dynamicForm checkErrors]) {
        NSArray* message;
        if (VALID_NOTEMPTY(self.dynamicForm.firstErrorInFields, NSString)) {
            message = [NSArray arrayWithObject:self.dynamicForm.firstErrorInFields];
        }
        
        [self onErrorResponse:RIApiResponseSuccess messages:message showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
        [self hideLoading];
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self.dynamicForm getValues]];
    
    [RIForm sendForm:[self.dynamicForm form]
      extraArguments:self.extraParameters
          parameters:parameters
        successBlock:^(id object, NSArray* successMessages)
     {
         [self hideLoading];
         [self.dynamicForm resetValues];
         if (NOTEMPTY([object valueForKey:@"next_step"])) {
             self.cart.nextStep = [object valueForKey:@"next_step"];
         }
         [self finishedRequests];
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         [self hideLoading];
         self.hasErrors = YES;
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.dynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
             }];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.dynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
             }];
         }
         else
         {
             [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
         }
     }];
}

-(void)finishedRequests {
    [self hideLoading];
    
    if(self.hasErrors) {
        [self onErrorResponse:RIApiResponseSuccess messages:@[STRING_ERROR_INVALID_FIELDS] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
        
        self.hasErrors = NO;
    } else {
        if (self.fromCheckout) {
            [JAUtils goToNextStep:self.cart.nextStep userInfo:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                                object:nil
                                                              userInfo:nil];
        }
    }
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view {
    //    CGPoint scrollPoint = CGPointMake(0.0, view.frame.origin.y);
    //
    //    if(self.billingContentView == [view superview])
    //    {
    //        scrollPoint = CGPointMake(0.0, 6.0f + CGRectGetMaxY(self.shippingContentView.frame) + 6.0f + view.frame.origin.y);
    //    }
    //
    //    [self.contentScrollView setContentOffset:scrollPoint
    //                                    animated:YES];
}

- (void)lostFocus {
    //    [UIView animateWithDuration:0.5f
    //                     animations:^{
    //                         self.contentScrollView.frame = self.originalFrame;
    //                     }];
}

- (NSDictionary*)getRequestParametersForRadioComponent:(JARadioComponent*)component andForm:(JADynamicForm*)dynamicForm {
    
    NSMutableDictionary* requestParameters = [NSMutableDictionary new];
    NSDictionary* parameterMap = [component getApiCallParameters];
    
    if (VALID_NOTEMPTY(parameterMap, NSDictionary)) {
        [parameterMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //look for value of field corresponding to key
            for (JADynamicField* field in dynamicForm.formViews) {
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
        }];
    }
    return [requestParameters copy];
}

- (void)openPicker:(JARadioComponent *)radioComponent {
    [self.dynamicForm resignResponder];
    [self removePickerView];
    self.radioComponent = radioComponent;
    if([radioComponent isComponentWithKey:@"region"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString)) {
        [self showLoading];
        [RILocale getLocalesForUrl:[radioComponent getApiCallUrl] parameters:nil successBlock:^(NSArray *regions) {
            self.regionsDataset = [regions copy];
            self.radioComponentDataset = [regions copy];
            [self hideLoading];
            [self setupPickerView];
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
            [self hideLoading];
        }];
    } else if([radioComponent isComponentWithKey:@"city"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString)) {
        if(self.contentView == [radioComponent superview]) {
            if(VALID_NOTEMPTY(self.citiesDataset, NSArray)) {
                self.radioComponentDataset = self.citiesDataset;
                [self setupPickerView];
            } else {
                [self showLoading];
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.dynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *cities) {
                                  self.citiesDataset = [cities copy];
                                  self.radioComponentDataset = [cities copy];
                                  
                                  [self hideLoading];
                                  [self setupPickerView];
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        } else if(self.contentView == [radioComponent superview]) {
            if(VALID_NOTEMPTY(self.citiesDataset, NSArray)) {
                self.radioComponentDataset = self.citiesDataset;
                [self setupPickerView];
            } else {
                [self showLoading];
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.dynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl] parameters:requestParameters successBlock:^(NSArray *cities) {
                                  self.citiesDataset = [cities copy];
                                  self.radioComponentDataset = [cities copy];
                                  [self hideLoading];
                                  [self setupPickerView];
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        }
    } else if([radioComponent isComponentWithKey:@"postcode"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString)) {
        if(self.contentView == [radioComponent superview]) {
            if(VALID_NOTEMPTY(self.postcodesDataset, NSArray)) {
                self.radioComponentDataset = self.postcodesDataset;
                [self setupPickerView];
            } else {
                [self showLoading];
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.dynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *postcodes) {
                                  self.postcodesDataset = [postcodes copy];
                                  self.radioComponentDataset = [postcodes copy];
                                  [self hideLoading];
                                  [self setupPickerView];
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        }
    } else if([radioComponent isComponentWithKey:@"gender"]) {
        if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY([self.radioComponent options], NSArray)) {
            self.radioComponentDataset  = [[self.radioComponent options] copy];
            [self setupPickerView];
        }
    }
}

-(NSString*)getPickerSelectedRow {
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
        for(id currentObject in self.radioComponentDataset)
        {
            NSString *title = @"";
            if(VALID_NOTEMPTY(currentObject, RILocale))
            {
                title = ((RILocale*) currentObject).label;
            }
            else if(VALID_NOTEMPTY(currentObject, NSString))
            {
                title = currentObject;
            }
            [dataSource addObject:title];
        }
    }
    
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

- (IBAction)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    if (VALID_NOTEMPTY(self.radioComponent, JARadioComponent)
        && VALID_NOTEMPTY(self.radioComponentDataset, NSArray)
        && selectedRow < [self.radioComponentDataset count]) {
        
        id selectedObject = [self.radioComponentDataset objectAtIndex:selectedRow];
        
        if (self.contentView == [self.radioComponent superview]) {
            if (VALID_NOTEMPTY(selectedObject, RILocale)
                && [self.radioComponent isComponentWithKey:@"region"]
                && ![[(RILocale*)selectedObject value] isEqualToString:[self.selectedRegion value]]) {
                
                self.selectedRegion = selectedObject;
                self.selectedCity = nil;
                self.citiesDataset = nil;
                self.selectedPostcode = nil;
                self.postcodesDataset = nil;
                
                [self.dynamicForm setRegionValue:selectedObject];
                [self.dynamicForm setCityValue:nil];
                [self.dynamicForm setPostcodeValue:nil];
            } else if (VALID_NOTEMPTY(selectedObject, RILocale) && [self.radioComponent isComponentWithKey:@"city"]) {
                self.selectedCity = selectedObject;
                self.selectedPostcode = nil;
                self.postcodesDataset = nil;
                
                [self.dynamicForm setCityValue:selectedObject];
                [self.dynamicForm setPostcodeValue:nil];
            } else if (VALID_NOTEMPTY(selectedObject, RILocale) && [self.radioComponent isComponentWithKey:@"postcode"]) {
                self.selectedPostcode = selectedObject;
                
                [self.dynamicForm setPostcodeValue:selectedObject];
            } else if (VALID_NOTEMPTY(selectedObject, NSString)) {
                [self.radioComponent setValue:selectedObject];
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
                                                    self.contentScrollOriginalHeight + self.headerLine.frame.size.height - height)];
        
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

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    return @"NewAddress";
}

@end
