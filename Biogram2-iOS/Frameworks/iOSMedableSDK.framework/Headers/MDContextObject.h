//
//  MDContextObject.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

@protocol MDContextObject <NSObject>
@required
- (NSString*)context;
- (NSString*)objectId;
- (NSString*)objectDescription;

@end
