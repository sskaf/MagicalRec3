//
//  MagicalImportFunctions.m
//  Magical Record
//
//  Created by Saul Mora on 3/7/12.
//  Copyright (c) 2012 Magical Panda Software LLC. All rights reserved.
//

#import "MagicalImportFunctions.h"

NSString *MRAttributeNameFromString(NSString *value)
{
    NSString *firstCharacter = [[value substringToIndex:1] capitalizedString];
    return [firstCharacter stringByAppendingString:[value substringFromIndex:1]];
}

NSString *MRPrimaryKeyNameFromString(NSString *value)
{
    NSString *firstCharacter = [[value substringToIndex:1] lowercaseString];
    return [firstCharacter stringByAppendingFormat:@"%@ID", [value substringFromIndex:1]];
}

NSDate *MRAdjustDateForDST(NSDate *date)
{
    NSTimeInterval dstOffset = [[NSTimeZone localTimeZone] daylightSavingTimeOffsetForDate:date];
    NSDate *actualDate = [date dateByAddingTimeInterval:dstOffset];

    return actualDate;
}

NSDate *MRDateFromString(NSString *value, NSString *format)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:format];

    NSDate *parsedDate = [formatter dateFromString:value];

    return parsedDate;
}

NSDate *MRDateFromNumber(NSNumber *value, BOOL milliseconds)
{
    NSTimeInterval timeInterval = [value doubleValue];

    if (milliseconds)
    {
        timeInterval = timeInterval / 1000.00;
    }

    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}

NSNumber *MRNumberFromString(NSString *value)
{
    return [NSNumber numberWithDouble:[value doubleValue]];
}

#if TARGET_OS_IPHONE

UIColor *MRColorFromString(NSString *serializedColor)
{
    NSInteger *componentValues = MRNewColorComponentsFromString(serializedColor);
    if (componentValues == NULL)
    {
        return nil;
    }

    UIColor *color = [UIColor colorWithRed:(componentValues[ 0 ] / (CGFloat)255.)
                                     green:(componentValues[ 1 ] / (CGFloat)255.)
                                      blue:(componentValues[ 2 ] / (CGFloat)255.)
                                     alpha:componentValues[ 3 ]];

    free(componentValues);
    return color;
}

#else

NSColor *MRColorFromString(NSString *serializedColor)
{
    NSInteger *componentValues = MRNewColorComponentsFromString(serializedColor);
    if (componentValues == NULL)
    {
        return nil;
    }

    NSColor *color = [NSColor colorWithDeviceRed:(componentValues[ 0 ] / (CGFloat)255.)
                                           green:(componentValues[ 1 ] / (CGFloat)255.)
                                            blue:(componentValues[ 2 ] / (CGFloat)255.)
                                           alpha:componentValues[ 3 ]];
    free(componentValues);
    return color;
}

#endif

NSInteger *MRNewColorComponentsFromString(NSString *serializedColor)
{
    NSScanner *colorScanner = [NSScanner scannerWithString:serializedColor];
    NSString *colorType;
    [colorScanner scanUpToString:@"("
                      intoString:&colorType];

    NSInteger *componentValues = malloc(4 * sizeof(NSInteger));
    if (componentValues == NULL)
    {
        return NULL;
    }

    if ([colorType hasPrefix:@"rgba"])
    {
        NSCharacterSet *rgbaCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"(,)"];

        NSInteger *componentValue = componentValues;
        while (![colorScanner isAtEnd])
        {
            [colorScanner scanCharactersFromSet:rgbaCharacterSet
                                     intoString:nil];
            [colorScanner scanInteger:componentValue];
            componentValue++;
        }
    }
    return componentValues;
}
