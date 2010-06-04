require 'eg_helper'

eg.setup do
  @original = { 'database' => {
    "micropower_micropower_sandbox"=>
    {"app_owner"=>"micropower_micropower_sandbox", "server"=>:db},
      "amc_accred_staging"=>
    {"app_owner"=>"amc_accred", "server"=>:plus2staging_local_mysql},
      "post_froggy"=>
    {"app_owner"=>"froggy_owner",
      "backup"=>{"to_s3"=>true},
      "server"=>:postfrog},
      "isg_url_shortener"=>
    {"app_owner"=>"isg_sandbox_v5", "server"=>:isg_forums_mysql},
      "isg_forums"=>{"app_owner"=>"isg_forums", "server"=>:isg_forums_mysql},
      "eggs_eggs"=>
    {"app_owner"=>"eggs_eggs",
      "backup"=>{"to_s3"=>true},
      "server"=>:db,
      "admin_owner"=>"eggs_admin"},
      "myfrogdb"=>{"app_owner"=>:myfroggy, "server"=>:myfrog},
      "amc_exam_staging"=>
    {"app_owner"=>"amc_exam", "server"=>:plus2staging_local_mysql},
      "micropower_golfo"=>{"app_owner"=>:golfo, "server"=>:linode_golfo_mysql},
      "linode_golfo"=>{"app_owner"=>:golfo, "server"=>:linode_golfo_mysql},
      "halal_staging"=>
    {"app_owner"=>"halal", "server"=>:plus2staging_local_postgres},
      "eggs_enag"=>
    {"app_owner"=>"eggs_enag", "backup"=>{"to_s3"=>true}, "server"=>:db},
      "amc_store"=>
    {"app_owner"=>"amc_store", "backup"=>{"to_s3"=>true}, "server"=>:amc},
      "weatherzone_wengine"=>
    {"app_owner"=>"weatherzone_wengine", "server"=>:linode_postgres},
      "weatherzone_wzfb_staging"=>
    {"app_owner"=>"weatherzone_wzfb_staging", "server"=>:db},
      "amc_ncmr"=>
    {"app_owner"=>"amc_ncmr", "backup"=>{"to_s3"=>true}, "server"=>:amc},
      "westpac_thinkbank_staging"=>
    {"app_owner"=>"westpac_thinkbank_staging", "server"=>:db},
      "micropower_micropower_staging"=>
    {"app_owner"=>"micropower", "server"=>:staging_mysql},
      "weatherzone_wx_staging"=>
    {"app_owner"=>"weatherzone_wx_staging", "server"=>:db},
      "isg_sandbox_v4"=>
    {"app_owner"=>"isg_sandbox_v5", "server"=>:isg_forums_mysql},
      "eggs_aecl"=>
    {"app_owner"=>"eggs_aecl", "backup"=>{"to_s3"=>true}, "server"=>:db},
      "eggs_hwag"=>
    {"app_owner"=>"eggs_hwag", "backup"=>{"to_s3"=>true}, "server"=>:db},
      "plus2_gemcutter"=>{"app_owner"=>"plus2_gemcutter", "server"=>:db},
      "isg_sandbox_v5"=>
    {"app_owner"=>"isg_sandbox_v5", "server"=>:isg_forums_mysql},
      "amc_exam"=>
    {"app_owner"=>"amc_exam", "backup"=>{"to_s3"=>true}, "server"=>:amc},
      "weatherzone_wzfb"=>
    {"app_owner"=>"weatherzone_wzfb", "backup"=>{"to_s3"=>true}, "server"=>:db},
      "amc_store_staging"=>
    {"app_owner"=>"amc_store", "server"=>:plus2staging_local_mysql}
  }}    
end

eg 'duping copies symbols' do
  ah = AngryHash[ @original ]
  ah2 = AngryHash[ ah ]

  Assert( ! ah2.database.isg_sandbox_v5.server.nil? )
  Assert( ah2.database.isg_sandbox_v5.server == @original['database']['isg_sandbox_v5']['server'] )
end

module Extendo
  def as_dag
    dag = dup
    dag
  end
end

eg 'duping from ext' do
  ah = AngryHash[ @original ]
  ah.extend(Extendo)

  ah2 = ah.as_dag

  Show( AngryHash.shooper )
  Show( ah.__id__ )
  Show( ah2.__id__ )
  
  Show( ah2 )
end
