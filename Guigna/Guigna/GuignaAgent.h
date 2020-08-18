#import <Foundation/Foundation.h>

@interface GuignaAgent : NSObject

@property(retain, atomic) id appDelegate;
@property(readwrite, atomic) int processID; // TODO: array of PIDs

- (NSString *)outputForCommand:(NSString *)command;
- (NSArray *)nodesForURL:(NSString *)url XPath:(NSString *)xpath;

@end
