setup:
	@make build
	@make up 
	# @make composer-update
build:
	docker-compose build --no-cache --force-rm
stop:
	docker-compose stop
up:
	docker-compose up -d

install-composer-project:
	docker exec server bash -c "composer create-project laravel/laravel ."

composer-update:
	docker exec server bash -c "composer update"
data:
	docker exec server bash -c "php artisan migrate"
	docker exec server bash -c "php artisan db:seed"


start:	
	docker exec server bash -c "php artisan serve"


bash:
	docker exec -it server bash 