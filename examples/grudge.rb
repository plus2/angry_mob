require 'angry_mob'
require 'exemplor'

module Power
	def powers!
		puts "power!"
	end
end

module Puff
	def puff!
		puts "puff!"
	end
end

eg 'grudgey' do
	powers = {
		[:a] => Power,
		[:a,:c] => [Power,Puff]
	}

	g = AngryMob::AngryStruct.new({:a => {'b' => 1}}, :powers => powers)

	g.a.b.tapp

	g.a.powers!

	g.a.c.powers!
	g.a.c.puff!

	g.a.c.d = "hello"

	puts g.a.c.d.upcase

	g.a.c.to_hash.tapp

	g.a.b = { :good => 'bye' }

	g.a.to_hash.tapp


end
