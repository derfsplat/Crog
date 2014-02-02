require 'rubygems'
require 'active_record'

class Event < ActiveRecord::Base
  belongs_to :location
  has_many :reservations
  has_many :people, :through => :reservations
end

class Person < ActiveRecord::Base
  self.primary_key = 'id'
  self.table_name = 'Attendees'

  has_many :reservations
  has_many :events, :through => :reservations

  validates :firstname, :lastname, :format => { :with => /\A[A-Za-z]+\z/, :message => 'Only a-z allowed' }
  validates :firstname, :lastname, :length => { :minimum => 2, :maximum => 50, :too_short => 'Too short - min 2', :too_long => 'Too long - max 50' }
end

#undoing the "Person" model override would negate need for middle-man reservation
#and we could re-write this as Has And Belongs To Many HABTM
class Reservation < ActiveRecord::Base
  belongs_to :event
  belongs_to :person, :foreign_key => :attendee_id
end

class Location < ActiveRecord::Base
  has_many :events
end

def print_that_shit(events)
  puts 'Event results:'
  events.each do |e|
    puts "#{e.title} at #{e.location.name}"
    if e.people.any?
      puts "Attendees:"
      e.people.each do |a|
        puts a.firstname
      end
    end
  end
end

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
                                        :database => 'dinnerparty.db',
                                        :pool => 5,
                                        :timeout => 5000)
=begin
#poopulate data
att1 = Person.new
att1.firstname = 'Fred'
att1.lastname = 'Johanns'
att1.save
event = Event.create(:title => 'Fancy Dinner', :eventdate => '2014-2-2', :location_id => 2)
=end

#add attendees through code
=begin
att1 = Person.new
att1.firstname = 'Dingle'
att1.lastname = 'Berrie'
att1.save
event = Event.where("title = 'Fancy Dinner'").first()
event.people.push att1
event.save
=end

#location relationship to events
'All events at each location:'
Location.all().each do |l|
    puts "Events at location #{l.name}"
    l.events.each do |e|
      puts e.title
    end
end

#invalid attendee using regex validaton
puts 'Invalid attendee creation:'
#use create! to throw an error immediately
att = Person.create(:firstname => '3', :lastname => 'blarg2')
unless att.valid?
  att.errors.each { |e| puts "#{e} #{att.errors[e]}" }
end
#searching
puts 'Searching for events:'
events = Event.all() #first, #last, #find(id)
print_that_shit(events)

#the following 2 won't work bc sqlite is picky about dates- left here as an example
#(even if it's set to 3-2-2014 after the update below, still doesn't work)
event = Event.find_by_title_and_eventdate('Fancy Dinner', '2014-3-2')
puts event.title unless event.nil?
events = Event.where(:title => 'Fancy Dinner', :eventdate => '>= 2014-3-2')
puts events.title if events.any?

events = Event.where("title = 'Fancy Dinner' and eventdate >= '2-2-2014'")
unless events.nil?
  puts
  puts 'Working method:'
  puts events.class.name
  puts events.explain
  if events.any?
    print_that_shit(events)
  end
end

event = events.first()
event.eventdate = '2014-2-3'
event.save
#alternatively:
event.update_attributes(eventdate: '2014-2-4')

#delete
#event.destroy

ActiveRecord::Base.connection.close