#!/usr/bin/env bash

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
echo "Starting database preparation..."
echo "Running db:prepare..."
bundle exec rails db:prepare
echo "Database preparation completed"

echo "========================================"
echo "Build script completed"
echo "========================================"