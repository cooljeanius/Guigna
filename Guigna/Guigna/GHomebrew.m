#import "GHomebrew.h"
#import "GPackage.h"

@implementation GHomebrew

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    if (self) {
        self.name = @"Homebrew";
        self.homepage = @"http://mxcl.github.com/homebrew/";
        self.prefix = @"/usr/local";
        self.cmd = [NSString stringWithFormat:@"%@/bin/brew", self.prefix];
    }
    return self;
}

- (NSArray *)list {
    // NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ search", self.cmd] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"/usr/bin/ruby -C %@/Library/Homebrew -I. -e require__'global';require__'formula';Formula.each__{|f|__puts__f.name+'__'+f.version}", self.prefix] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    [self.packagesIndex removeAllObjects];
    [self.items removeAllObjects];
    for (NSString *line in output) {
        NSArray *components = [line componentsSeparatedByString:@" "];
        GPackage *package = [[GPackage alloc] initWithName:components[0]
                                                   version:components[1]
                                                    system:self
                                                    status:GAvailableStatus];
        [self.items addObject:package];
        (self.packagesIndex)[[package key]] = package;
    }
    for (GPackage *package in self.installed) {
        ((GPackage *)(self.packagesIndex)[[package key]]).status = package.status;
    }
    return self.items;
}


- (NSArray *)installed {
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ list --versions", self.cmd] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    NSMutableArray *packages = [NSMutableArray array];
    NSArray *outdated = [self outdated];
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
        // TODO: return [] if name == "Error"
        GPackage *package = [[GPackage alloc] initWithName:name
                                                   version:components[1]
                                                    system:self
                                                    status:status];
        [packages addObject:package];
    }
    return packages;
}

- (NSArray *)outdated {
    // TODO make recognize --verbose option
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ outdated", self.cmd] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    NSMutableArray *packages = [NSMutableArray array];
    for (NSString *line in output) {
        NSArray *components = [line componentsSeparatedByString:@" "];
        // TODO: return [] if name == "Error:"
        GPackage *package = [[GPackage alloc] initWithName:components[0]
                                                   version:@"..."
                                                    system:self
                                                    status:GOutdatedStatus];
        [packages addObject:package];
    }
    return packages;
}

- (NSString *)info:(GItem *)item {
    return [self outputFor:@"%@ info %@", self.cmd, item.name];
}

- (NSString *)home:(GItem *)item {
    NSString *output = [[self outputFor:@"%@ info %@", self.cmd, item.name] componentsSeparatedByString:@"\n"][1];
    return output;
}

- (NSString *)log:(GItem *)item {
    if (item != nil ) {
        return [NSString stringWithFormat:@"http://github.com/mxcl/homebrew/commits/master/Library/Formula/%@.rb", item.name];
    } else {
        return @"http://github.com/mxcl/homebrew/commits";
    }
}

- (NSString *)contents:(GItem *)item {
    return [self outputFor:@"%@ list %@", self.cmd, item.name];
}

- (NSString *)cat:(GItem *)item {
    return [self outputFor:@"%@ cat %@", self.cmd, item.name];
}

- (NSString *)deps:(GItem *)item {
    return [self outputFor:@"%@ deps -n %@", self.cmd, item.name];
}

- (NSString *)dependents:(GItem *)item {
    return [self outputFor:@"%@ uses --installed %@", self.cmd, item.name];
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
    return [NSString stringWithFormat:@"%@ update", self.cmd];
}

+ (NSString *)setupCmd {
    return @"ruby <(curl -fsSkL https://raw.github.com/mxcl/homebrew/go) ; /usr/local/bin/brew update";
}

+ (NSString *)removeCmd {
    return @"cd /usr/local ; curl -L https://raw.github.com/gist/1173223 -o uninstall_homebrew.sh; sudo sh uninstall_homebrew.sh ; rm uninstall_homebrew.sh ; sudo rm -rf /Library/Caches/Homebrew; rm -rf /usr/local/.git";
}

- (NSString *)hideCmd {
    return @"sudo mv /usr/local /usr/local_off"; // TODO: prefix
}

- (NSString *)unhideCmd {
    return @"sudo mv /usr/local_off /usr/local";
}

@end
