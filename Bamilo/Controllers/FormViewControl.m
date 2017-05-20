//
//  FormViewControl.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormViewControl.h"
#import "FormHeaderTableViewCell.h"

@interface FormViewControl ()
@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) NSMutableDictionary<NSString *, InputTextFieldControl*> *inputControlsDictionary;
@property (nonatomic) NSUInteger numberOfRowsOfTableView;
@property (nonatomic) BOOL tableViewRegistered;
@end

@implementation FormViewControl {
@private UIEdgeInsets tableViewInitialInsets;
@private BOOL allErrorsHaveBeenShown;
}

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
    [self.tableView registerNib:[UINib nibWithNibName:[FormHeaderTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[FormHeaderTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[FormTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[FormTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[ButtonTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[ButtonTableViewCell nibName]];
    self.tableView.multipleTouchEnabled = NO;
    tableViewInitialInsets = self.tableView.contentInset;
    self.tableViewRegistered = YES;
}

- (void)setFormModelList:(NSMutableArray *)formModelList {
    _formModelList = formModelList;
    [self reloadViewIfPossible];
}

- (void)updateFieldIndex:(NSUInteger)index WithUpdateModelBlock:(updateModelWithPreviousModel)block {
    self.formModelList[index] = block(self.formModelList[index]);
}

- (NSMutableDictionary *)getMutableDictionaryOfForm {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [self.formModelList enumerateObjectsUsingBlock:^(FormItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[FormItemModel class]]) {
            return;
        }
        params[obj.fieldName] = [obj getValue];
    }];
    return params;
}

- (void)refreshView {
    [self reloadViewIfPossible];
}

- (void)reloadViewIfPossible {
    if (self.tableViewRegistered) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.numberOfRowsOfTableView - 1) {
        ButtonTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ButtonTableViewCell nibName] forIndexPath:indexPath];
        [cell.button setTitle:self.submitTitle forState:UIControlStateNormal];
        cell.delegate = self;
        return cell;
    } else {
        id<FormElementProtocol> formElement = self.formModelList[indexPath.row];
        if([formElement isKindOfClass:[FormItemModel class]]) {
            FormTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[FormTableViewCell nibName] forIndexPath:indexPath];
            cell.formItemControl.input.textField.delegate = self;
            cell.formItemControl.model = self.formModelList[indexPath.row];
            cell.formItemControl.fieldIndex = indexPath.row;
            self.inputControlsDictionary[((FormItemModel *)formElement).fieldName] = cell.formItemControl;
            cell.formItemControl.delegate = self;
            if (allErrorsHaveBeenShown) {
                [cell.formItemControl checkValidation];
            }
            return cell;
        } else if([formElement isKindOfClass:[FormHeaderModel class]]) {
            FormHeaderTableViewCell *formHeaderItemTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:[FormHeaderTableViewCell nibName] forIndexPath:indexPath];
            formHeaderItemTableViewCell.titleString  = ((FormHeaderModel *)formElement).headerString;
            return formHeaderItemTableViewCell;
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfRowsOfTableView = self.formModelList.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.formModelList.count && [[self.formModelList objectAtIndex:indexPath.row] isKindOfClass:[FormHeaderModel class]]) {
        return [FormHeaderTableViewCell cellHeight];
    } else {
        return UITableViewAutomaticDimension;
    }
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

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(tableViewInitialInsets.top, tableViewInitialInsets.left, kbSize.height, tableViewInitialInsets.right);
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
    UIEdgeInsets contentInsets = tableViewInitialInsets;
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
    [self.formModelList enumerateObjectsUsingBlock:^(FormItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[FormItemModel class]]) {
            return;
        }
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
    
    FormItemModel *model = self.formModelList[fieldIndex];
    model.inputTextValue = value;
    
    if ([model.validation checkValiditionOfString:[model getValue]].boolValue) {
        if ([self.delegate respondsToSelector:@selector(fieldHasBeenUpdatedByNewValidValue:inFieldIndex:)]){
            [self.delegate fieldHasBeenUpdatedByNewValidValue:value inFieldIndex:fieldIndex];
        }
    }
}

- (BOOL)showErrorMessageForField:(NSString *)fieldName errorMsg:(NSString *)string {
    InputTextFieldControl *inputTextFieldControl = [self.inputControlsDictionary objectForKey:fieldName];
    if(inputTextFieldControl) {
        [self.inputControlsDictionary[fieldName] showErrorMsg:string];
        return YES;
    }
    
    return NO;
}

- (void)showAnyErrorInForm {
    allErrorsHaveBeenShown = YES;
    [self.inputControlsDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, InputTextFieldControl * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj checkValidation];
    }];
}

@end
