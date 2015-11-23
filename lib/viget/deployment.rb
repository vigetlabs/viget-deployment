raise <<-EOF


Deployment configuration has changed, update your `config/deploy.rb` file to
point to the appropriate set of deployment recipes.  For 'rails' this would be:

  require 'viget/deployment/rails'

You can substitute the appropriate recipe set (e.g 'craft') as needed.

EOF