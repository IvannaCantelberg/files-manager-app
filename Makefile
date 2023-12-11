setup:
	@make build
	@make up 
	@make composer-update
build:
	docker-compose build --no-cache --force-rm
stop:
	docker-compose stop
up:
	docker-compose up -d

install-composer-project:
	docker exec laravel-docker bash -c "composer create-project laravel/laravel ."

composer-update:
	docker exec laravel-docker bash -c "composer update"
data:
	docker exec laravel-docker bash -c "php artisan migrate"
	docker exec laravel-docker bash -c "php artisan db:seed"


start:	
	docker exec laravel-docker bash -c "php artisan serve"


bash:
	docker exec -it laravel-docker bash 