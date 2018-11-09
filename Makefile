build:
	docker build . -t jmervine/splunk-nginx-defaults:latest

push:
	docker push jmervine/splunk-nginx-defaults:latest

.PHONY = build push
