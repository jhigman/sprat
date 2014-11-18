# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{testrun@testrunner.knowmalaria.co.uk}
role :web, %w{testrun@testrunner.knowmalaria.co.uk}
role :db, %w{testrun@testrunner.knowmalaria.co.uk}
role :resque_worker, %w{testrun@testrunner.knowmalaria.co.uk}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server 'testrunner.knowmalaria.co.uk', user: 'testrun', roles: %w{web app resque_worker}

# Resque config must be specified here (i.e. per env) and not in deploy.rb
set :workers, { "test_jobs" => 1 }
