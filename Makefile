CURRENT_DIR=$(shell pwd)

APP=$(shell basename ${CURRENT_DIR})

APP_CMD_DIR=${CURRENT_DIR}/cmd

IMG_NAME=${APP}
REGISTRY=${REGISTRY}

TAG=latest
ENV_TAG=latest
# Including
include .build_info

go:
	go run  ${CURRENT_DIR}/cmd/main.go 

run:
	docker-compose -f docker-compose.yml up --force-recreate

test:
	docker-compose -f docker-compose.test.yml up --force-recreate

dc-config:
	docker-compose -f docker-compose.yml config

build:
	CGO_ENABLED=0 GOOS=linux go build -mod=vendor -a -installsuffix cgo -o ${CURRENT_DIR}/bin/${APP} ${APP_CMD_DIR}/main.go


clear:
	rm -rf ${CURRENT_DIR}/bin/*

network:
	docker network create --driver=bridge ${NETWORK_NAME}

mark-as-production-image:
	docker tag ${REGISTRY}/${IMG_NAME}:${TAG} ${REGISTRY}/${IMG_NAME}:production
	docker push ${REGISTRY}/${IMG_NAME}:production

build-image:
	docker build --no-cache --rm -t ${REGISTRY}/${IMG_NAME}:${TAG} .
	docker tag ${REGISTRY}/${IMG_NAME}:${TAG} ${REGISTRY}/${IMG_NAME}:${ENV_TAG}

push-image:
	docker push ${REGISTRY}/${IMG_NAME}:${TAG}
	docker push ${REGISTRY}/${IMG_NAME}:${ENV_TAG}

swag_init:
	swag init -g api/main.go -o api/docs

.PHONY: proto

