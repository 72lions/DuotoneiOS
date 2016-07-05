//
//  STLDuotoneConverter.m
//  Duotone
//
//  Created by Thodoris Tsiridis on 17/07/15.
//  Copyright © 2015 72lions. All rights reserved.
//

#import "STLDuotoneConverter.h"

// Makes sure that a color value doesn't drop below 0 or doesn't go over 255
#define SAFECOLOR(color) MIN(255,MAX(0,color))

@implementation STLDuotoneConverter

- (void)convertImage:(UIImage *)image withHighlightColor:(UIColor *)highlightColor shadowColor:(UIColor *)shadowColor contrast:(CGFloat)contrast
{

    __weak STLDuotoneConverter *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        STLDuotoneConverter *strongSelf = weakSelf;

        CGFloat highlightsColorRed = 0.0, highlightsColorGreen = 0.0, highlightsColorBlue = 0.0, highlightsColorAlpha = 0.0;
        [highlightColor getRed:&highlightsColorRed green:&highlightsColorGreen blue:&highlightsColorBlue alpha:&highlightsColorAlpha];

        CGFloat shadowsColorRed = 0.0, shadowsColorGreen = 0.0, shadowsColorBlue = 0.0, shadowsColorAlpha = 0.0;
        [shadowColor getRed:&shadowsColorRed green:&shadowsColorGreen blue:&shadowsColorBlue alpha:&shadowsColorAlpha];

        BOOL shouldCalculateContrast = contrast != 0.5f;
        CGFloat contrastNorm = (1.f + contrast - 0.5f);

        CGImageRef imageRef = [image CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSUInteger numberOfPixels = width * height;

        unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        unsigned char *convertedRawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        NSUInteger bytesPerPixel = 4;

        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                     bitsPerComponent, bytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);

        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);

        for (int i = 0; i < numberOfPixels; i++) {

            NSUInteger offset = i * bytesPerPixel;

            NSUInteger red = rawData[offset];
            NSUInteger green = (rawData[offset + 1]);
            NSUInteger blue  = (rawData[offset + 2]);
            NSUInteger alpha = (rawData[offset + 3]);

            // Contrast
            if (shouldCalculateContrast) {
                // Contrast: (f - 0.5) * c + 0.5;
                red = SAFECOLOR(255 * (((red / 255.f) - 0.5f) * contrastNorm + 0.5f));
                green = SAFECOLOR(255 * (((green / 255.f) - 0.5f) * contrastNorm + 0.5f));
                blue = SAFECOLOR(255 * (((blue / 255.f) - 0.5f) * contrastNorm + 0.5f));
            }
            // End of Contrast

            // Convert to grayscale
            NSUInteger average = floor(0.299f * red + 0.587f * green + 0.114f * blue);
            // End of Convert to grayscale

            // Apply duotone
            NSArray *hsl = [strongSelf rgbToHslWithRed:average green:average blue:average];
            NSNumber *luminosityNorm = hsl[2];
            // The luminosity from 0 to 255
            NSUInteger luminosity = MAX(0, MIN(254, floor([luminosityNorm floatValue] * 254)));

            CGFloat ratio = luminosity / 255.f;
            NSUInteger newRed = floor((highlightsColorRed * 255) * ratio + (shadowsColorRed * 255) * (1 - ratio));
            NSUInteger newGreen = floor((highlightsColorGreen * 255) * ratio + (shadowsColorGreen * 255) * (1 - ratio));
            NSUInteger newBlue = floor((highlightsColorBlue * 255) * ratio + (shadowsColorBlue * 255) * (1 - ratio));
            // End of Apply duotone

            convertedRawData[offset] = newRed;
            convertedRawData[offset + 1] = newGreen;
            convertedRawData[offset + 2] = newBlue;
            convertedRawData[offset + 3] = alpha;

        }


        // Creates an image based on the new raw data
        UIImage *image = [strongSelf convertBitmapRGBA8ToUIImage:convertedRawData withWidth:width withHeight:height];

        free(rawData);
        free(convertedRawData);

        // Dispatch the delegate back on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.delegate duotoneConverter:strongSelf didFinishConvertingImage:image];
        });
    });
}

/**
 * Creates a UIImage based on an rgb array
 *
 * @param buffer The pixel data which length should be width * height * 4
 * @param width The image width
 * @param height The image height
 */
- (UIImage *)convertBitmapRGBA8ToUIImage:(unsigned char *)buffer withWidth:(NSUInteger)width withHeight:(NSUInteger)height
{

    size_t bufferLength = width * height * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if(colorSpaceRef == NULL) {
        NSLog(@"Error allocating color space");
        CGDataProviderRelease(provider);
        return nil;
    }

    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    CGImageRef iref = CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerPixel,
                                    bytesPerRow,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,
                                    NULL,
                                    YES,
                                    renderingIntent);

    uint32_t* pixels = (uint32_t*)malloc(bufferLength);

    if(pixels == NULL) {
        NSLog(@"Error: Memory not allocated for bitmap");
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(iref);

        __weak STLDuotoneConverter *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            STLDuotoneConverter *strongSelf = weakSelf;
            [strongSelf.delegate duotoneConverterDidFailToConvertImage:strongSelf];
        });

        return nil;
    }

    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpaceRef,
                                                 bitmapInfo);

    if(context == NULL) {
        NSLog(@"Error context not created");
        free(pixels);
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(iref);

        __weak STLDuotoneConverter *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            STLDuotoneConverter *strongSelf = weakSelf;
            [strongSelf.delegate duotoneConverterDidFailToConvertImage:strongSelf];
        });
        return nil;
    }

    UIImage *image = nil;
    if(context) {

        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        // Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
        if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
            float scale = [[UIScreen mainScreen] scale];
            image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        } else {
            image = [UIImage imageWithCGImage:imageRef];
        }
        
        CGImageRelease(imageRef);	
        CGContextRelease(context);	
    }
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);
    
    if(pixels) {
        free(pixels);
    }

    return image;
}

/**
 * Converts RGB to HSL
 * 
 * @param red The red color value (0 - 255)
 * @param green The green color value (0 - 255)
 * @param blue The blue color value (0 - 255)
 */
- (NSArray *)rgbToHslWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue
{
    CGFloat redNorm = red / 255.f;
    CGFloat greenNorm = green / 255.f;
    CGFloat blueNorm = blue / 255.f;

    CGFloat max = MAX(blueNorm, MAX(redNorm, greenNorm));
    CGFloat min = MIN(blueNorm, MIN(redNorm, greenNorm));
    CGFloat h = 0;
    CGFloat s = 0;
    CGFloat l = (max + min) / 2;

    if (max != min) {

        CGFloat delta = max - min;
        s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);

        if (max == redNorm) {
            h = (greenNorm - blueNorm) / delta + (greenNorm < blueNorm ? 6 : 0);
        }

        if (max == greenNorm) {
            h = (blueNorm - redNorm) / delta + 2;
        }

        if (max == blueNorm) {
            h = (redNorm - greenNorm) / delta + 4;
        }

        h /= 6;
    }

    return @[@(h), @(s), @(l)];

}

- (void)dealloc
{
    self.delegate = nil;
}

@end
