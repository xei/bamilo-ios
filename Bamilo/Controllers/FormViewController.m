//
//  FormViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormViewController.h"
#import "FormTableViewCell.h"
#import "BasicTableViewCell.h"

@interface FormViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableview;
@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic) NSUInteger numberOfRowsOfTableView;

@end

@implementation FormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Tableview registrations
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview registerNib: [UINib nibWithNibName:[FormTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[FormTableViewCell nibName]];
    [self.tableview registerNib:[UINib nibWithNibName:[BasicTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[BasicTableViewCell nibName]];
    [self.tableview registerNib:[UINib nibWithNibName:[ButtonTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[ButtonTableViewCell nibName]];
}



#pragma mark - tableviewDelegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.formMessage && indexPath.row == 0) {
        BasicTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:[BasicTableViewCell nibName] forIndexPath:indexPath];
        cell.titleLabel.text = self.formMessage;
        return cell;
    }
    
    if (indexPath.row == self.numberOfRowsOfTableView - 1) {
        ButtonTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:[ButtonTableViewCell nibName] forIndexPath:indexPath];
        cell.button.titleLabel.text = self.submitTitle;
        cell.delegate = self;
        return cell;
    }
    
    FormTableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:[FormTableViewCell nibName] forIndexPath:indexPath];
    cell.formItemControl.input.textField.delegate = self; 
    cell.formItemControl.model = self.formMessage ? self.formItemListModel[indexPath.row - 1] : self.formItemListModel[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.numberOfRowsOfTableView = self.formMessage ? self.formItemListModel.count + 2 : self.formItemListModel.count + 1;
    return self.numberOfRowsOfTableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (void)viewDidAppear:(BOOL)animated {
    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self unregisterForKeyboardNotifications];
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
    self.tableview.contentInset = contentInsets;
    self.tableview.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.tableview scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableview.contentInset = contentInsets;
    self.tableview.scrollIndicatorInsets = contentInsets;
}


#pragma mark - TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

#pragma mark - helper functions

- (Boolean)isFormValid {
    __block Boolean result = YES;
    
    [self.formItemListModel enumerateObjectsUsingBlock:^(FormItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj.validation checkValiditionOfString:obj.titleString].boolValue) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

#pragma mark - form submission abstract method
- (void)buttonTapped:(id)cell {
    return;
}
@end
