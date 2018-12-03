.PHONY: help build start destroy test

TOKEN := eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ

.DEFAULT: help
help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/\n\t/'

build:	## build docker container
	docker build -t pando85/openresty-nginx-jwt .

start:	## start docker container
start: destroy build
	docker run --rm \
	-d --name openresty-nginx-jwt \
	-e JWT_SECRET=secret \
	-v $(shell pwd)/nginx.conf:/etc/nginx/nginx.conf \
	-v $(shell pwd)/bearer.lua:/etc/nginx/bearer.lua \
	-p 8080:8080 \
	pando85/openresty-nginx-jwt

destroy:	## destroy docker container
destroy:
	docker rm -f openresty-nginx-jwt || true

test:	## run tests
test: start
	curl -s -H "Authorization:Bearer ${TOKEN}" localhost:8080/secure/ | grep "<p>i am protected by jwt<p>"
	curl -s "localhost:8080/secure/?token=${TOKEN}" | grep "<p>i am protected by jwt<p>"
	curl -s --cookie "token=${TOKEN}" localhost:8080/secure/ | grep "<p>i am protected by jwt<p>"
