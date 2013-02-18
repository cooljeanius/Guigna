#import "GMacOSX.h"
#import "GPackage.h"

@implementation GMacOSX

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    if (self) {
        self.name = @"Mac OS X";
        self.homepage = @"http://support.apple.com/downloads/";
        self.prefix = @"/usr/sbin";
        self.cmd = [NSString stringWithFormat:@"%@/pkgutil", self.prefix];
    }
    return self;
}

// TODO: 
- (NSArray *)list {
    return [self installed];
}


- (NSArray *)installed {
    // TODO: status available for uninstalled packages
    [self.packagesIndex removeAllObjects];
    [self.items removeAllObjects];  
    NSArray *history = [NSArray arrayWithContentsOfFile:@"/Library/Receipts/InstallHistory.plist"];
    for (NSDictionary *dict in history) {
        NSString *name = dict[@"displayName"];
        NSString *version = dict[@"displayVersion"];
        NSString *category = [[dict[@"processName"] stringByReplacingOccurrencesOfString:@" " withString:@""] capitalizedString];
        NSString *ID = [dict[@"packageIdentifiers"] componentsJoinedByString:@" "];
        GPackage *package = [[GPackage alloc] initWithName:name
                                                   version:version
                                                    system:self
                                                    status:GUpToDateStatus];
        package.ID = ID;
        package.categories = category;
        package.description = ID;
        [self.items addObject:package];
        // [self.packagesIndex setObject:package forKey:[package key]];
    }
    [self.items setArray:[[self.items reverseObjectEnumerator] allObjects]];
//    for (GPackage *package in self.installed) {
//        ((GPackage *)[self.packagesIndex objectForKey:[package key]]).status = package.status;
//    }
    return self.items;
}

- (NSArray *)outdated {
    NSMutableArray *packages = [NSMutableArray array];
    // TODO: sudo /usr/sbin/softwareupdate --list
    return packages;
}

- (NSArray *)inactive {
    NSMutableArray *packages = [NSMutableArray array];
    for (GPackage *package in [self installed]) {
        if (package.status == GInactiveStatus)
            [packages addObject:package];
    }
    return packages;
}

- (NSArray *)availableCommands {
    return @[@"forget"];
}


- (NSString *)info:(GItem *)item {
    NSMutableString *output = [NSMutableString string]; 
    for (NSString *pkgID in [item.ID componentsSeparatedByString:@" "]) {
        [output appendString:[self outputFor: @"/usr/sbin/pkgutil --pkg-info %@", pkgID]];        
    }
    return output;

}

// TODO: macappstore://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=12

- (NSString *)log:(GItem *)item {
        return @"http://support.apple.com/downloads/";
}

- (NSString *)contents:(GItem *)item {
    NSMutableString *output = [NSMutableString string]; 
    for (NSString *pkgID in [item.ID componentsSeparatedByString:@" "]) {
        NSDictionary *plist = [[self outputFor:@"%@ --pkg-info-plist %@", self.cmd, pkgID] propertyList];
        NSString *prefix = [NSString stringWithFormat:@"%@%@", plist[@"volume"], plist[@"install-location"]];
        NSMutableArray *outputLines = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ --files %@", self.cmd, pkgID] componentsSeparatedByString:@"\n"]];
        [outputLines removeObjectAtIndex:[outputLines count]-1];
        for (NSString *line in outputLines) {
            [output appendFormat:@"%@/%@\n", prefix, line ];
        }
    }
    return output;
}

- (NSString *)cat:(GItem *)item {
    return @"TODO";
}

@end
