//
//  GDIArcLabel.h
//  GDIArcLabel
//
//  Created by Grant Davis on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GDIArcLabel : UILabel

@property (nonatomic) CGFloat radius;

- (NSMutableAttributedString *)attributedString;

+ (CGFloat)sizeInRadiansOfText:(NSString *)text font:(UIFont *)font radius:(CGFloat)radius;

@end
