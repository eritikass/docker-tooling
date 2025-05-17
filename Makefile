DIR ?= $(shell pwd)

default:
	@echo "no action[DIR=$(DIR)]..."

test_build_run_nginx:
	cd ./nginx-dir-listing && docker build -t nginx-dir-listing .
	@echo "Open -> http://localhost:80/"
	docker run --rm -p 80:80 -v "$(DIR):/usr/share/nginx/html/_test" nginx-dir-listing