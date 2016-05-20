//
//  RIFieldOption.m
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIFieldOption.h"
#import "RIField.h"
#import "RIForm.h"

@implementation RIFieldOption

@dynamic isDefault;
@dynamic label;
@dynamic value;
@dynamic isUserSubscribed;
@dynamic field;
@dynamic text;
@dynamic subtext;
@dynamic linkHTML;
@dynamic linkLabel;
@dynamic subForm;

+ (NSString*)getFieldOptionsForApiCall:(NSString*)apiCall
                          successBlock:(void (^)(NSArray *))successBlock
                          failureBlock:(void (^)(RIApiResponse, NSArray *))failureBlock;
{

    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:apiCall]
                                                            parameters:nil
                                                            httpMethod:HttpResponsePost
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject){
                                                              
                                                              if (VALID_NOTEMPTY(jsonObject, NSDictionary)) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      
                                                                      NSArray* data = [metadata objectForKey:@"data"];
                                                                      if (VALID_NOTEMPTY(data, NSArray)) {
                                                                          
                                                                          NSArray* fieldOptionsArray = [RIFieldOption parseFieldOptions:data];
                                                                          successBlock(fieldOptionsArray);
                                                                      }
                                                                  }
                                                              }
                                                              
                                                          }failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                              
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                                  });
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                      failureBlock(apiResponse, errorArray);
                                                                  });
                                                              } else
                                                              {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      failureBlock(apiResponse, nil);
                                                                  });
                                                              }
                                                          }];
}

+ (NSArray *)parseFieldOptions:(NSArray*)fieldOptionJSONArray
{
    NSMutableArray* newFieldOptionsMutableArray = [NSMutableArray new];
    
    for (NSDictionary* json in fieldOptionJSONArray) {
        if (VALID_NOTEMPTY(json, NSDictionary)) {
            
            RIFieldOption* newFieldOption = [RIFieldOption parseFieldOption:json];
            [newFieldOptionsMutableArray addObject:newFieldOption];
        }
    }
    
    return [newFieldOptionsMutableArray copy];
}

+ (RIFieldOption *)parseFieldOption:(NSDictionary *)fieldOptionObject
{
    RIFieldOption *fieldOption = (RIFieldOption *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIFieldOption class])];

    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"is_default"], NSString))
    {
        fieldOption.isDefault = [NSNumber numberWithBool:[[fieldOptionObject objectForKey:@"is_default"] boolValue]];
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"label"], NSString))
    {
        fieldOption.label = [fieldOptionObject objectForKey:@"label"];
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"value"], NSString))
    {
        fieldOption.value = [fieldOptionObject objectForKey:@"value"];
    } else if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"value"], NSNumber))
    {
        NSNumber* valueNumber = [fieldOptionObject objectForKey:@"value"];
        fieldOption.value = [valueNumber stringValue];
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"text"], NSString))
    {
        fieldOption.text = [fieldOptionObject objectForKey:@"text"];
        //hammer this shit here because the api can't take care of it's own data integrity
        fieldOption.text = [fieldOption.text stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"subtext"], NSString))
    {
        fieldOption.subtext = [fieldOptionObject objectForKey:@"subtext"];
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"link"], NSDictionary)) {
        
        NSDictionary* linkDictionary = [fieldOptionObject objectForKey:@"link"];
        
        if (VALID_NOTEMPTY([linkDictionary objectForKey:@"label"], NSString))
        {
            fieldOption.linkLabel = [linkDictionary objectForKey:@"label"];
        }
        
        if (VALID_NOTEMPTY([linkDictionary objectForKey:@"html"], NSString))
        {
            fieldOption.linkHTML = [linkDictionary objectForKey:@"html"];
        }
        
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"user_subscribed"], NSNumber))
    {
        fieldOption.isUserSubscribed = [fieldOptionObject objectForKey:@"user_subscribed"];
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"form_entity"], NSDictionary)) {
        
        NSDictionary* formJSON = [fieldOptionObject objectForKey:@"form_entity"];
        RIForm* newForm = [RIForm parseForm:formJSON];
        
        fieldOption.subForm = newForm;
    }
    
    return fieldOption;
}

+ (void)saveFieldOption:(RIFieldOption *)option andContext:(BOOL)save
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:option];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

@end
