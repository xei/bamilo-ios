//
//  RIForm.m
//  Comunication Project
//
//  Created by Telmo Pinto on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIForm.h"
#import "RIField.h"

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
    //get form indexes
    
    return [RIFormIndex getFormIndexesWithWithSuccessBlock:^(id formIndexes) {
        
        for (RIFormIndex* formIndex in formIndexes) {
            
            if ([formIndex.uid isEqualToString:formIndexID]) {
                //found the index
                
                if (VALID_NOTEMPTY(formIndex.form, RIForm)) {
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
                                                                           
                                                                           if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                               
                                                                               RIForm* newForm = [RIForm parseForm:metadata];
                                                                               
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
            }
        }
    } andFailureBlock:failureBlock];
}

+ (void)requestFormForIndex:(RIFormIndex*)formIndex
               successBlock:(void (^)(id form))successBlock
               failureBlock:(void (^)(NSArray *errorMessage))failureBlock;
{

}

+ (RIForm *)parseForm:(NSDictionary *)formJSON;
{
    RIForm* newForm = (RIForm*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIForm class])];
    
    NSArray* data = [formJSON objectForKey:@"data"];
    
    if (VALID_NOTEMPTY(data, NSArray)) {
        
        NSDictionary* formDict = [data firstObject];
        
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
    }
    return newForm;
}

+ (void)saveForm:(RIForm *)form;
{
    for (RIField* field in form.fields) {
        [RIField saveField:field];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:form];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

@end
