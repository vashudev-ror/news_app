namespace :import do
  desc "Import news articles and their like counts"

  task news_articles: :environment do
    require 'csv'
    csv_path = Rails.root.join("data/news_articles.csv")
    if File.exist?(csv_path)
      puts "Importing articles from: #{csv_path}"

      CSV.foreach(csv_path, headers: true) do |row|
        title = row['title'].to_s.strip
        next if title.blank?

        article = Article.find_or_initialize_by(title: title)

        publication_date = row['publication_date'].presence
        category = row['category'].presence
        author = row['author'].presence
        likes_string = row['like_counts_per_date'].to_s

        article.assign_attributes(
          publication_date: publication_date,
          category: category,
          author: author,
          body: read_html_body(title)
        )

        if article.save
          puts "Imported: #{title}"
          article.like_counts.destroy_all
          parse_likes(likes_string).each do |date_str, count|
            begin
              date_obj = Date.parse(date_str)
              article.like_counts.create!(date: date_obj, count: count)
            rescue ArgumentError => e
              puts "Warning: Could not parse date '#{date_str}' for article '#{title}'. Skipping this like count. Error: #{e.message}"
            rescue ActiveRecord::RecordInvalid => e
              puts "Warning: Failed to save like count for '#{title}' (Date: #{date_str}, Count: #{count}). Error: #{e.message}"
            end
          end
        else
          puts "Failed to save article: #{title}"
          puts "Errors: #{article.errors.full_messages.join(", ")}"
        end
      end
    else
      puts "CSV file not found at #{csv_path}"
    end
  end

   def read_html_body(title)
    filename = title.downcase.gsub(%r{[\s\-/]}, '_')
                      .gsub(/[.:\'%]/, '')
                      .concat('.html')
    file_path = Rails.root.join('data', filename)
    File.read(file_path)
  rescue Errno::ENOENT
    puts "Missing body file for: #{title}"
    ''
  end

  def parse_likes(likes_string)
    return {} if likes_string.blank?
    likes_string.split('|').to_h do |pair|

      date_part, _, count_str = pair.rpartition(':')
      if date_part.empty? && count_str.present? && !pair.include?(':')
        date_part = pair # The whole string is the date
        count_str = "0" # No count specified
      elsif date_part.empty? && count_str.empty? # Handles empty string or string with only a colon
        date_part = pair
        count_str = "0"
      end

      [date_part, count_str.to_i]
    end
  end
end