# encoding: utf-8
#
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.current = User.system


john  = User.create! name: 'John Smith', email: 'js@example.com', login: 'jsmith'
ulf   = User.create! name: 'Ulf', email: 'ulf@hpi.uni-potsdam.de', login: 'ulf'
eve   = User.create! name: 'Eve Longhorn', email: 'eve@macrosoft.com', login: 'longeve'
bob   = User.create! name: 'Bob Baumeister', email: 'bob@bau.de', login: 'boby'
alice = User.create! name: 'Alice Thorn', email: 'athorn@schatten.de', login: 'atho'

caf = Cafeteria.create! name: "Mensa Griebnitzsee", address: "Somewhere"
m = caf.meals.create! date: Time.zone.now.to_date, name: "Essen 1", description: "Grießspeise mit Früchten (iee)"
m.comments.create! user: john, message: "Gar nicht so schlecht wie sonst."
m.comments.create! user: alice, message: "klappe. könte kotzen alta"

m = caf.meals.create! date: Time.zone.now.to_date, name: "Essen 2", description: "Steak mit Pommes (lecker)"
m.comments.create! user: eve, message: "Ein ausgewogenes Gericht basierend auf wissenschaftlich nachgewiesenen aktuellen Bedarfs- und Nährungstabellen."

m = caf.meals.create! date: Time.zone.now.tomorrow.to_date, name: "Essen 1", description: "BIO-Nudeln mit veganer Soße"
m.comments.create! user: bob, message: "Bäää WARUM SCHON WIEDER VEGAN????!?!??!?"
caf.meals.create! date: Time.zone.now.tomorrow.to_date, name: "Essen 2", description: "Kalamari mit würzigen Ofenkartoffeln"
caf.meals.create! date: Time.zone.now.tomorrow.to_date, name: "Essen 3", description: "Rinderzunge vom Grill mit Kroketten"

ulf = Cafeteria.create! name: "Ulf's Cafe", address: "A.E-0"
m = ulf.meals.create! date: Time.zone.now.to_date,
  name: "Wiener Schnitzen mit Pilzen", description: "Würziges Schnitzel nach Wiener Art mit frischen
  Pilzen sowie Beilage nach Wahl."
m.comments.create! user: ulf, message: "Als Beilagen gibt's heute Kartoffeln, Kroketten und Pommes."

ulf.meals.create! date: Time.zone.now.tomorrow.to_date,
  name: "Potsdammer Jägerschnitzel", description: "Ein weiterer kulinarischer Schmeiß aus der regionalen Küche."
ulf.meals.create! date: Time.zone.now.tomorrow.tomorrow.to_date,
  name: "Berliner Currywurst", description: "Berlinerisch scharf - das Original."
