//
//  RISuccess.m
//  Jumia
//
//  Created by Claudio Sobrinho on 26/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "RISuccess.h"

@interface RISuccess ()

@property (strong, nonatomic) NSArray *successCodes; //!< Array with success codes returned by the request
@property (strong, nonatomic) NSArray *successMessagesArray; //!< Array filled with success messages, if the API field "validate" is an array
@property (strong, nonatomic) NSDictionary *successMessagesDictionary; //!< Dictionary filled with success messages, if the API field "validate" is a dictionary

@end

@implementation RISuccess

+ (NSArray *)getSuccessMessages:(NSDictionary *)successJsonObject
{
    NSArray *successMessages = nil;
    
    RISuccess *success = [RISuccess parseSuccessMessages:successJsonObject];
    //CHECK: Shouldn't be needed
    if(NOTEMPTY(success.successMessagesArray))
    {
        successMessages = [success.successMessagesArray copy];
    }
    // -- 
    else if(NOTEMPTY(success.successCodes))
    {
        NSMutableArray *successCodeStrings = [[NSMutableArray alloc] init];
        for(id successCode in success.successCodes)
        {
            if(VALID_NOTEMPTY(successCode, NSString))
            {
                if(VALID_NOTEMPTY([RILocalizationWrapper localizedErrorCode:successCode], NSString) || ([successCode caseInsensitiveCompare:[RILocalizationWrapper localizedErrorCode:successCode]] == NSOrderedSame))
                {
                    [successCodeStrings addObject:[RILocalizationWrapper localizedErrorCode:successCode]];
                }
            }
            else if(VALID_NOTEMPTY(successCode, NSDictionary) && VALID_NOTEMPTY([successCode objectForKey:@"message"], NSString))
            {
                NSString *successMessage = [successCode objectForKey:@"message"];
                if(VALID_NOTEMPTY([RILocalizationWrapper localizedErrorCode:successMessage], NSString) || ([successMessage caseInsensitiveCompare:[RILocalizationWrapper localizedErrorCode:successMessage]] == NSOrderedSame))
                {
                    [successCodeStrings addObject:successMessage];
                }
            }
        }
        
        if(VALID_NOTEMPTY(successCodeStrings, NSMutableArray))
        {
            successMessages = [successCodeStrings copy];
        }
    }
    
    return successMessages;
}

+ (NSDictionary *) getSuccessDictionary:(NSDictionary *)successJsonObject
{
    NSDictionary *successDictionary = nil;
    
    RISuccess *success = [RISuccess parseSuccessMessages:successJsonObject];
    if(NOTEMPTY(success.successMessagesDictionary))
    {
        successDictionary = [success.successMessagesDictionary copy];
    }
    
    return  successDictionary;
}

/**
 * Method to parse success messages from the json object
 */
+ (RISuccess *)parseSuccessMessages:(NSDictionary *)jsonObject
{
    RISuccess *success = [[RISuccess alloc] init];
    
    if(VALID_NOTEMPTY([jsonObject objectForKey:@"messages"], NSDictionary))
    {
        NSDictionary *messagesObject = [jsonObject objectForKey:@"messages"];
        if(VALID_NOTEMPTY([messagesObject objectForKey:@"success"], NSArray))
        {
            NSArray *successCodesObject = [messagesObject objectForKey:@"success"];
            if(NOTEMPTY(successCodesObject))
            {
                NSMutableArray *successCodesArray = [[NSMutableArray alloc] init];
                for (NSString *successCodeString in successCodesObject)
                {
                    [successCodesArray addObject:successCodeString];
                }
                success.successCodes = [successCodesArray copy];
            }
        }else if(VALID_NOTEMPTY([messagesObject objectForKey:@"success"], NSDictionary))
            {
                NSDictionary *successCodesObject = [messagesObject objectForKey:@"success"];
                if (VALID_NOTEMPTY([successCodesObject objectForKey:@"message"], NSString)) {
                    success.successCodes = @[[successCodesObject objectForKey:@"message"]];
                }
            }
    }
    return success;
}


@end
