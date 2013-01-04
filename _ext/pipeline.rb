require 'splitter'
require 'split_cloud'
require 'split_filterer'
require 'split_atomizer'
require 'atomizer'
require 'paginator'
require 'posts'

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::DataDir.new
  extension Awestruct::Extensions::Posts.new( '', :posts ) 
  extension Awestruct::Extensions::SplitFilterer.new( :posts, 'tags', 
                                                     :sanitize=>true,
                                                     :blacklist=>['author', 'authors', 'tags', 'tag',
                                                      'page', 'javascripts', 'images', 'readme', 'templates']
                                                    ) 
  extension Awestruct::Extensions::Paginator.new( :posts, 'index', :per_page=>30, :per_page_init=>5 )
  extension Awestruct::Extensions::Splitter.new( :posts, 
                                                 'tags',
                                                 'templates/tags', 
                                                 '/', 
                                                 :per_page=>30, :per_page_init=>5,
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
                                                 :per_page=>30, :per_page_init=>5,
                                                 :output_home_file=>'index',
                                                 :sanitize=>true )
  extension Awestruct::Extensions::Indexifier.new
  extension Awestruct::Extensions::SplitAtomizer.new( :posts, 
                                                     'tags',
                                                     '/', 
                                                     :num_entries=>10,
                                                     :sanitize=>true,
                                                     :whitelist=>['announcement', 'bean-validation', 'hibernate',
                                                      'hibernate-ogm', 'hibernate-search', 'hibernate-validator',
                                                      'jboss-tools', 'news', 'ogm', 'seam', 'weld', 'web-beans'],
                                                     :blacklist=>['author', 'authors', 'tags', 'tag',
                                                      'page', 'javascripts', 'images', 'readme', 'templates'])
  extension Awestruct::Extensions::SplitAtomizer.new( :posts, 
                                                   'author',
                                                   '/', 
                                                   :num_entries=>10,
                                                   :sanitize=>true,
                                                   :blacklist=>['sergey-smirnov'] )
  extension Awestruct::Extensions::Atomizer.new( 
    :posts, 
    '/feed.atom', 
    :num_entries=>100,
    :content_url=>'http://in.relation.to',
    :feed_title=> 'In Relation To' )
end

