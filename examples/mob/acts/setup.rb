require 'web_server/nginx'


act 'hello', :on => 'start' do
  sh "echo hello"

  act_now Nginx, :hello => 'there'
end
