# Diagnosticator - Homebrew

Instructions to setup a [brew](https://brew.sh/index_it) package (see [here](https://betterprogramming.pub/a-step-by-step-guide-to-create-homebrew-taps-from-github-repos-f33d3755ba74?gi=6c4ab43c1533))

1. add a tag to the current repo ([diagnosticator-mac](https://github.com/cccnrc/diagnosticator-mac.git))
```
git tag -a v0.1.0 -m "version 0.1.0"
git push origin v0.1.0
```

2. create the new realease on [diagnosticator-mac](https://github.com/cccnrc/diagnosticator-mac.git) and get the `.tar.gz` [link](https://github.com/cccnrc/diagnosticator-mac/archive/refs/tags/v0.1.0.tar.gz)
```
brew create https://github.com/cccnrc/diagnosticator-mac/archive/refs/tags/v0.1.0.tar.gz
```
