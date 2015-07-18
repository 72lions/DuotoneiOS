# Duotone effect in iOS

Spotify's new brand identity is full of bright colours. Here is the same effect in iOS

## Usage

```objc
/**
 * Converts a UIImage to a duotone image by providing the colors for the hightlights / shadows and the contrast
 *
 * @param image The image that will be converted
 * @param highlightColor The color that will be used for the highlights
 * @param shadowColor The color that will be used for the shadows
 * @param contrast The contrast value. (0 - 1 with 0.5f meaning that there will be no contrast applied)
 */
- (void)convertImage:(UIImage *)image withHighlightColor:(UIColor *)highlightColor shadowColor:(UIColor *)shadowColor contrast:(CGFloat)contrast;
```

When the work is done this delegate method will be called:

```objc
/**
 * When the converter finishes the image convertion this delegate method is called
 *
 * @param duotonConverter The converter instance
 * @param image The converted image
 */
- (void)duotoneConverter:(STLDuotoneConverter *)duotoneConverter didFinishConvertingImage:(UIImage *)image;
```

and if the work is not successful the following delegate method will be called:

```objc
/**
 * When the converter encouters an error with the image convertion this delegate method is called
 *
 * @param duotonConverter The converter instance
 */
- (void)duotoneConverterDidFailToConvertImage:(STLDuotoneConverter *)duotoneConverter;
```
