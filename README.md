**GUIGNA: the GUI of Guigna is Not by Apple  :)**

Guigna* is the prototype of a GUI supporting Homebrew, MacPorts, Fink and pkgsrc at the same time.
This branch was originally a fork, but upstream moved their branch to [https://github.com/gui-dos/Guigna](https://github.com/gui-dos/Guigna), so now this technically isn't a fork any more...

### Design and ideas###
Guigna was born as a single MacRuby script for personal use: it tries to
abstract several package managers by creating generalized classes
(GSystem and GPackage) while keeping a minimalist approach and using screen
scraping.

Guigna doesn't hide the complexity of compiling open source software: it launches
the shell commands in a Terminal window you can monitor and interrupt. When
administration privilege is required, the password for `sudo` can be typed
directly in the Terminal brougth to the foreground thanks to the Scripting Bridge. 

When several package managers are detected, their sandboxes are hidden by appending
`_off` to their prefix before the compilation phase. An off-line mode, however, allows
to still get the details about the packages by scraping directly their original
websites.


\* The [Kodkod](http://en.wikipedia.org/wiki/Kodkod) (Leopardus guigna), also called Guiña,
is the smallest cat in the Americas.
