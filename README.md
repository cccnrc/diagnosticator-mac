# Diagnosticator - Mac

---

## Dependencies
[Diagnosticator](https://diagnosticator.com) can be easily installed on Mac. Just follow these simple steps to install needed dependencies:

1. Brew
To install  you need [brew](https://brew.sh/index_it). Just open a terminal and type:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Docker
To install [docker](https://www.docker.com):
```
brew install docker
brew install docker-machine
brew install virtualbox --cask
docker-machine create --driver virtualbox default --virtualbox-hostonly-cidr "192.168.56.3/24" dev
```
- ***note***: if you get an ***error*** with the latest command have a look [here](https://medium.com/crowdbotics/a-complete-one-by-one-guide-to-install-docker-on-your-mac-os-using-homebrew-e818eb4cfc3)
- ***note***: if you get an `E_ACCESSDENIED` error have a look at [this](https://stackoverflow.com/questions/70281938/docker-machine-unable-to-create-a-machine-on-macos-vboxmanage-returning-e-acces)

check that it works:
```
docker run hello-world
```

3. Docker-Compose
```
brew install docker-compose
```

4. jq
```
brew install jq
brew install wget
```
