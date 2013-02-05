#import "GCocoaPods.h"
#import "GPackage.h"

@implementation GCocoaPods

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    if (self) {
        self.name = @"CocoaPods";
        self.homepage = @"http://www.cocoapods.org";
        self.prefix = @"/opt/local";
        self.cmd = [NSString stringWithFormat:@"%@/bin/pod", self.prefix];
    }
    return self;
}

- (NSArray *)list {
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ list --no-color", self.cmd] componentsSeparatedByString:@"--> "]];
    [output removeObjectAtIndex:0];
    [self.packagesIndex removeAllObjects];
    [self.items removeAllObjects];
    for (NSString *pod in output) {
        NSArray *lines = [pod componentsSeparatedByString:@"\n"];
        NSInteger sep = [lines[0] rangeOfString:@" (" options:NSBackwardsSearch].location;
        NSString *name = [lines[0] substringToIndex:sep];
        NSString *version = [lines[0] substringWithRange:NSMakeRange(sep+2, [lines[0] length]-sep-3)];
        GPackage *package = [[GPackage alloc] initWithName:name
                                                   version:version
                                                    system:self
                                                    status:GAvailableStatus];
        NSMutableString *description = [NSMutableString string];
        NSString *nextLine;
        int i = 1;
        while (![(nextLine = [lines[i++] substringFromIndex:4]) hasPrefix:@"- "]) {
            if (i !=2)
                [description appendString:@" "];
            [description appendString:nextLine];
        };
        package.description = description;
        if ([nextLine hasPrefix:@"- Homepage:"]) {
            package.homepage = [nextLine substringFromIndex:12];
        }
        [self.items addObject:package];
        (self.packagesIndex)[[package key]] = package;
    }
    // TODO
    //    for (GPackage *package in self.installed) {
    //        ((GPackage *)[self.packagesIndex objectForKey:[package key]]).status = package.status;
    //    }
    return self.items;
}


- (NSArray *)installed {
    NSMutableArray *packages = [NSMutableArray array];
    // TODO
    return packages;
    NSArray *outdated = [self outdated];
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ list", self.cmd] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    NSString *name;
    GStatus status;
    for (NSString *line in output) {
        NSArray *components = [line componentsSeparatedByString:@" "];
        name = components[0];
        status = GUpToDateStatus;
        if ([outdated count] > 0) {
            for (GPackage *package in outdated) {
                if ([name isEqualToString:package.name]) {
                    status = GOutdatedStatus;
                    break;
                }
            }
        }
        GPackage *package = [[GPackage alloc] initWithName:name
                                                   version:components[1]
                                                    system:self
                                                    status:status];
        [packages addObject:package];
    }
    return packages;
}

- (NSArray *)outdated {
    NSMutableArray *packages = [NSMutableArray array];
    // TODO
    return packages;
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ outdated", self.cmd] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    for (NSString *line in output) {
        NSArray *components = [line componentsSeparatedByString:@" "];
        GPackage *package = [[GPackage alloc] initWithName:components[0]
                                                   version:@"..."
                                                    system:self
                                                    status:GOutdatedStatus];
        [packages addObject:package];
    }
    return packages;
}

// TODO
- (NSString *)info:(GItem *)item {
    return [self outputFor:@"%@ search --stats --no-color %@", self.cmd, item.name];
}

- (NSString *)home:(GItem *)item {
        return item.homepage;
}

- (NSString *)log:(GItem *)item {
    if (item != nil ) {
        return [NSString stringWithFormat:@"http://github.com/CocoaPods/Specs/tree/master/%@", item.name];
    } else {
        return @"http://github.com/CocoaPods/Specs/commits";
    }
}

- (NSString *)contents:(GItem *)item {
    return [self outputFor:@"%@ search --stats --no-color %@", self.cmd, item.name];
}

// TODO:
- (NSString *)cat:(GItem *)item {
    return [self outputFor:@"%@ cat %@", self.cmd, item.name];
}

- (NSString *)deps:(GItem *)item {
    return [self outputFor:@"%@ search --stats --no-color %@", self.cmd, item.name];
}

- (NSString *)dependents:(GItem *)item {
    return [self outputFor:@"%@ search --stats --no-color %@", self.cmd, item.name];
}


- (NSString *) installCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ install %@", self.cmd, package.name];
}

- (NSString *) uninstallCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ remove %@", self.cmd, package.name];
}

- (NSString *) upgradeCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ upgrade %@", self.cmd, package.name];
    
}

- (NSString *)cleanCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ cleanup %@", self.cmd, package.name];
}

- (NSString *)selfupdateCmd {
    return [NSString stringWithFormat:@"%@ repo update  --no-color", self.cmd];
}

// TODO: 
+ (NSString *)setupCmd {
    return @"sudo /opt/local/bin/gem1.9 install pod; /opt/local/bin/pod setup";
}

+ (NSString *)removeCmd {
    return @"sudo /opt/local/bin/gem1.9 uninstall pod";
}

- (NSString *)hideCmd {
    return @"sudo mv /opt/local /opt/local_off"; // TODO: prefix
}

- (NSString *)unhideCmd {
    return @"sudo mv /opt/local_off /opt/local";
}

@end
