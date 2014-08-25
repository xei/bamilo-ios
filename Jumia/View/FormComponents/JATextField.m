//
//  JATextField.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATextField.h"

@implementation JATextField

- (BOOL)isValid
{
    if ((self.field.requiredMessage.length > 0) && (self.textField.text.length == 0))
    {
        [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                    message:self.field.requiredMessage
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
        
        self.textField.backgroundColor = [UIColor redColor];
        
        return NO;
    }
    else
    {
        if (self.field.regex.length > 0)
        {
            if (![self validateInputWithString:self.textField.text andRegularExpression:self.field.regex]) {
                [[[UIAlertView alloc] initWithTitle:@"Jumia iOS"
                                            message:@"Please verify the inserted data."
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Ok", nil] show];
                
                self.textField.backgroundColor = [UIColor redColor];
                
                return NO;
            }
        }
    }
    
    self.textField.backgroundColor = [UIColor whiteColor];
    
    return YES;
}

- (BOOL)validateInputWithString:(NSString *)aString
           andRegularExpression:(NSString *)regExp
{
    NSString * const regularExpression = regExp;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        NSLog(@"error %@", error);
    }
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:aString
                                                        options:0
                                                          range:NSMakeRange(0, [aString length])];
    return numberOfMatches > 0;
}


+ (JATextField *)getNewJATextField
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JATextField"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JATextField class]]) {
            return (JATextField *)obj;
        }
    }
    
    return nil;
}

@end
