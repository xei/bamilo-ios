//
//  RILocalizationWrapper.m
//  Comunication Project
//
//  Created by Pedro Lopes on 18/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RILocalizationWrapper.h"

@implementation RILocalizationWrapper

+ (NSString *)localizedString:(NSString *)key;
{
    NSString* returnString;
    
    NSArray *localeArray = [[NSUserDefaults standardUserDefaults] objectForKey:kLanguageCodeKey];
    
    static NSBundle * bundle = nil;
    NSString * path;
    
    if(VALID_NOTEMPTY(localeArray, NSArray))
    {
        NSDictionary *componentsFromLocale = [NSLocale componentsFromLocaleIdentifier:[localeArray objectAtIndex:0]];
        NSString *languageCode = [componentsFromLocale objectForKey:NSLocaleLanguageCode];
        
        path = [[NSBundle mainBundle] pathForResource:languageCode
                                               ofType:@"lproj"];
        bundle = [[NSBundle alloc] initWithPath:path];
        
        returnString = NSLocalizedStringFromTableInBundle(key, @"RIStrings", bundle, key);
        
    }
    
    if(ISEMPTY(localeArray) || ISEMPTY(bundle) || NO == VALID(bundle, NSBundle) || [returnString isEqualToString:key] || ISEMPTY(returnString))
    {
        path = [[NSBundle mainBundle] pathForResource:@"en"
                                               ofType:@"lproj"];
        bundle = [[NSBundle alloc] initWithPath:path];
        returnString = NSLocalizedStringFromTableInBundle(key, @"RIStrings", bundle, key);
    }
    
    return returnString;
}

+ (NSString *)localizedErrorCode:(NSString *)errorCode;
{
    NSString *localizedErrorCode = nil;
    NSString *locale = [[NSUserDefaults standardUserDefaults] stringForKey:kLanguageCodeKey];
    NSDictionary *componentsFromLocale =  [NSLocale componentsFromLocaleIdentifier:locale];
    NSString *languageCode = [componentsFromLocale objectForKey:NSLocaleLanguageCode];
    
    if(NOTEMPTY(languageCode)) {
        NSString * path = [[NSBundle mainBundle] pathForResource:languageCode
                                                          ofType:@"lproj"];
        if(NOTEMPTY(path)) {
            NSBundle * bundle = [[NSBundle alloc] initWithPath:path];
            if(NOTEMPTY(bundle))
            {
                localizedErrorCode = NSLocalizedStringFromTableInBundle([errorCode lowercaseString], @"RIStrings", bundle, key);
            }
        }
    }
    return localizedErrorCode;
}

@end
