//
//  Model.m
//  ZPUISearchController
//
//  Created by 赵鹏 on 2018/10/16.
//  Copyright © 2018 赵鹏. All rights reserved.
//

#import "Model.h"

@implementation Model

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.name = [dict objectForKey:@"name"];
        self.number = [dict objectForKey:@"number"];
    }
    
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end
