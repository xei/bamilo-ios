//
//  RIError.m
//  Comunication Project
//
//  Created by Pedro Lopes on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIError.h"
#import "RILocalizationWrapper.h"

@interface RIError ()

@property (strong, nonatomic) NSArray *errorCodes; //!< Array with error codes returned by the request
@property (strong, nonatomic) NSArray *errorMessagesArray; //!< Array filled with error messages, if the API field "validate" is an array
@property (strong, nonatomic) NSDictionary *errorMessagesDictionary; //!< Dictionary filled with error messages, if the API field "validate" is a dictionary

@end

@implementation RIError

+ (NSArray *) getErrorMessages:(NSDictionary *)errorJsonObject
{
    NSArray *errorMessages = nil;
    
    RIError *error = [RIError parseErrorMessages:errorJsonObject];
    if(NOTEMPTY(error.errorMessagesArray))
    {
        errorMessages = [error.errorMessagesArray copy];
    }
    else if(NOTEMPTY(error.errorCodes))
    {
        NSMutableArray *errorCodeStrings = [[NSMutableArray alloc] init];
        for(id errorCode in error.errorCodes)
        {
            if(VALID_NOTEMPTY(errorCode, NSString))
            {
                if(VALID_NOTEMPTY([RILocalizationWrapper localizedErrorCode:errorCode], NSString) || ([errorCode caseInsensitiveCompare:[RILocalizationWrapper localizedErrorCode:errorCode]] == NSOrderedSame))
                {
                    [errorCodeStrings addObject:[RILocalizationWrapper localizedErrorCode:errorCode]];
                }
            }
            else if(VALID_NOTEMPTY(errorCode, NSDictionary) && VALID_NOTEMPTY([errorCode objectForKey:@"message"], NSString))
            {
                NSString *errorMessage = [errorCode objectForKey:@"message"];
                if(VALID_NOTEMPTY([RILocalizationWrapper localizedErrorCode:errorMessage], NSString) || ([errorMessage caseInsensitiveCompare:[RILocalizationWrapper localizedErrorCode:errorMessage]] == NSOrderedSame))
                {
                    [errorCodeStrings addObject:errorMessage];
                }
            }
        }
        
        if(VALID_NOTEMPTY(errorCodeStrings, NSMutableArray))
        {
            errorMessages = [errorCodeStrings copy];
        }
    }
    
    return errorMessages;
}

+ (NSDictionary *) getErrorDictionary:(NSDictionary *)errorJsonObject
{
    NSDictionary *errorDictionary = nil;
    
    RIError *error = [RIError parseErrorMessages:errorJsonObject];
    if(NOTEMPTY(error.errorMessagesDictionary))
    {
        errorDictionary = [error.errorMessagesDictionary copy];
    }
    
    return  errorDictionary;
}

#pragma mark - private methods

/**
 * Method to parse error messages from the json object
 */
+ (RIError *)parseErrorMessages:(NSDictionary *)jsonObject
{
    RIError *error = [[RIError alloc] init];
    
    if(VALID_NOTEMPTY([jsonObject objectForKey:@"messages"], NSDictionary))
    {
        NSDictionary *messagesObject = [jsonObject objectForKey:@"messages"];
        if(VALID_NOTEMPTY([messagesObject objectForKey:@"error"], NSArray))
        {
            NSArray *errorCodesObject = [messagesObject objectForKey:@"error"];
            if(NOTEMPTY(errorCodesObject))
            {
                NSMutableArray *errorCodesArray = [[NSMutableArray alloc] init];
                for (NSString *errorCodeString in errorCodesObject)
                {
                    [errorCodesArray addObject:errorCodeString];
                }
                error.errorCodes = [errorCodesArray copy];
            }
        }
    
        if(NOT_NIL([messagesObject objectForKey:@"validate"]))
        {
            id errorMessagesObject = [messagesObject objectForKey:@"validate"];
            if (VALID_NOTEMPTY(errorMessagesObject, NSDictionary))
            {
                NSMutableDictionary *errorMessagesDictionary = [[NSMutableDictionary alloc] init];
                
                NSArray  *errorMessagesKeys = [errorMessagesObject allKeys];
                for(NSString *errorMessageKey in errorMessagesKeys) {
                    [errorMessagesDictionary setValue:[errorMessagesObject objectForKey:errorMessageKey] forKey:errorMessageKey];
                }
                error.errorMessagesDictionary = [errorMessagesDictionary copy];
            }
            else if (VALID_NOTEMPTY(errorMessagesObject, NSArray))
            {
                NSMutableArray *errorMessagesArray = [[NSMutableArray alloc] init];
                for (NSString *errorMessageString in errorMessagesObject) {
                    [errorMessagesArray addObject:errorMessageString];
                }
                error.errorMessagesArray = [errorMessagesArray copy];
            }
        }
        else if(VALID_NOTEMPTY([messagesObject objectForKey:@"error"], NSDictionary))
        {
            error.errorMessagesDictionary = [[messagesObject objectForKey:@"error"] copy];
        }
    }
    return error;
}

@end
