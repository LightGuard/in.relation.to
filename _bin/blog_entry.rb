class BlogEntry
  attr_accessor :title, :post, :author, :tags, :url, :date

  
  def to_erb
  end

  def to_console
    puts "Author #{author}"
    puts "Tags #{tags}"
    puts "Url #{url}"
    puts "Post #{post}"
  end
end