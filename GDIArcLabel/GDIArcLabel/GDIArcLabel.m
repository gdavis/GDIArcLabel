//
//  GDIArcLabel.m
//  GDIArcLabel
//
//  Created by Grant Davis on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GDIArcLabel.h"

@implementation GDIArcLabel

+ (CGFloat)sizeInRadiansOfText:(NSString *)text font:(UIFont *)font radius:(CGFloat)radius
{
    // break the characters into an array so we can draw each character
    NSMutableArray *textCharacters = [NSMutableArray arrayWithCapacity:[text length]];
    for (int i=0; i<[text length]; i++) {
        [textCharacters addObject: [text substringWithRange:NSMakeRange(i, 1)]];
    }
    
    CGFloat dr = 0.f;
    
    for (int i=0; i<[textCharacters count]; i++) {
        
        NSString *string = [textCharacters objectAtIndex:i];
        CGSize characterSize = [string sizeWithFont:font];
        CGFloat rotation = ( characterSize.width + font.pointSize * .05) / (radius + font.descender);
        
        dr += rotation;
    }
    
    return dr;
}


@end
