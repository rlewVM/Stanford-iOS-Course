//
//  Photo.h
//  TopPlaces
//
//  Created by Rachel Lew on 3/16/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique_id;
@property (nonatomic, retain) NSString * place_id;
@property (nonatomic, retain) Photographer *whoTook;

@end
