//
//  SignInViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SignInViewController.h"
#import "InputTextFieldControl.h"
#import "UIScrollView+Extension.h"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet InputTextFieldControl *emailControl;
@property (weak, nonatomic) IBOutlet InputTextFieldControl *passwordControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UITextField *activeField;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.scrollView.delegate = self;
}

- (void)setupView {
    
    FormItemValidation *emailValidation = [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter: [NSString emailRegxPattern]];
    [self.emailControl setModel: [[FormItemModel alloc] initWithTitle:nil andIcon:[UIImage imageNamed:@"Email"] placeholder:@"ایمیل" validation:emailValidation]];
    self.emailControl.type = InputTextFieldControlTypeEmail;
    
    
    FormItemValidation *passValidation = [[FormItemValidation alloc] initWithRequired:YES max:50 min:6 withRegxPatter:nil];
    [self.passwordControl setModel: [[FormItemModel alloc] initWithTitle:nil andIcon:[UIImage imageNamed:@"Password"] placeholder:@"کلمه عبور" validation:passValidation]];
    self.passwordControl.type = InputTextFieldControlTypePassword;

    
    self.emailControl.input.textField.delegate = self;
    self.passwordControl.input.textField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self unregisterForKeyboardNotifications];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard notifications

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}



#pragma mark - TextField delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}



- (IBAction)submitLogin:(id)sender {
    
    if (![self.emailControl isValid] || ![self.passwordControl isValid]) {
        return;
    }
    
    [[DataManager sharedInstance] loginUserViaUsername:@"aliunco90@gmail.com" password:@"ali1123581321" complitionBlock:^(RIApiResponse response, id data, NSArray *errorMessages) {
        
    }];
}


@end
