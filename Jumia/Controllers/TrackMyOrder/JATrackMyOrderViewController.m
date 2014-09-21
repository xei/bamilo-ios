//
//  JATrackMyOrderViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATrackMyOrderViewController.h"
#import "RIOrder.h"

@interface JATrackMyOrderViewController ()
<
    UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *trackOrderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLine;
@property (weak, nonatomic) IBOutlet UITextField *orderTextField;
@property (weak, nonatomic) IBOutlet UIButton *buttonTrack;
@property (weak, nonatomic) IBOutlet UILabel *labelAsterisco;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTextField;
@property (weak, nonatomic) IBOutlet UIView *variableView;
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *variableViewHeightConstraint;

@end

@implementation JATrackMyOrderViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initViewElements];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)trackOrder:(id)sender
{
    self.variableView.hidden = YES;
    
    [self.view endEditing:YES];
    
    if (self.orderTextField.text.length > 0)
    {
        [self showLoading];
        
        [RIOrder trackOrderWithOrderNumber:self.orderTextField.text
                          WithSuccessBlock:^(RITrackOrder *trackingOrder) {
                              
                              [self buildContentForOrder:trackingOrder];
                              
                              [self hideLoading];
                              
                          } andFailureBlock:^(NSArray *errorMessages) {
                              
                              [self builContentForNoResult];
                              
                              [self hideLoading];
                              
                          }];
    }
    else
    {
#warning add string here
        JAErrorView *errorView = [JAErrorView getNewJAErrorView];
        [errorView setErrorTitle:@"Please enter the order ID."
                        andAddTo:self];
    }
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self trackOrder:nil];
    
    return YES;
}

#pragma mark - Build variable content

- (void)buildContentForOrder:(RITrackOrder *)order
{
    // Clean the variable view if the user track another order
    for (UIView *view in self.variableView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            if (view != self.orderIdLabel) {
                [view removeFromSuperview];
            }
        }
    }
    
    self.variableView.hidden = NO;
    
    float startingY = self.lineImageView.frame.origin.y + 10;
    
    self.orderIdLabel.text = [NSString stringWithFormat:@"# %@", order.orderId];
    
    // Creation date
    UILabel *creationDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 150, 20)];
    creationDateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    creationDateLabel.textColor = UIColorFromRGB(0x4e4e4e);
    creationDateLabel.text = STRING_CREATION_DATE;
    [creationDateLabel sizeToFit];
    [self.variableView addSubview:creationDateLabel];
    
    UILabel *creationDateLabelDetail = [[UILabel alloc] initWithFrame:CGRectMake(creationDateLabel.frame.size.width + 12, startingY, 200, 20)];
    creationDateLabelDetail.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    creationDateLabelDetail.textColor = UIColorFromRGB(0x666666);
    creationDateLabelDetail.text = order.creationDate;
    [creationDateLabelDetail sizeToFit];
    [self.variableView addSubview:creationDateLabelDetail];
    
    startingY += creationDateLabel.frame.size.height + 10;
    
    // Payment method
    UILabel *paymentMethodLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 150, 20)];
    paymentMethodLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    paymentMethodLabel.textColor = UIColorFromRGB(0x4e4e4e);
    paymentMethodLabel.text = STRING_PAYMENT_METHOD;
    [paymentMethodLabel sizeToFit];
    [self.variableView addSubview:paymentMethodLabel];
    
    UILabel *paymentMethodLabelDetail = [[UILabel alloc] initWithFrame:CGRectMake(paymentMethodLabel.frame.size.width + 12, startingY, 200, 20)];
    paymentMethodLabelDetail.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    paymentMethodLabelDetail.textColor = UIColorFromRGB(0x666666);
    paymentMethodLabelDetail.text = order.paymentMethod;
    [paymentMethodLabelDetail sizeToFit];
    [self.variableView addSubview:paymentMethodLabelDetail];
    
    startingY += paymentMethodLabelDetail.frame.size.height + 20;
    
    // Products label
    UILabel *productsLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 20)];
    productsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    productsLabel.textColor = UIColorFromRGB(0x4e4e4e);
    productsLabel.text = STRING_PRODUCTS;
    [productsLabel sizeToFit];
    [self.variableView addSubview:productsLabel];
    
    startingY += productsLabel.frame.size.height + 20;
    
    for (RIItemCollection *item in order.itemCollection)
    {
        UILabel *labelProductName = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 40)];
        labelProductName.numberOfLines = 0;
        labelProductName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        labelProductName.textColor = UIColorFromRGB(0x4e4e4e);
        labelProductName.text = item.name;
        [labelProductName sizeToFit];
        [self.variableView addSubview:labelProductName];
        
        startingY += labelProductName.frame.size.height + 6;
        
        UILabel *labelQuantity = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 40)];
        labelQuantity.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        labelQuantity.textColor = UIColorFromRGB(0x666666);
        labelQuantity.text = [NSString stringWithFormat:STRING_QUANTITY, [item.quantity stringValue]];
        [labelQuantity sizeToFit];
        [self.variableView addSubview:labelQuantity];
        
        startingY += labelQuantity.frame.size.height + 6;
        
        RIStatus *status = [item.status firstObject];
        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, startingY, 296, 20)];
        statusLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        statusLabel.textColor = UIColorFromRGB(0x666666);
        statusLabel.text = status.itemStatus;
        [statusLabel sizeToFit];
        [self.variableView addSubview:statusLabel];
        
        startingY += statusLabel.frame.size.height + 20;
    }
    
    self.variableView.frame = CGRectMake(self.variableView.frame.origin.x,
                                         self.variableView.frame.origin.y,
                                         self.variableView.frame.size.width,
                                         startingY);
    
    self.variableViewHeightConstraint.constant = startingY + self.lineImageView.frame.size.height - 12;
    
    [self.view needsUpdateConstraints];
    
    self.contentScrollView.contentSize = CGSizeMake(320, self.variableView.frame.size.height + self.topView.frame.size.height + 10);
}

