require 'eg_helper'

eg 'parses dot syntax' do
  ah = AngryHash[:hello => {:a => 1}]

  ah.add_dotted("hello.there.matey" => 2, :wot => :evah, 'hi.foo' => 123)

  Show(ah)
end
