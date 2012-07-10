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

admin = User.create! name: 'admin', login: 'admin', email: 'admin@om.altimos.de'

Cafeteria.create! name: "Mensa Jena, Ernst-Abbe-Platz",
  address: "Ernst-Abbe-Platz", user: admin, url: "http://khaos.at/openmensa/jena_eabp.xml"
Cafeteria.create! name: "Mensa Jena, Philosophenweg",
  address: "Philosophenweg", user: admin, url: "http://khaos.at/openmensa/jena_philweg.xml"
Cafeteria.create! name: "Mensa Jena, Carl-Zeiss-Promenade",
  address: "Carl-Zeiss-Promenade", user: admin, url: "http://khaos.at/openmensa/jena_czprom.xml"
