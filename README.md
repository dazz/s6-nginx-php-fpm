# S6 nginx/php-fpm container


## usage

This is a simple container with nginx and php-fpm based on alpine linux.
To install all the dependencies and build the container run:

```bash
make up
```

## What is this about
We often have the case that we need to deploy our PHP application to `$server`, but since PHP does not come with its own
webserver we always run a second container which passes the requests to our PHP process.
We looked into many options and decided against them for different reasons.

- **Kubernetes:** Overkill for a PHP-Application
- **Docker Compose:** Not recommended in production, not well documented
- **FrankenPHP:** Not stable enough (at the time), written in go, compiles PHP
- **SupervisorD:** Not recommended for running as PID 1 in a dockerized environment
- **SystemD:** Not available for alpine (package requires gclib)
- **s6-overlay:** Works like a charm in ubuntu (glibc) and alpine (musl) and is made for running as PID 1 in container


## What are the components
We installed just an index file in the `app` directory to showcase a running php application.

- Alpine
- s6-overlay
- nginx
- php-fpm

We use preconfigured user `www-data` and install the app in `var/www/html`.

## s6-overlay
- starts PID 1 with `ENTRYPOINT ["/init"]`
- starts all services and scripts that are defined in `/etc/s6-overlay/s6-rc.d/user/contents.d`

## Recipes
Use cases and how they can be solved using s6

### Feature Flags
Sometimes you need to enable or disable services. 

> s6-rc wasn't made for dynamic service sets; it was made for reliability and predictability of the machine state, 
> which runtime changes are bad for - and you're going against its design by attempting to conditionally start services.

> The way to achieve what you want is by making sure that only the services you want to activate are in s6-rc's user 
> bundle, which contains everything that will be started. For that purpose, you have the S6_STAGE2_HOOK environment variable: 
> in it, put the path to a script, and that script will be run before s6-rc analyzes its service set. 
> That script should be the one to read your environment variables, and adjust the files of /etc/s6-overlay/s6-rc.d/user/contents accordingly.


```yaml
# docker-compose.yml
services:
  app:
    environment:
      S6_STAGE2_HOOK: /etc/s6-hook/feature-toggle
      FEATURE_MIGRATIONS_ENABLED: "false"
```

#### /etc/s6-hook/feature-toggle
```shell
#!/command/with-contenv sh

# Read environment variable and default to "false" if not set
INIT_MIGRATIONS="${FEATURE_MIGRATIONS_ENABLED:-false}"

# Define a space-separated list of feature toggles (since arrays are not supported in sh)
# the feature name is the upper SNAKE_CASE version of the feature directory name in lower kebab-case
features="INIT_MIGRATIONS"

# Iterate through each feature toggle
for feature in $features; do
    # Get the value of the environment variable, default to "false" if not set
    is_enabled=$(eval echo \${$feature:-false})

    # Convert the feature name to lowercase and replace underscores with hyphens
    feature_file=$(echo "$feature" | tr 'A-Z' 'a-z' | tr '_' '-')

    # Check if the feature is enabled
    if [ "$is_enabled" = "true" ]; then
        touch "/etc/s6-overlay/s6-rc.d/user/contents.d/$feature_file"
    else
        rm -f "/etc/s6-overlay/s6-rc.d/user/contents.d/$feature_file"
    fi
done

exit 0
```

### Doctrine Migrations

```shell []
/etc/s6-overlay/s6-rc.d
├── init-migrations
│   ├── dependencies.d
│   │    └── svc-php-fpm
│   ├── type
│   └── up
└── scripts
        └── init-migrations
```

```shell []
#!/command/with-contenv sh
s6-setuidgid www-data

php /var/www/html/bin/console doctrine:migrations:migrate --env=`printcontenv APP_ENV` --no-interaction
php /var/www/html/bin/console doctrine:migrations:status --env=`printcontenv APP_ENV`
```

### CronJobs with Symfony Scheduler Component

```shell []
/etc/s6-overlay/s6-rc.d
├── svc-scheduler
│   ├── dependencies.d
│   │    └── svc-php-fpm
│   ├── type
│   └── up
└── scripts
        └── svc-scheduler
```

```shell []
#!/command/with-contenv sh
s6-setuidgid www-data

php /var/www/html/bin/console messenger:consume scheduler_default \
  --time-limit=300 \
  --limit=10 \
  --env=`printcontenv APP_ENV` --quiet
```

### check requirements in dev

```shell []
/etc/s6-overlay/s6-rc.d
├── init-dependencies
│   ├── dependencies.d
│   │    ├── base
│   │    └── svc-php-fpm
│   ├── type
│   └── up
└── scripts
        └── init-dependencies
```

```shell []
#!/command/with-contenv sh

# Check if the composer binary exists
if command -v composer >/dev/null 2>&1; then
    # Composer is installed, run composer install
    echo "init-dependencies: info: Composer found. Checking dependencies."
    composer -d /var/www/html check-platform-reqs
    exit 0
fi
echo "init-dependencies: info: Composer not found. Please install Composer before running this script."
exit 0
```