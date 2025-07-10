namespace :import do
  desc "Import news articles and their like counts"
  task news_articles: :environment do
    require 'csv'

    csv_path = Rails.root.join('data', 'news_articles.csv')
    unless File.exist?(csv_path)
      puts "CSV file not found at #{csv_path}"
      next
    end

    puts "Importing articles from: #{csv_path}"

    CSV.foreach(csv_path, headers: true) do |row|
      title = row['title']
      article = Article.find_or_initialize_by(title: title)

      article.assign_attributes(
        publication_date: row['publication_date'],
        category: row['category'],
        author: row['author'],
        body: read_html_body(title)
      )

      if article.save
        puts "✔ Imported: #{title}"
        article.like_counts.destroy_all # idempotent step
        parse_likes(row['like_counts_per_date']).each do |date, count|
          article.like_counts.create!(date: date, count: count)
        end
      else
        puts "⚠ Failed to save article: #{title}"
        puts article.errors.full_messages
      end
    end
  end

  def read_html_body(title)
    filename = title.downcase.gsub(/[\s\-\/]/, '_')
                             .gsub(/[.:\'%]/, '')
                             .concat('.html')
    file_path = Rails.root.join('data', filename)
    File.read(file_path)
  rescue Errno::ENOENT
    puts "⚠ Missing body file for: #{title}"
    ''
  end

  def parse_likes(likes_string)
    likes_string.split('|').map { |pair| pair.split(':') }.to_h.transform_values(&:to_i)
  end
end
