# Viget Deployment Recipes

This gem provides the standard deployment recipes and configurations that we use for deploying Rails 3 applications.  The philosophy is very much "convention over configuration" -- its aim is to remove boilerplate deployment configuration from our projects. Rather than requiring you to maintain a large number of configuration settings directly in the `deploy.rb` file, this tool makes intelligent guesses based on how we prefer to deploy applications.

At its core, this library takes care of these aspects of deployment:

* Multi-environment support
* Bundler integration
* Smart configuration file generation
* Deployment notifications to Slack
* Maintenance mode
* Asset precompilation
* Running migrations on every deploy

While many of the defaults are chosen for you, every effort has been made to allow customization where necessary.

## Installation

Since this gem is not intended for public release, you must reference the desired release tag from your `Gemfile`:

    gem 'viget-deployment', :github => 'vigetlabs/viget-deployment', :tag => '1.0.1', :group => :development, :require => false

## 5-Minute Configuration & Deployment

Run `capify .` if you don't already have a Capfile present (https://github.com/vigetlabs/viget_rails_application_setup will do this for you).

Create a `deploy.rb` file:

    # config/deploy.rb
    require 'viget/deployment'
    set :application, 'puma'
    set :user, "deploy"

Create at least one environment file (for your default environment):

    # config/deploy/integration.rb
    server '192.168.1.1', :web, :app, :db, :primary => true

Deploy the latest code:

    $ cap setup
    $ cap deploy

## Configuration

Every deployment requires at least 2 files:

* `config/deploy.rb` -- Handles overall deployment configuration (e.g. strategy, source, notifications, etc...).
* `config/deploy/<environment>.rb` -- Handles the configuration for the target deployment host(s).  The filename is dependent on your default deployment environment (typically `integration`).

### Basic

Once installed, a basic `deploy.rb` file might look like:

    # config/deploy.rb
    require 'viget/deployment'
    set :application, 'puma'

What this does:

* Uses `www-data` as the remote deployment user
* Deploys via git with a remote cache
* Sets the default environment to `integration`
* Deploys from the repository at the URL `git@github.com:vigetlabs/puma.git`
* Uses `/var/www/puma/integration` as the base deployment directory
* Deploys from the `master` branch

The corresponding `deploy/integration.rb` file might look like:

    # config/deploy/integration.rb
    server '192.168.1.1', :app, :web, :db, :primary => true

The default configuration values are chosen based on our common deployment scenarios.  Based on this philosophy, we map the following remote branches to the different deployment environments:

    origin/master     => integration
    origin/staging    => staging
    origin/production => production

### Advanced

