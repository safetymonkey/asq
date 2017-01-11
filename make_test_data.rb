asq = Asq.new(:name => "Test asq", :query => "select * from test;")
asq.save

database = Database.new(:name => "PageDB", :hostname => "pagedb1.sad.marchex.com", :db_type => "mysql")
database.save

database = Database.new(:name => "FortKnoxDB", :hostname => "fortknoxb1.sad.marchex.com", :db_type => "postgres")
database.save