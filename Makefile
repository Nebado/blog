DOCKER_COMPOSE = docker-compose
EXEC_SYMFONY   = $(DOCKER_COMPOSE) exec -T php php bin/console
EXEC_COMPOSER  = $(DOCKER_COMPOSE) exec -T php composer
EXEC_PHP       = $(DOCKER_COMPOSE) exec -T php php

# Protect targets
.PHONY: php-cs-fixer phpcpd phpmd phpstan fix

analyse: composer-valid container-linter mapping-valid phpstan phpmd phpcpd

phpstan: # Search for possible errors
	@echo -e "\e[32mRunning phpstan...\e[0m"
	$(EXEC_PHP) vendor/bin/phpstan analyse --configuration=phpstan.neon --memory-limit=4G

phpmd: # Detects mess code
	@echo -e "\e[32mRunning phpmd...\e[0m"
	@$(EXEC_PHP) vendor/bin/phpmd src/ text .phpmd.xml

phpcpd: # Detects code duplicates
	@echo -e "\e[32mRunning phpcpd...\e[0m"
	@$(EXEC_PHP) vendor/bin/phpcpd src --exclude src/Admin/Controller

php-cs-fixer :  # # Corrects the code to meet the standards
	@echo -e "\e[32mRunning php-cs-fixer...\e[0m"
	@$(EXEC_PHP) vendor/bin/php-cs-fixer fix

composer-valid: # Checks if your composer.json is valid.
	@echo -e "\e[32mRunning composer validate...\e[0m"
	$(EXEC_COMPOSER) valid

container-linter: # Guarantees that the arguments injected in the services correspond to the type declarations.
	@echo -e "\e[32mRunning container linter...\e[0m"
	@$(EXEC_SYMFONY) lint:container

mapping-valid:
	@echo -e "\e[32mRunning mapping valid...\e[0m"
	@$(EXEC_SYMFONY) doctrine:schema:valid --skip-sync

fix: php-cs-fixer
