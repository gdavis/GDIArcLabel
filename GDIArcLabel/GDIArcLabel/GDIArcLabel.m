//
//  GDIArcLabel.m
//  GDIArcLabel
//
//  Created by Grant Davis on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GDIArcLabel.h"
#import "GDIMath.h"
#import <CoreText/CoreText.h>


@interface GDIArcLabel()
CTFontRef CTFontCreateFromUIFont(UIFont *font);
@end


@implementation GDIArcLabel
@synthesize radius = _radius;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _radius = 100.f;
    }
    return self;
}


CTFontRef CTFontCreateFromUIFont(UIFont *font)
{
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName,
                                            font.pointSize, 
                                            NULL);
    return ctFont;
}


- (NSMutableAttributedString *)attributedString
{
    assert(self.text != nil);
    assert(self.font != nil);
	
	// Create the attributed string
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    if (self.text != nil) {
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), (__bridge CFStringRef)self.text);
    }
    
    CFRange textRange = CFRangeMake(0, CFAttributedStringGetLength(attrString));
    
    // set the font
    CTFontRef ctFont = CTFontCreateFromUIFont(self.font);
    CFAttributedStringSetAttribute(attrString, textRange, kCTFontAttributeName, ctFont);
    CFRelease(ctFont);
    
    // set text color
    CFAttributedStringSetAttribute(attrString, textRange, kCTForegroundColorAttributeName, self.textColor.CGColor);
    
    NSMutableAttributedString *nsString = (__bridge NSMutableAttributedString *) attrString;
    return nsString;
}


- (void)drawTextInRect:(CGRect)rect
{
    if (self.text == nil || self.font == nil )
        return;
    
    // setup the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGContextScaleCTM(context, 1.f, -1.f);
    
    // DEBUG: reference point for origin
    CGContextAddEllipseInRect(context, CGRectMake(-5, -5, 10, 10));
    CGContextSetRGBFillColor(context, 1.f, 0.f, 1.f, 1.f);
    CGContextFillPath(context);
    
    // draw the arc for reference
    CGContextAddArc(context, 0, 0, _radius, 0, M_PI*2, 1);
    CGContextSetRGBStrokeColor(context, 1.f, 0.f, 1.f, 1.f);
    CGContextStrokePath(context);
    
    // get the attributed string for our current state
    NSMutableAttributedString *attrString = [self attributedString];
    
    // create a line for the text
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFMutableAttributedStringRef)attrString);
    assert(line != NULL);
    
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runArray);
    CFIndex runIndex = 0;
    
    // create fonts for the glyph and apply to the context
    CTFontRef ctFont = CTFontCreateFromUIFont(self.font);
    CGFontRef cgFont = CTFontCopyGraphicsFont(ctFont, NULL);
    CGContextSetFont(context, cgFont);
    CGContextSetFontSize(context, CTFontGetSize(ctFont));
    
    CGFloat currentRotation = M_PI;
    
    // go through the runs of the line and draw
    for (; runIndex < runCount; runIndex++) {
        
        // pull out the current run
        CTRunRef run = CFArrayGetValueAtIndex(runArray, runIndex);
        
        // count the glphs in the run
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        
        // now loop through all the glyphs and draw each
        CFIndex glyphIndex = 0;
        for (; glyphIndex < glyphCount; glyphIndex++) {

            // pull out the glyph
            CFRange glyphRange = CFRangeMake(glyphIndex, 1);    
            
            // get the glyph and its position
            CGGlyph glyph;
            CTRunGetGlyphs(run, glyphRange, &glyph);
            
            // get the glyph size
            CGFloat ascent, descent;
            CGSize glyphSize;
            CGFloat glyphWidth = CTRunGetTypographicBounds(run, glyphRange, &ascent, &descent, NULL);
            glyphSize.width = glyphWidth;
            glyphSize.height = ascent + descent;
                        
            CGFloat glyphSizeInRadians = glyphSize.width / _radius;
            CGPoint position = cartesianCoordinateFromPolar(_radius, currentRotation);

            CGContextSetFillColorWithColor(context, self.textColor.CGColor);
        
            CGAffineTransform textTransform = CGAffineTransformMakeRotation((currentRotation - M_PI) - M_PI * .5);
            CGContextSetTextMatrix(context, textTransform);
            CGContextShowGlyphsAtPoint(context, position.x, position.y, &glyph, 1);
            
            currentRotation += glyphSizeInRadians;
        }
    }
    
    CFRelease(ctFont);
    CFRelease(cgFont);    
}


- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
    [self setNeedsDisplay];
}


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
