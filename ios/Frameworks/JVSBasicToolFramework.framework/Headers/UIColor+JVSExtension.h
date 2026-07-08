//
//  UIColor+JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/12.
//

#import <UIKit/UIKit.h>


#define UIColorFromHex(_hex_)   [UIColor jvs_colorWithHexString:(_hex_)]


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void JVS_RGB2HSL(CGFloat r, CGFloat g, CGFloat b,
                        CGFloat *h, CGFloat *s, CGFloat *l);

FOUNDATION_EXPORT void JVS_HSL2RGB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *r, CGFloat *g, CGFloat *b);

FOUNDATION_EXPORT void JVS_RGB2HSB(CGFloat r, CGFloat g, CGFloat b,
                       CGFloat *h, CGFloat *s, CGFloat *v);

FOUNDATION_EXPORT void JVS_HSB2RGB(CGFloat h, CGFloat s, CGFloat v,
                       CGFloat *r, CGFloat *g, CGFloat *b);

FOUNDATION_EXPORT void JVS_RGB2CMYK(CGFloat r, CGFloat g, CGFloat b,
                        CGFloat *c, CGFloat *m, CGFloat *y, CGFloat *k);

FOUNDATION_EXPORT void JVS_CMYK2RGB(CGFloat c, CGFloat m, CGFloat y, CGFloat k,
                        CGFloat *r, CGFloat *g, CGFloat *b);

FOUNDATION_EXPORT void JVS_HSB2HSL(CGFloat h, CGFloat s, CGFloat b,
                       CGFloat *hh, CGFloat *ss, CGFloat *ll);

FOUNDATION_EXPORT void JVS_HSL2HSB(CGFloat h, CGFloat s, CGFloat l,
                       CGFloat *hh, CGFloat *ss, CGFloat *bb);

@interface UIColor (JVSExtension)

+ (UIColor *)jvs_colorWithHue:(CGFloat)hue
                  saturation:(CGFloat)saturation
                   lightness:(CGFloat)lightness
                       alpha:(CGFloat)alpha;

/**
 Creates and returns a color object using the specified opacity
 and CMYK color space component values.
 
 @param cyan    The cyan component of the color object in the CMYK color space,
 specified as a value from 0.0 to 1.0.
 
 @param magenta The magenta component of the color object in the CMYK color space,
 specified as a value from 0.0 to 1.0.
 
 @param yellow  The yellow component of the color object in the CMYK color space,
 specified as a value from 0.0 to 1.0.
 
 @param black   The black component of the color object in the CMYK color space,
 specified as a value from 0.0 to 1.0.
 
 @param alpha   The opacity value of the color object,
 specified as a value from 0.0 to 1.0.
 
 @return        The color object. The color information represented by this
 object is in the device RGB colorspace.
 */
+ (UIColor *)jvs_colorWithCyan:(CGFloat)cyan
                      magenta:(CGFloat)magenta
                       yellow:(CGFloat)yellow
                        black:(CGFloat)black
                        alpha:(CGFloat)alpha;

/**
 Creates and returns a color object using the hex RGB color values.
 
 @param rgbValue  The rgb value such as 0x66ccff.
 
 @return          The color object. The color information represented by this
 object is in the device RGB colorspace.
 */
+ (UIColor *)jvs_colorWithRGB:(uint32_t)rgbValue;

/**
 Creates and returns a color object using the hex RGBA color values.
 
 @param rgbaValue  The rgb value such as 0x66ccffff.
 
 @return           The color object. The color information represented by this
 object is in the device RGB colorspace.
 */
+ (UIColor *)jvs_colorWithRGBA:(uint32_t)rgbaValue;

/**
 Creates and returns a color object using the specified opacity and RGB hex value.
 
 @param rgbValue  The rgb value such as 0x66CCFF.
 
 @param alpha     The opacity value of the color object,
 specified as a value from 0.0 to 1.0.
 
 @return          The color object. The color information represented by this
 object is in the device RGB colorspace.
 */
+ (UIColor *)jvs_colorWithRGB:(uint32_t)rgbValue alpha:(CGFloat)alpha;

+ (UIColor *)jvs_colorWithHex:(UInt32)hex;

+ (UIColor *)jvs_colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;

/**
 Creates and returns a color object from hex string.
 
 @discussion:
 Valid format: #RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...
 The `#` or "0x" sign is not required.
 The alpha will be set to 1.0 if there is no alpha component.
 It will return nil when an error occurs in parsing.
 
 Example: @"0xF0F", @"66ccff", @"#66CCFF88"
 
 @param hexStr  The hex string value for the new color.
 
 @return        An UIColor object from string, or nil if an error occurs.
 */
+ (nullable UIColor *)jvs_colorWithHexString:(NSString *)hexStr;

/**
 Creates and returns a color object by add new color.
 
 @param add        the color added
 
 @param blendMode  add color blend mode
 */
- (UIColor *)jvs_colorByAddColor:(UIColor *)add blendMode:(CGBlendMode)blendMode;

