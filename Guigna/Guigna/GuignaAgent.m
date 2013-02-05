#import "GuignaAgent.h"

@implementation GuignaAgent

@synthesize appDelegate, processID;

- (id)init {
    self = [super init];
    if (self) {
        self.processID = -1;
    }
    return self;
}

- (NSString *)outputForCommand:(NSString *)command {    
    NSTask *task = [[NSTask alloc] init];
    NSArray *tokens = [command componentsSeparatedByString:@" "];
    command = tokens[0];
    NSMutableArray *args = [NSMutableArray array];
    if ([tokens count] > 1) {
        NSArray *components = [tokens subarrayWithRange: NSMakeRange(1, [tokens count]-1)];
        for (NSString *component in components){
            [args addObject:[component stringByReplacingOccurrencesOfString:@"__" withString:@" "]];
        }
    }
    [task setLaunchPath:command];
    [task setArguments:args];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:[NSPipe pipe]]; // Suppress STDERR
    [task setStandardInput:[NSPipe pipe]]; // NSLog workaround
    [task launch];
    processID = [task processIdentifier];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    processID = -1;
    // int status = [task terminationStatus]; // TODO
    NSString __autoreleasing *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

- (NSArray *)nodesForURL:(NSString *)url XPath:(NSString *)xpath {
    NSError *error = nil;
    NSMutableString *page = [NSMutableString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
    NSData *data = [page dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLDocument __autoreleasing *doc = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:&error];
    NSArray *nodes = [[doc rootElement] nodesForXPath:xpath error:&error];
    return nodes;
}

@end
