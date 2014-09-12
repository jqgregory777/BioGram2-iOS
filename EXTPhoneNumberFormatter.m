//  Created by Ahmed Abdelkader on 1/22/10.
//  This work is licensed under a Creative Commons Attribution 3.0 License.

#import "EXTPhoneNumberFormatter.h"

@implementation EXTPhoneNumberFormatter

- (id)init {
    NSArray *usPhoneFormats = [NSArray arrayWithObjects:
                               @"+1 (###) ###-####",
                               @"1 (###) ###-####",
                               @"011 $",
                               @"###-####",
                               @"(###) ###-####", nil];
    
    NSArray *ukPhoneFormats = [NSArray arrayWithObjects:
                               @"+44 ##########",
                               @"00 $",
                               @"0### - ### ####",
                               @"0## - #### ####",
                               @"0#### - ######", nil];
    
    NSArray *jpPhoneFormats = [NSArray arrayWithObjects:
                               @"+81 ############",
                               @"001 $",
                               @"(0#) #######",
                               @"(0#) #### ####", nil];
    
    _predefinedFormats = [[NSDictionary alloc] initWithObjectsAndKeys:
                         usPhoneFormats, @"us",
                         ukPhoneFormats, @"ul",
                         jpPhoneFormats, @"jp",
                         nil];
    
    return self;
}

- (NSString *)regionFromLocale:(NSString *)locale {
    // extract lowercased region code from locale id (e.g. "en_US" --> "us")
    NSString* region = [locale lowercaseString];
    NSArray* components = [region componentsSeparatedByString:@"_"];
    if([components count] >= 2) {
        region = components[1];
    }
    return region;
}

- (NSString *)placeholderStringForLocale:(NSString *)locale {
    NSString* region = [self regionFromLocale:locale];
    
    NSArray *localeFormats = [_predefinedFormats objectForKey:region];
    
    if(localeFormats == nil)
        // locale id's region code not found -- default to U.S.A.
        localeFormats = [_predefinedFormats objectForKey:@"us"];
    
    if(localeFormats != nil) {
        unsigned long count = [localeFormats count];
        if (count > 0) {
            unsigned long index = count - 1;
            return localeFormats[index];
        }
    }
    
    return @"(###) ###-####"; // fail safe - should never get here
}

- (NSString *)format:(NSString *)phoneNumber withLocale:(NSString *)locale {
    // extract lowercased region code from locale id (e.g. "en_US" --> "us")
    NSString* region = [self regionFromLocale:locale];
    
    NSArray *localeFormats = [_predefinedFormats objectForKey:region];

    if(localeFormats == nil)
        // locale id's region code not found -- default to U.S.A.
        localeFormats = [_predefinedFormats objectForKey:@"us"];

    if(localeFormats == nil)
        return phoneNumber;

    NSString *input = [self strip:phoneNumber];
    
    for(NSString *phoneFormat in localeFormats) {
        int i = 0;
        
        NSMutableString *temp = [[NSMutableString alloc] init];
        
        for(int p = 0; temp != nil && i < [input length] && p < [phoneFormat length]; p++) {
            char c = [phoneFormat characterAtIndex:p];
            BOOL required = [self canBeInputByPhonePad:c];
            char next = [input characterAtIndex:i];
            
            switch(c) {
                case '$':
                    p--;
                    [temp appendFormat:@"%c", next];
                    i++;
                    break;
                    
                case '#':
                    if(next < '0' || next > '9') {
                        temp = nil;
                        break;
                    }
                    [temp appendFormat:@"%c", next];
                    i++;
                    break;
                    
                default:
                    if(required) {
                        if(next != c) {
                            temp = nil;
                            break;
                        }
                        [temp appendFormat:@"%c", next];
                        i++;
                    } else {
                        [temp appendFormat:@"%c", c];
                        if(next == c)
                            i++;
                    }
                    break;
            }
        }
        
        if(i == [input length]) {
            return temp;
        }
    }
    
    return input;
}


- (NSString *)strip:(NSString *)phoneNumber {
    NSMutableString *res = [[NSMutableString alloc] init];
    
    for(int i = 0; i < [phoneNumber length]; i++) {
        char next = [phoneNumber characterAtIndex:i];
        
        if([self canBeInputByPhonePad:next])
            [res appendFormat:@"%c", next];
    }
    
    return res;
}


- (BOOL)canBeInputByPhonePad:(char)c {
    if(c == '+' || c == '*' || c == '#') return YES;
    if(c >= '0' && c <= '9') return YES;
    return NO;
}


// NOT NEEDED in ARC MODE
//- (void)dealloc {
//    [_predefinedFormats release];
//    [super dealloc];
//}


@end