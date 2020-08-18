#import <Foundation/Foundation.h>

#import "GItem.h"

@interface GTask : NSObject

@property(weak, atomic) GItem *item;
@property(strong, atomic) NSString *command;
@property(readwrite, atomic) BOOL privileged;

- (GMark)mark;
- (GSystem *)system;

@end
