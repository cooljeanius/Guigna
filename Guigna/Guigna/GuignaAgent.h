#import <Foundation/Foundation.h>

@interface GuignaAgent : NSObject

@property(retain) id appDelegate;
@property(readwrite) int processID; // TODO: array of PIDs

- (NSString *)outputForCommand:(NSString *)command;
- (NSArray *)nodesForURL:(NSString *)url XPath:(NSString *)xpath;

@end
