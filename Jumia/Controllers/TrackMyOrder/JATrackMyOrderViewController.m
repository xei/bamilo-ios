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

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *trackOrderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLine;
@property (weak, nonatomic) IBOutlet UITextField *orderTextField;
@property (weak, nonatomic) IBOutlet UIButton *buttonTrack;
@property (weak, nonatomic) IBOutlet UILabel *labelAsterisco;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTextField;

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

#pragma mark - Init elements

- (void)initViewElements
{
    self.topView.layer.cornerRadius = 4.0f;
    
    self.trackOrderLabel.text = @"Track Your Order";
    self.trackOrderLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.imageViewLine.backgroundColor = UIColorFromRGB(0xfaa41a);
    
    self.orderTextField.placeholder = @"Order ID";
    self.orderTextField.textColor = UIColorFromRGB(0xcccccc);
    
    self.imageViewTextField.backgroundColor = UIColorFromRGB(0xcccccc);
    
    [self.buttonTrack setTitle:@"Track Order"
                      forState:UIControlStateNormal];
    
    [self.buttonTrack setTitleColor:UIColorFromRGB(0x4e4e4e)
                           forState:UIControlStateNormal];
    
#warning remove this
    self.orderTextField.text = @"301956292";
}

#pragma mark - Actions

- (IBAction)trackOrder:(id)sender
{
    [self.view endEditing:YES];
    
    [self showLoading];
    
    if (self.orderTextField.text.length > 0)
    {
        [RIOrder trackOrderWithOrderNumber:self.orderTextField.text
                          WithSuccessBlock:^(RITrackOrder *trackingOrder) {
                              
                              [self hideLoading];
                              
                              NSLog(@"Aqui");
                              
                          } andFailureBlock:^(NSArray *errorMessages) {
                              
                              [self hideLoading];
                              
                              NSLog(@"Ali");
                              
                          }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                    message:@"Please enter the order ID."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
    }
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
