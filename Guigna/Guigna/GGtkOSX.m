#import "GGtkOSX.h"
#import "GPackage.h"

@implementation GGtkOSX

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    if (self) {
        self.name = @"Gtk-OSX";
        self.homepage = @"http://live.gnome.org/GTK%2B/OSX";
        self.prefix = [@"~/.local/" stringByExpandingTildeInPath];
        self.cmd = [NSString stringWithFormat:@"%@/bin/jhbuild", self.prefix];
    }
    return self;
}


// TODO: 
- (NSString *)log:(GItem *)item {
    return @"// http://git.gnome.org/browse/gtk-osx/";
}

// TODO: test

+ (NSString *)setupCmd {
    return @"cd ~/Library/Application\\ Support/Guigna/ ; curl -L -O http://git.gnome.org/browse/gtk-osx/plain/gtk-osx-build-setup.sh ; sh gtk-osx-build-setup.sh ; ~/.local/bin/jhbuild bootstrap ; ~/.local/bin/jhbuild build meta-gtk-osx-bootstrap ; ~/.local/bin/jhbuild build meta-gtk-osx-core ; ~/.local/bin/jhbuild shell";
}

@end
