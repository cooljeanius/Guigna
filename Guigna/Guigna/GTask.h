#import <Foundation/Foundation.h>

#import "GItem.h"

@interface GTask : NSObject

@property(weak) GItem *item;
@property(strong) NSString *command;
@property(readwrite) BOOL privileged;

- (GMark)mark;
- (GSystem *)system;

@end
