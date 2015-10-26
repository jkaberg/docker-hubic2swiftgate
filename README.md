# docker-hubic2swiftgate


# Download
``` bash
sudo apt-get install -y git
sudo git clone https://github.com/jkaberg/docker-hubic2swiftgate
cd docker-hubic2swiftgate
```

Edit the config file in config/config.php by,
* Going to https://hubic.com/home/browser/developers/ and getting the necessary information
* Add an application
* Fill out last name an redirection domain (https://**** IP OR FQDN ****:9443/callback/) Very important!
* Hit Details to get the necessary client id and secret client
* fill out config.php

# Build
``` bash
docker build -t hubic2swiftgate .
```

# Run
``` bash
docker run -d -p 9443:443 --name hubic2swiftgate --restart always hubic2swiftgate
```

Then at last configure hubic2swiftgate at
```
https://**** IP OR FQDN ****:9443/register/?client=hubic&password=****yourHubicPassword****
```

You can then mount hubic2swiftgate with s3ql or similar like so,
``` bash
mount.s3ql swift://localhost:9443/<bucketname> <mountpoint>
```