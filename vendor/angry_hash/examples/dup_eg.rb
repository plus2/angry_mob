require 'eg_helper'

require 'angry_hash/extension'

eg.setup do
  @original = { 'database' => {
    "micropower_micropower_sandbox" => {"app_owner" => "micropower_micropower_sandbox", "server" => :db},
    "post_froggy"                   => {"app_owner" => "froggy_owner", "backup"                  => {"to_s3"                       => true}, "server" => :postfrog},
    "myfrogdb"                      => {"app_owner" => :myfroggy, "server"                       => :myfrog},
    "eggs_hwag"                     => {"app_owner" => "eggs_hwag", "backup"                     => {"to_s3"                       => true}, "server" => :db},
    "isg_sandbox_v5"                => {"app_owner" => "isg_sandbox_v5", "server"                => :isg_forums_mysql},
  }}    
end

eg 'duping copies symbols' do
  ah = AngryHash[ @original ]
  ah2 = AngryHash[ ah ]

  Assert( ! ah2.database.isg_sandbox_v5.server.nil? )
  Assert( ah2.database.isg_sandbox_v5.server == @original['database']['isg_sandbox_v5']['server'] )
end

def same_obj(a,b)
  a.__id__ == b.__id__
end

def diff_obj(a,b)
  ! same_obj(a,b)
end

eg 'dup is deep' do
  ah  = AngryHash[ @original ]
  ah2 = ah.dup

  Assert( diff_obj ah                            , ah2 )
  Assert( diff_obj ah.database                   , ah2.database )
  Assert( diff_obj ah.database.post_froggy       , ah2.database.post_froggy )
  Assert( diff_obj ah.database.post_froggy.backup, ah2.database.post_froggy.backup )

end

module Extendo
  def as_dag
    dag = dup_with_extension
    dag
  end

  def is_extended?
    true
  end
end

eg 'duping from ext' do
  ah = AngryHash[ @original ]
  ah.extend(Extendo)

  ah2 = ah.as_dag

  Show( ah.__id__ )
  Show( ah2.__id__ )
  
  Show( ah2 )
end

module ExtendoDb
  def is_db_extended?
    true
  end
end

eg 'extension preservation' do
  ah = AngryHash[ @original ]
  Assert( ! ah.is_extended? )
  Assert( ! ah.database.post_froggy.is_db_extended? )

  ah.extend(Extendo)
  ah.database.post_froggy.extend(ExtendoDb)

  Assert(   ah.is_extended? )
  Assert(   ah.database.post_froggy.is_db_extended? )

  ah2 = ah.dup
  Show( ah2.is_extended? )
  Show( ah2.database.post_froggy.is_db_extended? )
end
