//
//  JAFormComponent.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAFormComponent.h"

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
                
                return NO;
            }
        }
    }
    
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

@end

@implementation JACheckBoxComponent

@end

@implementation JABirthDateComponent

@end

@implementation JAGenderComponent

- (void)initSegmentedControl:(NSArray *)itens
{
    NSInteger i = 0;
    for (NSString *temp in itens) {
        [self.segmentedControl setTitle:temp
                      forSegmentAtIndex:i];
        
        i++;
    }
}

@end

@implementation JAFormComponent


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

+ (JACheckBoxComponent *)getNewJACheckBoxComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JACheckBoxComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JACheckBoxComponent class]]) {
            return (JACheckBoxComponent *)obj;
        }
    }
    
    return nil;
}

+ (JABirthDateComponent *)getNewJABirthDateComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JABirthDateComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JABirthDateComponent class]]) {
            return (JABirthDateComponent *)obj;
        }
    }
    
    return nil;
}

+ (JAGenderComponent *)getNewJAGenderComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAGenderComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAGenderComponent class]]) {
            return (JAGenderComponent *)obj;
        }
    }
    
    return nil;
}

@end