/**
 Creates and returns a color object by change components.
 
 @param hueDelta         the hue change delta specified as a value
 from -1.0 to 1.0. 0 means no change.
 
 @param saturationDelta  the saturation change delta specified as a value
 from -1.0 to 1.0. 0 means no change.
 
 @param brightnessDelta  the brightness change delta specified as a value
 from -1.0 to 1.0. 0 means no change.
 
 @param alphaDelta       the alpha change delta specified as a value
 from -1.0 to 1.0. 0 means no change.
 */
- (UIColor *)jvs_colorByChangeHue:(CGFloat)hueDelta
                      saturation:(CGFloat)saturationDelta
                      brightness:(CGFloat)brightnessDelta
                           alpha:(CGFloat)alphaDelta;

///值不需要除以255.0
+ (UIColor *)jvs_colorWithWholeRed:(CGFloat)red
                            green:(CGFloat)green
                             blue:(CGFloat)blue
                            alpha:(CGFloat)alpha;
///值不需要除以255.0
+ (UIColor *)jvs_colorWithWholeRed:(CGFloat)red
                            green:(CGFloat)green
                             blue:(CGFloat)blue;

/**
 *  @brief  随机颜色
 *
 *  @return UIColor
 */
+ (UIColor *)jvs_randomColor;

/**
 *  @brief  渐变颜色
 *
 *  @param c1     开始颜色
 *  @param c2     结束颜色
 *  @param height 渐变高度
 *
 *  @return 渐变颜色
 */
+ (UIColor*)jvs_gradientFromColor:(UIColor*)c1 toColor:(UIColor*)c2 withHeight:(int)height;

/**
 * 反转颜色
 */
- (UIColor *)jvs_invertedColor;
/**
 * 半透明颜色
 */
- (UIColor *)jvs_colorForTranslucency;
/**
 * 浅色
 */
- (UIColor *)jvs_lightenColor:(CGFloat)lighten;
/**
 * 深色
 */
- (UIColor *)jvs_darkenColor:(CGFloat)darken;


#pragma mark - Get color's description
///=============================================================================
/// @name Get color's description
///=============================================================================

/**
 Returns the rgb value in hex.
 @return hex value of RGB,such as 0x66ccff.
 */
- (uint32_t)jvs_rgbValue;

/**
 Returns the rgba value in hex.
 
 @return hex value of RGBA,such as 0x66ccffff.
 */
- (uint32_t)jvs_rgbaValue;

/**
 Returns the color's RGB value as a hex string (lowercase).
 Such as @"0066cc".
 
 It will return nil when the color space is not RGB
 
 @return The color's value as a hex string.
 */
- (nullable NSString *)jvs_hexString;

/**
 Returns the color's RGBA value as a hex string (lowercase).
 Such as @"0066ccff".
 
 It will return nil when the color space is not RGBA
 
 @return The color's value as a hex string.
 */
- (nullable NSString *)jvs_hexStringWithAlpha;


#pragma mark - Retrieving Color Information
///=============================================================================
/// @name Retrieving Color Information
///=============================================================================

/**
 Returns the components that make up the color in the HSL color space.
 
 @param hue         On return, the hue component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param saturation  On return, the saturation component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param lightness   On return, the lightness component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param alpha       On return, the alpha component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @return            YES if the color could be converted, NO otherwise.
 */
- (BOOL)jvs_getHue:(CGFloat *)hue
       saturation:(CGFloat *)saturation
        lightness:(CGFloat *)lightness
            alpha:(CGFloat *)alpha;

/**
 Returns the components that make up the color in the CMYK color space.
 
 @param cyan     On return, the cyan component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param magenta  On return, the magenta component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param yellow   On return, the yellow component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param black    On return, the black component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @param alpha    On return, the alpha component of the color object,
 specified as a value between 0.0 and 1.0.
 
 @return         YES if the color could be converted, NO otherwise.
 */
- (BOOL)jvs_getCyan:(CGFloat *)cyan
           magenta:(CGFloat *)magenta
            yellow:(CGFloat *)yellow
             black:(CGFloat *)black
             alpha:(CGFloat *)alpha;

/**
 The color's red component value in RGB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat jvs_red;

/**
 The color's green component value in RGB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat jvs_green;

/**
 The color's blue component value in RGB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat jvs_blue;

/**
 The color's hue component value in HSB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat jvs_hue;

/**
 The color's saturation component value in HSB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat jvs_saturation;

/**
 The color's brightness component value in HSB color space.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat jvs_brightness;

/**
 The color's alpha component value.
 The value of this property is a float in the range `0.0` to `1.0`.
 */
@property (nonatomic, readonly) CGFloat jvs_alpha;

/**
 The color's colorspace model.
 */
@property (nonatomic, readonly) CGColorSpaceModel jvs_colorSpaceModel;

/**
 Readable colorspace string.
 */
@property (nullable, nonatomic, readonly) NSString *jvs_colorSpaceString;


@end

NS_ASSUME_NONNULL_END