- (void)builContentForNoResult
{    
    // Clean the variable view if the user track another order
    for (UIView *view in self.variableView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            if (view != self.orderIdLabel) {
                [view removeFromSuperview];
            }
        }
    }
    
    self.variableView.hidden = NO;
    
    self.orderIdLabel.text = [NSString stringWithFormat:@"# %@", self.orderTextField.text];
    
    UILabel *noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.lineImageView.frame.origin.y + 10, 268, 40)];
    noResultsLabel.textAlignment = NSTextAlignmentCenter;
    noResultsLabel.numberOfLines = 0;
    noResultsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    noResultsLabel.textColor = UIColorFromRGB(0x666666);
    noResultsLabel.text = STRING_ERROR_NO_RESULTS_FOR_TRACKING_ID;
    [self.variableView addSubview:noResultsLabel];
    
    self.variableViewHeightConstraint.constant = noResultsLabel.frame.size.height + 46;
    
    [self.view needsUpdateConstraints];
    
    self.contentScrollView.contentSize = CGSizeMake(320, self.variableView.frame.size.height + self.topView.frame.size.height + 10);
}

#pragma mark - Init elements

- (void)initViewElements
{
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_ORDER_STATUS;
    
    self.topView.layer.cornerRadius = 4.0f;
    
    self.trackOrderLabel.text = STRING_TRACK_YOUR_ORDER;
    self.trackOrderLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.imageViewLine.backgroundColor = UIColorFromRGB(0xfaa41a);
    
    self.orderTextField.placeholder = STRING_ORDER_ID;
    self.orderTextField.textColor = UIColorFromRGB(0x666666);
    if (VALID_NOTEMPTY(self.startingTrackOrderNumber, NSString)) {
        self.orderTextField.text = self.startingTrackOrderNumber;
    }
    
    self.imageViewTextField.backgroundColor = UIColorFromRGB(0xcccccc);
    
    [self.buttonTrack setTitle:STRING_TRACK_ORDER
                      forState:UIControlStateNormal];
    
    [self.buttonTrack setTitleColor:UIColorFromRGB(0x4e4e4e)
                           forState:UIControlStateNormal];
    
    self.orderIdLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.variableView.layer.cornerRadius = 4.0f;
}

@end
