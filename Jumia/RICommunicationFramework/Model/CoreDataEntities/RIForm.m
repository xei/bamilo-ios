//
//  RIForm.m
//  Comunication Project
//
//  Created by Telmo Pinto on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIForm.h"
#import "RIField.h"
#import "RIFieldDataSetComponent.h"

@implementation RIForm

@dynamic uid;
@dynamic method;
@dynamic action;
@dynamic fields;
@dynamic formIndex;

+ (NSString*)getForm:(NSString*)formIndexID
        successBlock:(void (^)(id form))successBlock
        failureBlock:(void (^)(NSArray *errorMessage))failureBlock;
{
    //get form for index
    return [RIFormIndex getFormWithIndexId:formIndexID successBlock:^(RIFormIndex* formIndex) {
        
        if (VALID_NOTEMPTY(formIndex, RIFormIndex) && VALID_NOTEMPTY(formIndex.form, RIForm)) {
            //index has form
            successBlock(formIndex.form);
        } else {
            
            if (VALID_NOTEMPTY(formIndex.url, NSString)) {
                
                [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:formIndex.url]
                                                                 parameters:nil httpMethodPost:YES
                                                                  cacheType:RIURLCacheNoCache
                                                                  cacheTime:RIURLCacheDefaultTime
                                                               successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                                   
                                                                   NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                   
                                                                   if (VALID_NOTEMPTY(metadata, NSDictionary) && VALID_NOTEMPTY([metadata objectForKey:@"data"], NSArray)) {
                                                                       NSArray* data = [metadata objectForKey:@"data"];
                                                                       RIForm* newForm = [RIForm parseForm:[data firstObject]];
                                                                       
                                                                       [RIForm saveForm:newForm];
                                                                       newForm.formIndex = formIndex;
                                                                       formIndex.form = newForm;
                                                                       //form index was already on database, it just lacked the form variable. let's save the context without adding any other NSManagedObject
                                                                       [[RIDataBaseWrapper sharedInstance] saveContext];
                                                                       
                                                                       successBlock(newForm);
                                                                   } else {
                                                                       failureBlock(nil);
                                                                   }
                                                                   
                                                               } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                                   if(NOTEMPTY(errorJsonObject))
                                                                   {
                                                                       failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                                   } else if(NOTEMPTY(errorObject))
                                                                   {
                                                                       NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                       failureBlock(errorArray);
                                                                   } else
                                                                   {
                                                                       failureBlock(nil);
                                                                   }
                                                               }];
            }
        }
        
        return;
        
        
    } andFailureBlock:failureBlock];
}

#pragma mark - Facebook Login
+ (NSString*)sendForm:(RIForm*)form
         successBlock:(void (^)(NSDictionary *jsonObject))successBlock
      andFailureBlock:(void (^)(NSArray *errorObject))failureBlock
{
    BOOL isPostRequest = [@"post" isEqualToString:[form.method lowercaseString]];
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:form.action]
                                                            parameters:[RIForm getParametersForForm:form]
                                                        httpMethodPost:isPostRequest
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  successBlock(metadata);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

+ (RIForm *)parseForm:(NSDictionary *)formDict;
{
    RIForm* newForm = (RIForm*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIForm class])];
    
    if (VALID_NOTEMPTY(formDict, NSDictionary)) {
        
        if ([formDict objectForKey:@"id"]) {
            newForm.uid = [formDict objectForKey:@"id"];
        }
        if ([formDict objectForKey:@"action"]) {
            newForm.action = [formDict objectForKey:@"action"];
        }
        if ([formDict objectForKey:@"method"]) {
            newForm.method = [formDict objectForKey:@"method"];
        }
        
        NSArray* fields = [formDict objectForKey:@"fields"];
        
        if (VALID_NOTEMPTY(fields, NSArray)) {
            for (NSDictionary* fieldJSON in fields) {
                RIField* newField = [RIField parseField:fieldJSON];
                newField.form = newForm;
                [newForm addFieldsObject:newField];
            }
        }
    }
    
    return newForm;
}

+ (void)saveForm:(RIForm *)form;
{
    for (RIField* field in form.fields) {
        
        for (RIFieldDataSetComponent *component in field.dataSet) {
            [RIFieldDataSetComponent saveFieldDataSetComponent:component];
        }
        
        [RIField saveField:field];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:form];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (NSDictionary *) getParametersForForm:(RIForm *)form
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for(RIField *field in form.fields)
    {
        [parameters setValue:field.value forKey:field.name];
    }
    return [parameters copy];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

@end
