app_name=phpvirtualbox
app_version=$(shell ./version.sh)

docker_repo=fbartels
docker_name=phpvirtualbox
docker_login=`cat ~/.docker-account-user`
docker_pwd=`cat ~/.docker-account-pwd`

all: build run

build:
	if [ -z ${app_version} ] ; then echo "no target app_version specified"; exit 13; fi
	if [ `systemctl is-active docker` = "inactive" ] ; then sudo systemctl start docker; fi
	sudo docker build -t $(docker_name) .

run: clean build
	sudo docker run -it \
	--publish=9080:80 \
	-e ID_PORT_18083_TCP=127.0.0.1:5678 \
	--name=$(app_name) $(docker_name)

clean:
	sudo docker rm $(app_name) || exit 0

repo-login:
	sudo docker login -u $(docker_login) -p $(docker_pwd)

# Docker publish
publish: build repo-login publish-latest publish-version

publish-latest: tag-latest
	@echo 'publish latest to $(docker_repo)'
	sudo docker push $(docker_repo)/$(docker_name):latest

publish-version: tag-version
	@echo 'publish $(app_version) to $(docker_repo)'
	sudo docker push $(docker_repo)/$(docker_name):$(app_version)

# Docker tagging
tag: tag-latest tag-version

tag-latest:
	@echo 'create tag latest'
	sudo docker tag $(docker_name) $(docker_repo)/$(docker_name):latest

tag-version:
	@echo 'create tag $(VERSION)'
	sudo docker tag $(docker_name) $(docker_repo)/$(docker_name):$(app_version)

