//
//  Model.h
//  ZPUISearchController
//
//  Created by 赵鹏 on 2018/10/16.
//  Copyright © 2018 赵鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Model : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSNumber *number;

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
