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
#import "RICustomer.h"
#import "RIFieldOption.h"
#import "RICart.h"
#import "RITarget.h"
#import "RISuccess.h"

@implementation RIForm

@dynamic type;
@dynamic method;
@dynamic action;
@dynamic fields;
@dynamic formIndex;

+ (NSString *)getForm:(NSString *)formIndexType successBlock:(void (^)(RIForm *))successBlock failureBlock:(void (^)(RIApiResponse, NSArray *))failureBlock {
    return [self getForm:formIndexType forceRequest:NO successBlock:successBlock failureBlock:failureBlock];
}

+ (NSString*)getForm:(NSString*)formIndexType forceRequest:(BOOL)forceRequest successBlock:(void (^)(RIForm *))successBlock failureBlock:(void (^)(RIApiResponse, NSArray *))failureBlock {
    //get form for index
    
    return [RIFormIndex getFormWithType:formIndexType successBlock:^(RIFormIndex* formIndex) {
        
        if (VALID_NOTEMPTY(formIndex, RIFormIndex) && VALID_NOTEMPTY(formIndex.form, RIForm)) {
            //index has form
            
            if (!forceRequest) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(formIndex.form);
                });
                return;
            }
        }
        
        if (VALID_NOTEMPTY(formIndex.targetString, NSString))
        {
            NSString* urlString = [RITarget getURLStringforTargetString:formIndex.targetString];

            NSURL *url = [NSURL URLWithString:urlString];
            
            [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                             parameters:nil
                                                             httpMethod:HttpVerbPOST
                                                              cacheType:RIURLCacheNoCache
                                                              cacheTime:RIURLCacheDefaultTime
                                                     userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                           successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                               
                                                               NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                               
                                                               if (VALID_NOTEMPTY(metadata, NSDictionary) && VALID_NOTEMPTY([metadata objectForKey:@"form_entity"], NSDictionary)) {
                                                                   NSDictionary* formEntity = [metadata objectForKey:@"form_entity"];
                                                                   
                                                                   RIForm* newForm = [RIForm parseFormEntity:formEntity formIndex:formIndex formIndexType:formIndexType];

                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       successBlock(newForm);
                                                                   });
                                                               } else {
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       failureBlock(apiResponse, nil);
                                                                   });
                                                               }
                                                               
                                                           } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
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
        
        
        return;
        
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
        [RIForm getFormWithUrl:formIndexType successBlock:successBlock failureBlock:failureBlock];
    }];
}

+ (NSString *)getFormWithUrl:(NSString *)urlString successBlock:(void (^)(RIForm *))successBlock failureBlock:(void (^)(RIApiResponse, NSArray *))failureBlock {
    urlString = [NSString stringWithFormat:@"%@%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_FORMS_GET, urlString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:nil
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary) && VALID_NOTEMPTY([metadata objectForKey:@"form_entity"], NSDictionary)) {
                                                                  NSDictionary* formEntity = [metadata objectForKey:@"form_entity"];
                                                                  
                                                                  // Update user newsletter preferences
                                                                  RIForm* newForm = [RIForm parseFormEntity:formEntity formIndex:nil formIndexType:nil];
//                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      successBlock(newForm);
//                                                                  });
                                                              } else {
//                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      failureBlock(apiResponse, nil);
//                                                                  });
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
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


+ (RIForm*)parseFormEntity:(NSDictionary*)formEntityJSON formIndex:(RIFormIndex*)formIndex formIndexType:(NSString*)formIndexType {
    RIForm* newForm = [RIForm parseForm:formEntityJSON];
    
    if (VALID_NOTEMPTY(formIndex, RIFormIndex)) {
        [RIForm saveForm:newForm andContext:NO];
        newForm.formIndex = formIndex;
        formIndex.form = newForm;
        //form index was already on database, it just lacked the form variable. let's save the context without adding any other NSManagedObject
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }

    return newForm;
}

+ (NSString*)sendForm:(RIForm*)form successBlock:(void (^)(id object, NSArray* successMessages))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, id errorObject))failureBlock {
    return [RIForm sendForm:form
             extraArguments:nil
                 parameters:[RIForm getParametersForForm:form]
               successBlock:successBlock
            andFailureBlock:failureBlock];
}

