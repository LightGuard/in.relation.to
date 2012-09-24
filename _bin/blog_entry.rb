class BlogEntry
  attr_accessor :title, :content, :author, :blogger_name, :tags, :slug, :date, :lace

  def to_erb
    tag_string = ""
    tags.each { |tag| tag_string += tag }


    erb = "---\n" << 
    "title: '#{@title}'\n" <<
    "author: '#{@author}'\n" << 
    "blogger_name: '#{@blogger_name}'\n" << 
 #   "publish date: '#{date}\n" << 
    "layout: blog-post\n" << 
    "tags: [#{tag_string}]\n" << 
    "slug: #{slug}\n" <<
    "lace: #{@lace}\n" << 
    "---\n" <<
    "#{content}\n"

  end

  def file_name
  	date_string = date.strftime( "%Y-%m-%d" )
  	return "#{date_string}-#{slug}.erb"
  end
end
