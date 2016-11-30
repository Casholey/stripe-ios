//
//  STPFile.m
//  Stripe
//
//  Created by Charles Scalesse on 11/30/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPFile.h"
#import "NSDictionary+Stripe.h"

@interface STPFile ()

@property (nonatomic, readwrite) NSString *fileId;
@property (nonatomic, readwrite) NSDate *created;
@property (nonatomic, readwrite) STPFilePurpose purpose;
@property (nonatomic, readwrite) NSNumber *size;
@property (nonatomic, readwrite) NSURL *url;
@property (nonatomic, readwrite) NSString *mimeType;
@property (nonatomic, readwrite, copy) NSDictionary *allResponseFields;

- (BOOL)isEqualToFile:(STPFile *)file;

@end

@implementation STPFile

#pragma mark - Equality

- (BOOL)isEqual:(STPFile *)file {
    return [self isEqualToFile:file];
}

- (NSUInteger)hash {
    return [self.fileId hash];
}

- (BOOL)isEqualToFile:(STPFile *)file {
    if (self == file) {
        return YES;
    }
    
    if (!file || ![file isKindOfClass:self.class]) {
        return NO;
    }
    
    return [self.fileId isEqualToString:file.fileId];
}

#pragma mark  - STPAPIResponseDecodable

+ (NSArray *)requiredFields {
    return @[@"id", @"created", @"size", @"purpose", @"mimetype"];
}

+ (instancetype)decodedObjectFromAPIResponse:(NSDictionary *)response {
    NSDictionary *dict = [response stp_dictionaryByRemovingNullsValidatingRequiredFields:[self requiredFields]];
    if (!dict) {
        return nil;
    }
    
    STPFile *file = [[STPFile alloc] init];
    file.fileId = dict[@"id"];
    file.created = [[NSDate alloc] initWithTimeIntervalSince1970:[dict[@"created"] doubleValue]];
    file.size = dict[@"size"];
    file.url = [[NSURL alloc] initWithString:dict[@"url"]];
    file.mimeType = dict[@"mimetype"];
    
    NSString *purpose = dict[@"purpose"];
    if ([purpose isEqualToString:@"identity_document"]) {
        file.purpose = STPFilePurposeIdentityDocument;
    } else if ([purpose isEqualToString:@"dispute_evidence"]) {
        file.purpose = STPFilePurposeDisputeEvidence;
    }
    
    file.allResponseFields = dict;
    return file;
}

@end
