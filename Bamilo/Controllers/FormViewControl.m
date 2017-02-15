//
//  FormViewControl.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormViewControl.h"
#import "BasicTableViewCell.h"

@interface FormViewControl ()
@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) NSMutableDictionary<NSString *, InputTextFieldControl*> *inputControlsDictionary;
@property (nonatomic) NSUInteger numberOfRowsOfTableView;

@end

@implementation FormViewControl

//Lazy initialization for inputControlsDictionary
- (NSMutableDictionary<NSString *,InputTextFieldControl *> *)inputControlsDictionary {
    if (!_inputControlsDictionary) {
        _inputControlsDictionary = [[NSMutableDictionary<NSString *,InputTextFieldControl *> alloc] init];
    }
    return _inputControlsDictionary;
}


- (void)registerDelegationsAndDataSourceForTableview {
    //Tableview registrations
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib: [UINib nibWithNibName:[FormTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[FormTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[BasicTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[BasicTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[ButtonTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[ButtonTableViewCell nibName]];
    
    self.tableView.multipleTouchEnabled = NO;
}



#pragma mark - tableviewDelegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.formMessage && indexPath.row == 0) {
        BasicTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BasicTableViewCell nibName] forIndexPath:indexPath];
        cell.titleLabel.text = self.formMessage;
        return cell;
    }
    
    if (indexPath.row == self.numberOfRowsOfTableView - 1) {
        ButtonTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ButtonTableViewCell nibName] forIndexPath:indexPath];
        cell.button.titleLabel.text = self.submitTitle;
        cell.delegate = self;
        return cell;
    }
    
    FormTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[FormTableViewCell nibName] forIndexPath:indexPath];
    cell.formItemControl.input.textField.delegate = self; 
    NSString *fieldName = self.formMessage ? self.formItemListModel.allKeys[indexPath.row - 1] : self.formItemListModel.allKeys[indexPath.row];
    cell.formItemControl.model = self.formItemListModel[fieldName];
    cell.formItemControl.fieldName = fieldName;
    self.inputControlsDictionary[fieldName] = cell.formItemControl;
    cell.formItemControl.delegate = self;
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
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.tableView.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.tableView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
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
    
    [self.formItemListModel enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, FormItemModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if(![obj.validation checkValiditionOfString:obj.titleString].boolValue) {
            result = NO;
            *stop = YES;
        }
    }];
    return result;
}

#pragma mark - form submission abstract method
- (void)buttonTapped:(id)cell {
    [self.delegate viewNeedsToEndEditing];
    [self.delegate submitBtnTapped];
}

#pragma mark - InputTextFieldControlDelegate
- (void)inputValueHasBeenChanged:(id)inputTextFieldControl byNewValue:(NSString *)value inFieldName:(NSString *)fieldname {
    self.formItemListModel[fieldname].titleString = value;
}

- (void)showErrorMessgaeForField:(NSString *)fieldName errorMsg:(NSString *)string {
    [self.inputControlsDictionary[fieldName] showErrorMsg:string];
}

@end
