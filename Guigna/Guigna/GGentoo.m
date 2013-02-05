#import "GGentoo.h"
#import "GPackage.h"

@implementation GGentoo

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    if (self) {
        self.name = @"Gentoo";
        self.homepage = @"http://www.gentoo.org/proj/en/gentoo-alt/prefix/";
        self.prefix = [@"~/Gentoo/" stringByExpandingTildeInPath];
        self.cmd = [NSString stringWithFormat:@"%@/bin/emerge", self.prefix];
    }
    return self;
}


// TODO: 
- (NSString *)log:(GItem *)item {
    return @"http://www.gentoo.org/proj/en/gentoo-alt/prefix/";
}

+ (NSString *)setupCmd {
    return @"TODO";
}

@end