+ (NSString*)sendForm:(RIForm*)form parameters:(NSDictionary *)parameters successBlock:(void (^)(id object, NSArray* successMessages))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, id errorObject))failureBlock {
    return [RIForm sendForm:form
             extraArguments:nil
                 parameters:parameters
               successBlock:successBlock
            andFailureBlock:failureBlock];
}

+ (NSString*)sendForm:(RIForm*)form extraArguments:(NSDictionary *)extraArguments parameters:(NSDictionary*)parameters successBlock:(void (^)(id object, NSArray* successMessages))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, id errorObject))failureBlock {
    //BOOL isPostRequest = [@"post" isEqualToString:[form.method lowercaseString]];
    //TODO: DELELE
    
    HttpVerb response = [self getHttpResponseMethodFromForm:form];
    
    NSMutableDictionary *allParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    for(RIField *formField in form.fields)
    {
        if([@"hidden" isEqualToString:formField.type] && ![parameters objectForKey:formField.name])
        {
            [allParameters setValue:formField.value forKey:formField.name];
        }
    }
    
    NSString* urlString = [RITarget getURLStringforTargetString:form.action];
    
    NSURL *url = [NSURL URLWithString:urlString];
    if(VALID_NOTEMPTY(extraArguments, NSDictionary)) {
        NSArray *keys = [extraArguments allKeys];
        NSMutableArray *extraArgumentsArray = [[NSMutableArray alloc] init];
        for(NSString *key in keys) {
            [extraArgumentsArray addObject:[NSString stringWithFormat:@"%@=%@", key, [extraArguments objectForKey:key]]];
        }

        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", form.action, [extraArgumentsArray componentsJoinedByString:@"&"]]];
    }
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:allParameters
                                                            httpMethod:response
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSMutableArray* messagesArray = [NSMutableArray new];
                                                              NSDictionary* messages = [jsonObject objectForKey:@"messages"];
                                                              if (messages && messages.count) {
                                                                  NSArray* successMessages = [messages objectForKey:@"success"];
                                                                  if (successMessages.count) {
                                                                      NSDictionary* messageDictionary = [successMessages firstObject];
                                                                      if (messageDictionary && messageDictionary.count) {
                                                                          NSString* message = [messageDictionary objectForKey:@"message"];
                                                                          if (message.length) {
                                                                              [messagesArray addObject:message];
                                                                          }
                                                                      }
                                                                  }
                                                              }
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              
                                                              NSString *password = nil;
                                                              NSArray *parameterKeys = [parameters allKeys];
                                                              for(NSString *key in parameterKeys)
                                                              {
                                                                  if(NSNotFound != [[key lowercaseString] rangeOfString:@"password"].location)
                                                                  {
                                                                      password = [parameters objectForKey:key];
                                                                      break;
                                                                  }
                                                              }
                                                              
                                                              BOOL responseProcessed = NO;
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  NSDictionary* entities = [RIForm parseEntities:metadata plainPassword:password loginMethod:@"normal"];
                                                                  
                                                                  successBlock(entities, [messagesArray copy]);
                                                                  responseProcessed = YES;
                                                              }
                                                              else
                                                              {
                                                                  responseProcessed = YES;
                                                                  successBlock([RISuccess getSuccessMessages:jsonObject], [messagesArray copy]);
                                                              }
                                                              
                                                              if(!responseProcessed)
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject)) {
                                                                  NSDictionary *errorDictionary = [RIError getErrorDictionary:errorJsonObject];
                                                                  NSArray *errorArray = [RIError getErrorMessages:errorJsonObject];
                                                                  if(errorDictionary && errorDictionary.count) {
                                                                      failureBlock(apiResponse, errorDictionary);
                                                                  } else if(errorArray.count) {
                                                                      failureBlock(apiResponse, errorArray);
                                                                  } else {
                                                                      failureBlock(apiResponse, nil);
                                                                  }
                                                              } else if(NOTEMPTY(errorObject)) {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

+ (NSDictionary*)parseEntities:(NSDictionary*)entitiesJSON plainPassword:(NSString*)plainPassword loginMethod:(NSString*)loginMethod {
    NSMutableDictionary* newEntities = [NSMutableDictionary new];
    
    if ([entitiesJSON objectForKey:@"customer_entity"]) {
        RICustomer *newCustomer = [RICustomer parseCustomerWithJson:[entitiesJSON objectForKey:@"customer_entity"]
                                                      plainPassword:plainPassword
                                                        loginMethod:loginMethod];
        [newEntities setObject:newCustomer forKey:@"customer"];
    }
    
    if ([entitiesJSON objectForKey:@"cart_entity"]) {
        RICart *newCart = [RICart parseCart:entitiesJSON country:nil];
        [newEntities setObject:newCart forKey:@"cart"];
    }
    
    if ([entitiesJSON objectForKey:@"multistep_entity"]) {
        NSDictionary* nextStep = [entitiesJSON objectForKey:@"multistep_entity"];
        if (VALID_NOTEMPTY(nextStep, NSDictionary)) {
            [newEntities addEntriesFromDictionary:nextStep];
        }
    }
    
    return [newEntities copy];
}

+ (void)saveForm:(RIForm *)form andContext:(BOOL)save {
    for (RIField* field in form.fields) {
        for (RIFieldDataSetComponent *component in field.dataSet) {
            [RIFieldDataSetComponent saveFieldDataSetComponent:component andContext:NO];
        }
        
        for(RIFieldOption *option in field.options)
        {
            [RIFieldOption saveFieldOption:option andContext:NO];
        }
        
        [RIField saveField:field andContext:NO];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:form];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
}

+ (void)removeForm:(RIForm *)form {
    [[RIDataBaseWrapper sharedInstance] deleteObject:form];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (NSDictionary *) getParametersForForm:(RIForm *)form {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for(RIField *field in form.fields)
    {
        if(VALID_NOTEMPTY(field.value, NSString) && VALID_NOTEMPTY(field.name, NSString))
        {
            [parameters setValue:field.value forKey:field.name];
        }
    }
    return [parameters copy];
}

#pragma mark - Cancel requests
+ (void)cancelRequest:(NSString *)operationID {
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Auxiliar functions
+ (HttpVerb)getHttpResponseMethodFromForm:(RIForm *) form {
    NSString* formMethod = [form.method lowercaseString];
    if([@"post" isEqualToString:formMethod]){
        return HttpVerbPOST;
    }
    if([@"get" isEqualToString:formMethod]){
        return HttpVerbGET;
    }
    if([@"put" isEqualToString:formMethod]){
        return HttpVerbPUT;
    }
    else{
        return HttpVerbDELETE;
    }
}

+ (RIForm *)parseForm:(NSDictionary *)formDict {
    return [self parseToDataModelWithObjects:@[ formDict ]];
}

#pragma mark - JSONVerboseModel
+(instancetype)parseToDataModelWithObjects:(NSArray *)objects {
    NSDictionary *dict = objects[0];
    
    RIForm *form = (RIForm*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIForm class])];
    
    if (VALID_NOTEMPTY(dict, NSDictionary)) {
        
        if ([dict objectForKey:@"type"]) {
            form.type = [dict objectForKey:@"type"];
        }
        if ([dict objectForKey:@"action"]) {
            form.action = [dict objectForKey:@"action"];
        }
        if ([dict objectForKey:@"method"]) {
            form.method = [dict objectForKey:@"method"];
        }
        
        NSArray* fields = [dict objectForKey:@"fields"];
        
        if (VALID_NOTEMPTY(fields, NSArray)) {
            
            for (NSDictionary* fieldJSON in fields) {
                RIField* newField = [RIField parseField:fieldJSON];
                newField.form = form;
                [form addFieldsObject:newField];
            }
        }
    }
    
    return form;
}

@end
