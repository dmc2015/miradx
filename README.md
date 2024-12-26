# MiraDx Risk Analysis API

A Rails API that calculates risk scores for activities measured in micromorts. Built for MiraDx technical interview Winter 2024.

## Quick Start Testing

The API is deployed and ready for testing at:

```
https://miradx-api.onrender.com/
```
**Note: if the server is inactive it might take a minute for it to respond to requests**

While the site shows a Rails default view, the POST endpoint is active. Test with:

```bash
curl -X POST https://miradx-api.onrender.com/risk_analyses \
-H "Content-Type: application/json" \
-d '{
  "commuterId": "COM-123",
  "actions": [
    {
      "timestamp": "2022-01-01 10:05:11",
      "action": "walked on sidewalk",
      "unit": "mile",
      "quantity": 0.4
    }
  ]
}'
```

Expected response:

```json
{
  "commuterId": "COM-123",
  "risk": 1000
}
```

## Stack & Dependencies

- Ruby 3.3.0
- Rails 7.0.8
- PostgreSQL
- RSpec with FactoryBot for testing

## Local Development Setup

### Prerequisites

1. Install Git:

   ```bash
   # macOS (using Homebrew)
   brew install git

   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install git
   ```

2. Install RVM (Ruby Version Manager):

   ```bash
   # Install GPG keys
   gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

   # Install RVM
   \curl -sSL https://get.rvm.io | bash -s stable
   source ~/.rvm/scripts/rvm
   ```

3. Install Ruby:

   ```bash
   rvm install 3.3.0
   rvm use 3.3.0 --default
   ```

4. Install PostgreSQL:

   ```bash
   # macOS
   brew install postgresql
   brew services start postgresql

   # Ubuntu/Debian
   sudo apt-get install postgresql postgresql-contrib libpq-dev
   ```

### Project Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/dmc2015/miradx.git
   cd miradx
   ```

2. Install dependencies:

   ```bash
   gem install bundler
   bundle install
   ```

3. Setup database:

   ```bash
   rails db:create
   rails db:migrate
   rails db:seed  # Optional: adds sample data
   ```

4. Start the server:

   ```bash
   rails s
   ```

5. Test the local endpoint:

   ```bash
   curl -X POST http://localhost:3000/risk_analyses \
   -H "Content-Type: application/json" \
   -d '{
     "commuterId": "COM-123",
     "actions": [
       {
         "timestamp": "2022-01-01 10:05:11",
         "action": "walked on sidewalk",
         "unit": "mile",
         "quantity": 0.4
       },
       {
         "timestamp": "2022-01-01 10:30:09",
         "action": "climbed stairs",
         "unit": "floor",
         "quantity": 3
       }
     ]
   }'
   ```

## API Documentation

### POST /risk_analyses

Calculate risk score for a set of activities.

#### Request Format

```json
{
  "commuterId": "COM-123",
  "actions": [
    {
      "timestamp": "2022-01-01 10:05:11",
      "action": "walked on sidewalk",
      "unit": "mile",
      "quantity": 0.4
    }
  ]
}
```

#### Validation Rules

- All timestamps must be on the same calendar day
- Valid units: "mile", "floor", "minute", "quantity"
- Quantity must be positive
- Each action requires timestamp, action name, unit, and quantity

#### Response Format

```json
{
  "commuterId": "COM-123",
  "risk": 5500
}
```

#### Error Responses

- 400 Bad Request: Missing required parameters
- 422 Unprocessable Entity: Validation failures (e.g., timestamps on different days)

## Key Implementation Details

### Time Validation

The core logic ensures all activities occur on the same calendar day, handling edge cases around midnight boundaries:

```ruby
def self.valid_dates?(actions)
  return false if actions.blank?

  first_action = parse_timestamp(actions.first)
  return false unless first_action

  return true if actions.size == 1

  day_start = first_action.beginning_of_day
  day_end = first_action.tomorrow.midnight - 1.second

  actions.drop(1).all? do |action|
    current_date = parse_timestamp(action)
    current_date.between?(day_start, day_end)
  end
end
```

### Risk Calculation

Activities are scored using unit-specific multipliers and a base risk factor:

```ruby
UNIT_MAPPING = {
  floor: 20,
  mile: 10,
  quantity: 1,
  minute: 5
}.freeze

BASE_RISK_MULTIPLIER = 250
```

## CI/CD

The project includes automated testing via GitHub Actions. On every pull request and push to main:

- Runs full RSpec test suite
- Uses PostgreSQL 14 for test database
- Generates and uploads test coverage reports

## Testing Highlights

Special attention was given to timestamp validation edge cases:

```ruby
# Same day activities including midnight boundaries
let(:same_day_actions) do
  [
    { timestamp: '2022-01-01 10:00:00' },
    { timestamp: '2022-01-01 23:59:59' }
  ]
end

# Cross-day validation
let(:different_day_actions) do
  [
    { timestamp: '2022-01-01 23:59:59' },
    { timestamp: '2022-01-02 00:00:00' }
  ]
end
```

## Architecture Notes

- Service objects pattern for business logic separation
- Transaction-safe database operations
- Comprehensive error handling with appropriate status codes
- Clean JSON response formatting

## Deployment

The application is designed to be deployed on any Ruby-compatible hosting platform that supports PostgreSQL. Key requirements:

- Ruby 3.3.0 runtime
- PostgreSQL database
- Environment variables for database configuration
- GitHub Actions workflow for CI running RSpec tests on PRs
- Required status checks configured to ensure tests pass before merging to main

- Currently deployed on Render at <https://miradx-api.onrender.com/>
