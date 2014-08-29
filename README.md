Securifi Almond 
=======

### Setup instructions

1. Ensure you have [cocoapods](http://cocoapods.org) installed on your Mac`
```
$ [sudo] gem install cocoapods

$ pod setup
```

2. Navigate to `iosapp` project root and run  
```
    $ pod install
```
3. Open the workspace, not the proj file  
```
    $ open Almond.xcworkspace
```
4. **Build and Run!**

### Development Instructions

Anytime you change get changed CoreData, Storyboards, etc files, make sure to run _clean_ before **Build & Run**.

If podfile changes, make sure to run `pod update`

### Podspec files

We use `cocoapods` to manage all of our dependences.  Some dependencies have old pods or don't have pods at all, so we created some of our own. All of them are found under `podspecs` directory.
