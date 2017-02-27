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
@property (nonatomic) Boolean tableViewRegistered;
@end

@implementation FormViewControl

//Lazy initialization for inputControlsDictionary
- (NSMutableDictionary<NSString *,InputTextFieldControl *> *)inputControlsDictionary {
    if (!_inputControlsDictionary) {
        _inputControlsDictionary = [[NSMutableDictionary<NSString *,InputTextFieldControl *> alloc] init];
    }
    return _inputControlsDictionary;
}

- (void)setupTableView {
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
    [self.tableView setContentInset: self.tableViewInitialInsets];
    self.tableViewRegistered = YES;
}

- (void)setFormListModel:(NSMutableArray<FormItemModel *> *)formListModel {
    _formListModel = formListModel;
    [self reloadViewIfItsPossible];
}

- (void)updateFieldIndex:(NSUInteger)index WithUpdateModelBlock:(updateModelWithPreviousModel)block {
    self.formListModel[index] = block(self.formListModel[index]);
}

- (NSMutableDictionary *)getMutableDictionaryOfForm {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [self.formListModel enumerateObjectsUsingBlock:^(FormItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        params[obj.fieldName] = [obj getValue];
    }];
    return params;
}

- (void)refreshView {
    [self reloadViewIfItsPossible];
}

- (void)reloadViewIfItsPossible {
    if (self.tableViewRegistered) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
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
        [cell.button setTitle:self.submitTitle forState:UIControlStateNormal];
        cell.delegate = self;
        return cell;
    }
    
    FormTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[FormTableViewCell nibName] forIndexPath:indexPath];
    cell.formItemControl.input.textField.delegate = self; 
    NSUInteger fieldIndex = self.formMessage ? indexPath.row - 1 : indexPath.row;
    cell.formItemControl.model = self.formListModel[fieldIndex];
    cell.formItemControl.fieldIndex = fieldIndex;
    self.inputControlsDictionary[self.formListModel[fieldIndex].fieldName] = cell.formItemControl;
    cell.formItemControl.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.numberOfRowsOfTableView = self.formListModel.count + 1 + (self.formMessage != nil);
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

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableViewInitialInsets.top, self.tableViewInitialInsets.left, kbSize.height, self.tableViewInitialInsets.right);
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
    UIEdgeInsets contentInsets = self.tableViewInitialInsets;
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
    [self.formListModel enumerateObjectsUsingBlock:^(FormItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![obj.validation checkValiditionOfString:[obj getValue]].boolValue) {
            result = NO;
            *stop = YES;
        }
    }];
    return result;
}

#pragma mark - form submission abstract method
- (void)buttonTapped:(id)cell {
    [self.activeField resignFirstResponder];
    [self.delegate formSubmitButtonTapped];
}

#pragma mark - InputTextFieldControlDelegate
- (void)inputValueHasBeenChanged:(id)inputTextFieldControl byNewValue:(NSString *)value inFieldIndex:(NSUInteger)fieldIndex {
    
    self.formListModel[fieldIndex].titleString = value;
    
    if ([self.formListModel[fieldIndex].validation checkValiditionOfString:[self.formListModel[fieldIndex] getValue]].boolValue) {
        
        if ([self.delegate respondsToSelector:@selector(fieldHasBeenUpdatedByNewValidValue:inFieldIndex:)]){
            [self.delegate fieldHasBeenUpdatedByNewValidValue:value inFieldIndex:fieldIndex];
        }
    }
}

- (void)showErrorMessgaeForField:(NSString *)fieldName errorMsg:(NSString *)string {
    [self.inputControlsDictionary[fieldName] showErrorMsg:string];
}

- (void)showAnyErrorInForm {
    [self.inputControlsDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, InputTextFieldControl * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj checkValidation];
    }];
}

@end
