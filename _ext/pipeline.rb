require 'splitter'
require 'split_cloud'
require 'split_filterer'
require 'atomizer'
require 'paginator'

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::DataDir.new
  extension Awestruct::Extensions::Posts.new( '', :posts ) 
  extension Awestruct::Extensions::SplitFilterer.new( :posts, 'tags', ['author', 'authors', 'tags', 'tag'] ) 
  extension Awestruct::Extensions::Paginator.new( :posts, 'index', :per_page=>10 )
  extension Awestruct::Extensions::Splitter.new( :posts, 
                                                 'tags',
                                                 'templates/tags', 
                                                 '/', 
                                                 :per_page=>10,
                                                 :output_home_file=>'index',
                                                 :sanitize=>true )
  extension Awestruct::Extensions::SplitCloud.new( :posts,
                                                 'tags',
                                                 '/tags/index.html', 
                                                 :layout=>'blog',
                                                 :title=>'Tags')
  extension Awestruct::Extensions::Splitter.new( :posts, 
                                                 'author',
                                                 'templates/author', 
                                                 '/', 
                                                 :per_page=>10,
                                                 :output_home_file=>'index',
                                                 :sanitize=>true )
  extension Awestruct::Extensions::Indexifier.new
  extension Awestruct::Extensions::Atomizer.new( 
    :posts, 
    '/feed.atom', 
    :num_entries=>10000,
    :content_url=>'http://in.relation.to',
    :feed_title=> 'No Relation To' )
end

