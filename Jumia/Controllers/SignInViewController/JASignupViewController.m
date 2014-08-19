//
//  JASignupViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASignupViewController.h"
#import "RIForm.h"
#import "RIField.h"
#import "RIFieldDataSetComponent.h"
#import "JAFormComponent.h"
#import "RICustomer.h"

@interface JASignupViewController ()
<
    UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) UIButton *registerButton;
@property (weak, nonatomic) UIButton *registerByFacebook;
@property (strong, nonatomic) NSMutableArray *fieldsArray;
@property (assign, nonatomic) CGRect originalFrame;
@property (strong, nonatomic) RIForm *tempForm;

@end

@implementation JASignupViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.originalFrame = self.contentScrollView.frame;
    self.fieldsArray = [NSMutableArray new];
    
    [self showLoading];
    
    [RIForm getForm:@"register"
       successBlock:^(RIForm *form) {
           [self hideLoading];
           
           self.tempForm = form;
           float startingY = 0.0f;
           BOOL addedBirth = NO;
           
           for (RIField *field in form.fields)
           {
               if ([field.type isEqualToString:@"integer"])
               {
                   if (!addedBirth)
                   {
                       JABirthDateComponent *birthDate = [JAFormComponent getNewJABirthDateComponent];
                       birthDate.labelText.text = @"Birthdate";
                       
                       birthDate.layer.cornerRadius = 4.0f;
                       CGRect frame = birthDate.frame;
                       frame.origin.y = startingY;
                       birthDate.frame = frame;
                       startingY += (birthDate.frame.size.height + 8);
                       
                       [self.contentScrollView addSubview:birthDate];
                       [self.fieldsArray addObject:birthDate];
                       
                       addedBirth = YES;
                   }
               }
               else if ([field.type isEqualToString:@"radio"])
               {
                   NSMutableArray *contentArray = [NSMutableArray new];
                   
                   for (RIFieldDataSetComponent *component in field.dataSet) {
                       [contentArray addObject:component.value];
                   }
                   
                   JAGenderComponent *gender = [JAFormComponent getNewJAGenderComponent];
                   [gender initSegmentedControl:[contentArray copy]];
                   
                   gender.layer.cornerRadius = 4.0f;
                   gender.labelText.text = field.label;
                   gender.field = field;
                
                   CGRect frame = gender.frame;
                   frame.origin.y = startingY;
                   gender.frame = frame;
                   startingY += (gender.frame.size.height + 8);
                
                   
                   [self.contentScrollView addSubview:gender];
                   [self.fieldsArray addObject:gender];
               }
               else if ([field.type isEqualToString:@"checkbox"])
               {
                   JACheckBoxComponent *check = [JAFormComponent getNewJACheckBoxComponent];
                   check.field = field;
                   
                   check.layer.cornerRadius = 4.0f;
                   CGRect frame = check.frame;
                   frame.origin.y = startingY;
                   check.frame = frame;
                   startingY += (check.frame.size.height + 8);
                   
                   check.labelText.text = field.label;
                   [self.contentScrollView addSubview:check];
                   [self.fieldsArray addObject:check];
               }
               else if ([field.type isEqualToString:@"string"] || [field.type isEqualToString:@"email"])
               {
                   JATextField *textField = [JAFormComponent getNewJATextField];
                   textField.field = field;
                   
                   textField.layer.cornerRadius = 4.0f;
                   CGRect frame = textField.frame;
                   frame.origin.y = startingY;
                   textField.frame = frame;
                   startingY += (textField.frame.size.height + 8);
                   
                   textField.textField.placeholder = field.label;
                   textField.textField.delegate = self;
                   
                   [self.contentScrollView addSubview:textField];
                   [self.fieldsArray addObject:textField];
               }
               else if ([field.type isEqualToString:@"password"] || [field.type isEqualToString:@"password2"])
               {
                   JATextField *textField = [JAFormComponent getNewJATextField];
                   textField.field = field;
                   
                   textField.layer.cornerRadius = 4.0f;
                   CGRect frame = textField.frame;
                   frame.origin.y = startingY;
                   textField.frame = frame;
                   startingY += (textField.frame.size.height + 8);
                   
                   textField.textField.placeholder = field.label;
                   textField.textField.secureTextEntry = YES;
                   textField.textField.delegate = self;
                   
                   [self.contentScrollView addSubview:textField];
                   [self.fieldsArray addObject:textField];
               }
           }
           
           self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
           self.registerButton.frame = CGRectMake(6.0, startingY, self.contentScrollView.frame.size.width - 12.0, 44.0);
           
           [self.registerButton setTitle:@"Register"
                                forState:UIControlStateNormal];
           
           [self.registerButton setTitleColor:[UIColor orangeColor]
                                     forState:UIControlStateNormal];
           
           [self.registerButton addTarget:self
                                   action:@selector(registerCustomer)
                         forControlEvents:UIControlEventTouchUpInside];
           
           CGRect frame = self.registerButton.frame;
           frame.origin.y = startingY;
           self.registerButton.frame = frame;
           startingY += (self.registerButton.frame.size.height + 8);
           
           [self.contentScrollView addSubview:self.registerButton];
           
           [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, startingY)];
           
       } failureBlock:^(NSArray *errorMessage) {
           [self hideLoading];
           
           [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil] show];
       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)registerCustomer
{
    [self.view endEditing:YES];
    
    BOOL hasErrors = NO;
    NSString *pass1 = @"";
    NSString *pass2 = @"";
    
    for (id obj in self.fieldsArray)
    {
        if ([obj isKindOfClass:[JATextField class]])
        {
            if (![obj isValid])
            {
                hasErrors = YES;
                break;
                
                return;
            }
            else
            {
                if ([((JATextField *)obj).field.key isEqualToString:@"password"])
                {
                    pass1 = ((JATextField *)obj).textField.text;
                }
                else if ([((JATextField *)obj).field.key isEqualToString:@"password2"])
                {
                    pass2 = ((JATextField *)obj).textField.text;
                }
            }
        }
    }
    
    if ((pass1.length > 0) && (pass2.length > 0))
    {
        if (![pass2 isEqualToString:pass1])
        {
            [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                        message:@"The passwords doesn't match."
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Ok", nil] show];
            
            return;
        }
    }
    
    if (!hasErrors)
    {
        NSMutableDictionary *tempDic = [NSMutableDictionary new];
        
        for (id obj in self.fieldsArray)
        {
            if ([obj isKindOfClass:[JABirthDateComponent class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd-MM-yyyy"];
                NSString *dateString = [dateFormatter stringFromDate:((JABirthDateComponent *)obj).datePicker.date];
                
                NSArray *components = [dateString componentsSeparatedByString:@"-"];
                
                for (RIField *field in self.tempForm.fields) {
                    if ([field.type isEqualToString:@"integer"])
                    {
                        if ([field.key isEqualToString:@"day"])
                        {
                            NSDictionary *dicDay = @{field.name : components[0]};
                            [tempDic addEntriesFromDictionary:dicDay];
                        }
                        else if ([field.key isEqualToString:@"month"])
                        {
                            NSDictionary *dicMonth = @{field.name : components[1]};
                            [tempDic addEntriesFromDictionary:dicMonth];
                        }
                        else if ([field.key isEqualToString:@"year"])
                        {
                            NSDictionary *dicYear = @{field.name : components[2]};
                            [tempDic addEntriesFromDictionary:dicYear];
                        }
                    }
                }
            }
            else if ([obj isKindOfClass:[JAGenderComponent class]])
            {
                NSInteger index = ((JAGenderComponent *)obj).segmentedControl.selectedSegmentIndex;
                NSString *selectedGender = [((JAGenderComponent *)obj).segmentedControl titleForSegmentAtIndex:index];
                
                NSDictionary *temp = @{((JAGenderComponent *)obj).field.name : selectedGender};
                [tempDic addEntriesFromDictionary:temp];
            }
            else if ([obj isKindOfClass:[JACheckBoxComponent class]])
            {
               if (((JACheckBoxComponent *)obj).switchComponent.on)
               {
                   NSDictionary *temp = @{((JACheckBoxComponent *)obj).field.name : @"YES"};
                   [tempDic addEntriesFromDictionary:temp];
               }
                else
                {
                    NSDictionary *temp = @{((JACheckBoxComponent *)obj).field.name : @"NO"};
                    [tempDic addEntriesFromDictionary:temp];
                }
            }
            else if ([obj isKindOfClass:[JATextField class]])
            {
                NSDictionary *temp = @{((JATextField *)obj).field.name : ((JATextField *)obj).textField.text};
                [tempDic addEntriesFromDictionary:temp];
            }
        }
        
        [self showLoading];
        
        [RICustomer registerCustomerWithParameters:[tempDic copy]
                                      successBlock:^(id customer) {
                                          [self hideLoading];
                                          
                                          [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                                              object:@{@"index": @(0),
                                                                                                       @"name": @"Home"}];
                                          
                                      } andFailureBlock:^(NSArray *errorObject) {
                                          [self hideLoading];
                                          
                                          [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                                                      message:@"Error registering user"
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:@"Ok", nil] show];
                                      }];
    }
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *superView = textField.superview;
    
    CGPoint scrollPoint = CGPointMake(0.0, superView.frame.origin.y - 130);
    [self.contentScrollView setContentOffset:scrollPoint
                                    animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.contentScrollView.frame = self.originalFrame;
                     }];
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
