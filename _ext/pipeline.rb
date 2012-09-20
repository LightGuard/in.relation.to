require 'splitter'
require 'split_cloud'

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::Posts.new( '', :posts ) 
  extension Awestruct::Extensions::Paginator.new( :posts, '/index', :per_page=>10 )
  extension Awestruct::Extensions::Splitter.new( :posts, 
                                                 'tags',
                                                 '/index', 
                                                 '/tags', 
                                                 :per_page=>10,
                                                 :sanitize=>true )
  extension Awestruct::Extensions::SplitCloud.new( :posts,
                                                 'tags',
                                                 '/tags/index.html', 
                                                 :layout=>'blog',
                                                 :title=>'Tags')
  extension Awestruct::Extensions::Splitter.new( :posts, 
                                                 'author',
                                                 '/index', 
                                                 '/author', 
                                                 :per_page=>10,
                                                 :sanitize=>true )
  extension Awestruct::Extensions::Indexifier.new
  extension Awestruct::Extensions::Atomizer.new( 
    :posts, 
    '/feed.atom', 
    :num_entries=>10000,
    :content_url=>'http://in.relation.to',
    :feed_title=> 'No Relation To' )
end

