//
//  MDDataValidator.h
//

//

typedef enum
{
    DTValidatorTypeNone,
    DTValidatorTypeNotEmtpyString,
    DTValidatorTypeStringWithNoSpaces,
    DTValidatorTypeEmail,
    DTValidatorTypePhoneNumber,
    DTValidatorTypeNPI,
    DTValidatorTypeVerificationCode,
    DTValidatorTypeNumericPositive,
    DTValidatorTypeDate
} DTValidatorType;

@interface MDDataValidator : NSObject

+ (BOOL)validateCandidate:(NSString*)candidate withValidatorType:(DTValidatorType)validatorType;
+ (BOOL)validateUsername:(NSString *)candidate;
+ (BOOL)validateEmail:(NSString *)candidate;
+ (BOOL)validateNPI:(NSString *)candidate;
+ (BOOL)validateDate:(NSString*)candidate;

@end
