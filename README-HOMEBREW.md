# Diagnosticator - Homebrew

Basically you ping-pong [homebrew](https://brew.sh/index_it) between two different github repositories:
- the repository with all the scripts and executables: [diagnosticator-mac](https://github.com/cccnrc/diagnosticator-mac.git)
- the repository that points [homebrew](https://brew.sh/index_it) to the other one, which cointains only a `.rb` file that specifies dependencies etc: [homebrew-diagnosticator](https://github.com/cccnrc/homebrew-diagnosticator.git)

[brew](https://brew.sh/index_it) creates a package based on `URL` specified on the `.rb` file through what is called a `tap`

---
## Instructions
Instructions to setup a [brew](https://brew.sh/index_it) package (see [here](https://betterprogramming.pub/a-step-by-step-guide-to-create-homebrew-taps-from-github-repos-f33d3755ba74?gi=6c4ab43c1533))

1. add a tag to [diagnosticator-mac](https://github.com/cccnrc/diagnosticator-mac.git)
```
git tag -a v0.1.0 -m "version 0.1.0"
git push origin v0.1.0
```

2. create the new realease on [diagnosticator-mac](https://github.com/cccnrc/diagnosticator-mac/tags) and get the `.tar.gz` [v0.1.0](https://github.com/cccnrc/diagnosticator-mac/archive/refs/tags/v0.1.0.tar.gz)
```
brew create https://github.com/cccnrc/diagnosticator-mac/archive/refs/tags/v0.1.0.tar.gz
```
this automatically opens an `.rb` file that you can edit as you wish

3. edit the `diagnosticator-mac.rb` created file and copy it in the new empty repo [homebrew-diagnosticator](https://github.com/cccnrc/homebrew-diagnosticator/blob/main/diagnosticator.rb)

4. remove the original `diagnosticator-mac.rb` created file
```
rm /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/diagnosticator-mac.rb
```

5. create the `tap`
```
cd
brew tap cccnrc/diagnosticator
# Cloning into '/usr/local/Homebrew/Library/Taps/cccnrc/homebrew-diagnosticator'...
# ...
```

6. install it
```
brew install diagnosticator
```

7. check
```
which diagnosticator
```

8. in case you need to remove
```
brew uninstall diagnosticator
```

---
## Update [diagnosticator-mac](https://github.com/cccnrc/diagnosticator-mac.git)
This updates the scripts run. You have to create a new tag:
```
VERSION='0.1.10'
git add .
git commit -m "version $VERSION"
git push
git tag -a v"${VERSION}" -m "version $VERSION"
git push origin v"${VERSION}"
```
***create the new realease*** on [diagnosticator-mac](https://github.com/cccnrc/diagnosticator-mac/tags) and get the `.tar.gz` [v0.1.1](https://github.com/cccnrc/diagnosticator-mac/archive/refs/tags/v0.1.1.tar.gz)
```
brew create https://github.com/cccnrc/diagnosticator-mac/archive/refs/tags/v0.1.1.tar.gz
```
Update the `URL` value and copy and paste the new `sha256` value to your [homebrew-diagnosticator](https://github.com/cccnrc/homebrew-diagnosticator/blob/main/diagnosticator.rb)

Remove the new generated `.rb`
```
rm /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/diagnosticator-mac.rb
```
Then update `brew`:
```
brew upgrade
diagnosticator -v
```

---
## Update [homebrew-diagnosticator](https://github.com/cccnrc/homebrew-diagnosticator/tree/main)

Then you have to `uninstall` and `untap`:
```
brew uninstall --force diagnosticator
brew untap cccnrc/diagnosticator
```
then just tap again
```
brew tap cccnrc/diagnosticator
brew install diagnosticator
```
