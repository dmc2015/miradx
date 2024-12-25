#!/usr/bin/env bash
set -x  # Print each command before executing
set -e  # Exit immediately if a command exits with a non-zero status

bundle install || exit 1

echo "RAILS_ENV: $RAILS_ENV"
echo "DATABASE_URL: ${DATABASE_URL:=not set}"

bundle exec rake assets:precompile || exit 1
bundle exec rake assets:clean || exit 1

RAILS_ENV=production bundle exec rails db:migrate || exit 1

echo "========================================"



echo "========================================"
echo "Starting MiraDx Risk Analysis API build script"
echo "========================================"

echo "Setting errexit option..."
set -o errexit

echo "Starting installation of dependencies..."
echo "Running bundle install..."
bundle install
echo "Bundle install completed"

echo "----------------------------------------"
echo "Starting asset compilation..."
echo "Running asset precompile..."
bundle exec rake assets:precompile
echo "Asset precompile completed"

echo "Running asset clean..."
bundle exec rake assets:clean
echo "Asset clean completed"

echo "----------------------------------------"
echo "Checking environment variables..."
echo "DATABASE_URL status: $(if [ -z "$DATABASE_URL" ]; then echo "NOT SET"; else echo "IS SET"; fi)"
echo "RAILS_ENV is: $RAILS_ENV"

echo "----------------------------------------"
echo "Starting database setup..."
echo "Creating database..."
RAILS_ENV=production bundle exec rails db:create
echo "Running migrations..."
RAILS_ENV=production bundle exec rails db:migrate
echo "Database setup completed"

echo "========================================"
echo "Build script completed"
echo "========================================"