Deployments can be customized further, adding features like deployment notifications, configuration file generation, and integration with cron via the [whenever gem](http://github.com/javan/whenever).

There are some common core configuration changes you might want to make based on your deployment.  These can be specified in the main `deploy.rb` or an environment-specific file based on your needs:

* `:user` -- Name of the remote deployment user, defaults to `www-data`
* `:default_stage` -- Target environment when you run just `cap deploy`, defaults to `integration`.
* `:repository` -- Repository to use for fetching the source, defaults to `git@github.com:vigetlabs/{application}.git`.
* `:deploy_to` -- Target path for the application source, it contains the `current`, `shared`, and `releases` directories.  Defaults to `/var/www/{application}/{environment}`.
* `:branch` -- The remote branch to deploy from, defaults to the name of the environment (e.g. `staging`), or `master` when deploying to the `integration` environment.

To change one of these values, all you need to do is use `set` where necessary:

    # config/deploy/production.rb
    set :user, 'apache' # RHEL5
    server '192.168.1.1', :app, :web, :db, :primary => true

Other configuration changes are addressed in the following sections.

#### Bundler Integration

We assume the use of bundler in all deployment environments and use the default Capistrano integration that it provides, with one exception.  When bundling dependencies in the target environment we add the `--binstubs` flag to the defaults.  This places the binaries from your installed dependencies in a `bin` directory within the root deployment directory. So, instead of typing `rails c integration` to get a console, you'll need to use `./bin/rails c integration`.

This affects the default cron configuration as you'll see in a later section.

#### Deployment Notifications to Slack

Notifications are set to go out by default, all you need to do is provide the channel name and [webhook URL](http://vigesafe.lab.viget.com/passwords/80588ecb-c996-413a-9b58-23e12c11b535):

    # config/deploy.rb
    set :slack_url,     'https://hooks.slack.com/...'
    set :slack_channel, '#wcs'

Other configuration options:

    # Username to display for this notification
    #
    # Default: <environment> Deploy
    set :slack_username, 'WCS Deploy'

    # Emoji to show for the notification's avatar
    #
    # Default: :bell:
    set :slack_emoji, ':shoekid:'

    # URL of your app
    #
    # Default: nil
    set :slack_app_url, 'http://wcs.staging.vigetx.com/admin'

#### Configuration File Generation

One pain point we've experienced is the managing of configuration files that contain login information for various services.  As part of the core deployment strategy there is a facility to generate these configuration files when required. To generate a database configuration file, for example, you only need to create the template file it will use:

    # config/deploy/config_files/database.yml.erb
    <%= rails_env %>:
      adapter: mysql2
      encoding: utf8
      database: <%= Capistrano::CLI.ui.ask("Database name: ") %>
      pool: 5
      username: <%= Capistrano::CLI.ui.ask("Database username: ") %>
      password: <%= Capistrano::CLI.ui.ask("Database password: ") %>
      host: <%= Capistrano::CLI.ui.ask("Database host: ") %>

Any time an application server is put into service (via the `cap setup` task) or when a full deployment happens, a check is done to see if the target file (`database.yml`) exists on all matched servers.  If not, the template is processed with ERB to generate the `database.yml` file that gets symlinked into the current deployment directory. This particular template will prompt the user for configuration parameters with the `ask` method.

While `config/deploy/config_files` is the default location for these files, you can change this as necessary:

    # config/deploy.rb
    set :configuration_template_path, '/path/to/configuration/templates'

Keep in mind that this isn't limited to database configuration files -- any configuration file can be generated from a template.  All you need to do is create a template in the `:configuration_template_path` directory in the form of `<name>.<extension>.erb` and it will be processed and saved as `<name>.<extension>`.  It doesn't even need to be a YAML file.

#### Maintenance Mode

Having a maintenance page in place for when a site needs an extended period of downtime is a good idea. The maintenance recipes in this gem are intended to make this easy for all projects.  By default, we distribute a simple maintenance page in the gem, but you can change that location if you have a custom version in your project:

    # config/deploy.rb
    set :maintenance_source, 'config/deploy/assets/maintenance.html'

Additionally, you can configure the remote location where the file is saved with the `:maintenance_path` and `:maintenance_target` settings. Even though this is possible, it's not recommended.

#### Cron Integration

Not all projects use cron, so this is provided as an add-on to be used when necessary.  To enable it, simply load it into your deployment configuration:

    # config/deploy.rb
    require 'viget/deployment'
    load 'cron'

Behind the scenes, this recipe uses the [whenever gem](http://github.com/javan/whenever) to install cron jobs on deployment.  When possible, we use the default settings, but there are a couple settings that are automatically configured when this recipe is loaded:

* `:whenever_command` -- Command that is run when installing cron jobs, defaults to `./bin/whenever` due to our use of `--binstubs` with bundler (above).
* `:whenever_identifier` -- Sentinel that appears in the crontab file which allows whenever to reliably update jobs on each deployment.  This defaults to `{application}_{environment}` to allow multiple environments to be deployed to the same server.

If you only want to use the cron recipes in a specific environment, you can simply include it in the desired environment configuration files instead of the main `deploy.rb`.

#### Support for rbenv

We use rbenv for some deployment environments which requires updates to the `PATH` on the target system.  If you're using rbenv, simply load this recipe in the appropriate environment(s):

    # config/deploy/integration.rb
    load 'rbenv'

#### Tailing logs

This is not available by default. To use this feature, load this recipe in the appropriate environment(s) or main `./config/deploy.rb` with:

    # config/deploy/production.rb
    load 'logs'

To use it, it will default to using the current environment (stage) name. However, you can specify a different filename if desired:

    $ cap production logs:tail

Or for something like `cron.log`:

    $ cap production logs:tail -s file=cron

#### Remote Rails console

This is not available by default. To use this feature, load this recipe in the appropriate environment(s) or main `./config/deploy.rb` with:

    # config/deploy/integration
    load 'rails_console'

To use it, it will default to using the current environment (stage) name.

    $ cap integration rails:console

## Deployment

In the interest of simplicity, this tool provides only a few top-level commands:

    $ cap setup
    $ cap deploy
    $ cap offline
    $ cap online


#### Git deploy tags

viget-deployment can automatically push a git tag containing the environment and timestamp. Just load the recipe in the appropriate environment(s):

    # config/deploy/production.rb
    load 'deploy_tag'


### Setup

This is how you bootstrap your application servers that you're putting into service:

    $ cap setup

This will use your default environment, to specify an alternate environment:

    $ cap staging setup

If you already have your code deployed on existing application servers and want to put another server into the rotation, you'll need to add it to your environment:

    # config/deploy/production.rb
    server '192.168.1.1', :app, :web, :db, :primary => true
    server '192.168.1.2', :app, :web # <- new server

And then target just that new server with the `HOSTFILTER` environment variable:

    $ HOSTFILTER=192.168.1.1 cap production setup

This recipe will:

* Create the necessary directories on the target server
* Deploy the latest code from the appropriate branch
* Create any required configuration files
* Bundle the necessary application dependencies
* Create the database (on servers whose role is `:db` and flagged `:primary => true`)

### Deploy

It's pretty easy to do a deployment and realize, after it's done, that you forgot to run migrations or load seed data into the database.  There's rarely a time that we would want to deploy code and not run any pending migrations, so this has been condensed into a single command:

    $ cap deploy

This will run migrations and seed data on the appropriate servers if necessary.

### Maintenance Mode

Enabling maintenance mode is simple as well.  To take down all the servers in the `:web` role:

    $ cap offline

Then, to bring them back up:

    $ cap online

This will put the maintenance file in the correct place, but you'll need to make sure the web server is configured correctly:

#### Apache

    RewriteEngine On

    ErrorDocument 503 /system/maintenance.html
    RewriteCond %{REQUEST_URI} !.(css|gif|jpg|png)$
    RewriteCond %{DOCUMENT_ROOT}/system/maintenance.html -f
    RewriteCond %{SCRIPT_FILENAME} !maintenance.html
    RewriteRule ^.*$ - [R=503,L]

#### Nginx

    set $maintenance      off;
    set $maintenance_file "/system/maintenance.html";

    if (-f "$document_root$maintenance_file") {
      set $maintenance on;
    }

    if ($request_uri ~* ".(css|gif|jpg|png)$") {
      set $maintenance off;
    }

    if ($request_uri = $maintenance_file) {
      set $maintenance off;
    }

    if ($maintenance = on) {
      return 503;
    }

    error_page 503 @maintenance;

    location @maintenance {
      rewrite ^(.*)$ $maintenance_file break;
    }
