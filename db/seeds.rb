# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Clear existing data

RiskAnalysis.delete_all
Action.delete_all
Commuter.delete_all

# Seed commuters
commuters = Commuter.create!([
                               { commuter_id: 'COM-001' },
                               { commuter_id: 'COM-002' },
                               { commuter_id: 'COM-003' }
                             ])

# Seed actions
actions = Action.create!([
                           { timestamp: '2022-01-01 10:05:11', action: 'walked on sidewalk', unit: 'mile',
                             quantity: 0.4 },
                           { timestamp: '2022-01-02 11:15:22', action: 'biked to work', unit: 'mile', quantity: 2.5 },
                           { timestamp: '2022-01-03 08:45:33', action: 'ran in park', unit: 'mile', quantity: 1.2 }
                         ])

# Seed risk analyses and associate commuters and actions
RiskAnalysis.create!([
                       { commuter: commuters[0], action: actions[0] },
                       { commuter: commuters[1], action: actions[1] },
                       { commuter: commuters[2], action: actions[2] }
                     ])

puts "Seeded #{Commuter.count} commuters, #{Action.count} actions, and #{RiskAnalysis.count} risk analyses!"
