//
//  STLDuotoneConverter.h
//  Duotone
//
//  Created by Thodoris Tsiridis on 17/07/15.
//  Copyright © 2015 72lions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STLDuotoneConverter;
/**
 * Any class that wants to use the Duotone converter, needs to implement this delegate
 */
@protocol STLDuotoneConverterDelegate <NSObject>

/**
 * When the converter finishes the image convertion this delegate method is called
 *
 * @param duotonConverter The converter instance
 * @param image The converted image
 */
- (void)duotoneConverter:(STLDuotoneConverter *)duotoneConverter didFinishConvertingImage:(UIImage *)image;

/**
 * When the converter encouters an error with the image convertion this delegate method is called
 *
 * @param duotonConverter The converter instance
 */
- (void)duotoneConverterDidFailToConvertImage:(STLDuotoneConverter *)duotoneConverter;

@end

@interface STLDuotoneConverter : NSObject

/**
 * The delegate of the converter
 */
@property (nonatomic, weak) id<STLDuotoneConverterDelegate>delegate;

/**
 * Converts a UIImage to a duotone image by providing the colors for the hightlights / shadows and the contrast
 *
 * @param image The image that will be converted
 * @param highlightColor The color that will be used for the highlights
 * @param shadowColor The color that will be used for the shadows
 * @param contrast The contrast value. (0 - 1 with 0.5f meaning that there will be no contrast applied)
 */
- (void)convertImage:(UIImage *)image withHighlightColor:(UIColor *)highlightColor shadowColor:(UIColor *)shadowColor contrast:(CGFloat)contrast;

@end
