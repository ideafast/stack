#!/bin/sh
cd middleware-services/
docker build -t msimage .
docker run -d --name mscontainer -p 80:80 msimage
cd ../
