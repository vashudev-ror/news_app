require 'rails_helper'
require 'rake'

Rails.application.load_tasks

RSpec.describe 'import:news_articles', type: :task do
  let(:csv_path) { Rails.root.join('data', 'news_articles.csv') }
  let(:html_data_path) { Rails.root.join('data') }

  before do
    Rake::Task['import:news_articles'].reenable
    FileUtils.mkdir_p(html_data_path)
    Article.destroy_all
    LikeCount.destroy_all
  end

  def create_csv_file(content)
    File.write(csv_path, content)
  end

  def create_html_file(title, body_content)
    filename = title.downcase.gsub(%r{[\s\-/]}, '_')
                      .gsub(/[.:\'%]/, '')
                      .concat('.html')
    File.write(File.join(html_data_path, filename), body_content)
  end

  context 'when the CSV file is empty' do
    before do
      create_csv_file("title,publication_date,category,author,like_counts_per_date\n")
    end

    it 'processes without error and imports no articles' do
      expect { Rake::Task['import:news_articles'].invoke }.to_not raise_error
      expect(Article.count).to eq(0)
    end
  end

  context 'when importing valid data' do
    let(:csv_content) do
      "title,publication_date,category,author,like_counts_per_date\n" +
      "Test Article 1,2023-01-01,Tech,John Doe,2023-01-01:10|2023-01-02:15\n" +
      "Another Article,2023-02-15,Sports,Jane Smith,2023-02-15:5|2023-02-16:8\n"
    end
    let(:html_body_1) { "<html><body>Content of test article 1.</body></html>" }
    let(:html_body_2) { "<html><body>Content of another article.</body></html>" }

    before do
      create_csv_file(csv_content)
      create_html_file("Test Article 1", html_body_1)
      create_html_file("Another Article", html_body_2)
    end

    it 'imports articles and their like counts successfully' do
      expected_output_regex = /Importing articles from: #{Regexp.escape(csv_path.to_s)}\nImported: Test Article 1\nImported: Another Article\n/m
      expect { Rake::Task['import:news_articles'].invoke }
        .to output(expected_output_regex).to_stdout

      expect(Article.count).to eq(2)

      article1 = Article.find_by(title: 'Test Article 1')
      expect(article1).to be_present
      expect(article1.publication_date).to eq(Date.parse('2023-01-01'))
      expect(article1.category).to eq('Tech')
      expect(article1.author).to eq('John Doe')
      expect(article1.body).to eq(html_body_1)
      expect(article1.like_counts.count).to eq(2)
      expect(article1.like_counts.find_by(date: '2023-01-01').count).to eq(10)
      expect(article1.like_counts.find_by(date: '2023-01-02').count).to eq(15)

      article2 = Article.find_by(title: 'Another Article')
      expect(article2).to be_present
      expect(article2.publication_date).to eq(Date.parse('2023-02-15'))
      expect(article2.category).to eq('Sports')
      expect(article2.author).to eq('Jane Smith')
      expect(article2.body).to eq(html_body_2)
      expect(article2.like_counts.count).to eq(2)
      expect(article2.like_counts.find_by(date: '2023-02-15').count).to eq(5)
      expect(article2.like_counts.find_by(date: '2023-02-16').count).to eq(8)
    end
  end

  context 'when an article with the same title already exists' do
    let(:csv_content) do
      "title,publication_date,category,author,like_counts_per_date\n" +
      "Existing Article,2023-03-01,News,Original Author,2023-03-01:20\n"
    end
    let(:updated_csv_content) do
      "title,publication_date,category,author,like_counts_per_date\n" +
      "Existing Article,2023-03-02,Politics,New Author,2023-03-02:25|2023-03-03:30\n"
    end
    let(:html_body_original) { "Original body content." }
    let(:html_body_updated) { "Updated body content." }

    before do
      create_html_file("Existing Article", html_body_original)
      create_csv_file(csv_content)
      Rake::Task['import:news_articles'].invoke
      Rake::Task['import:news_articles'].reenable 
      create_html_file("Existing Article", html_body_updated)
      create_csv_file(updated_csv_content)
    end

    it 'updates the existing article and replaces its like counts' do
      expect(Article.count).to eq(1) # Ensure only one article initially
      article = Article.find_by(title: 'Existing Article')
      expect(article.author).to eq('Original Author')
      expect(article.like_counts.count).to eq(1)

      expect { Rake::Task['import:news_articles'].invoke }
        .to output(/Imported: Existing Article/).to_stdout

      expect(Article.count).to eq(1)
      article.reload
      expect(article.publication_date).to eq(Date.parse('2023-03-02'))
      expect(article.category).to eq('Politics')
      expect(article.author).to eq('New Author')
      expect(article.body).to eq(html_body_updated)
      expect(article.like_counts.count).to eq(2)
      expect(article.like_counts.find_by(date: '2023-03-02').count).to eq(25)
      expect(article.like_counts.find_by(date: '2023-03-03').count).to eq(30)
      expect(article.like_counts.find_by(date: '2023-03-01')).to be_nil
    end
  end

  context 'when a row has invalid data for an Article attribute' do
    let(:csv_content) do
      "title,publication_date,category,author,like_counts_per_date\n" +
      "Invalid Date Article,NOT_A_DATE,Sports,Invalid Author,2023-05-01:1\n"
    end
    let(:html_body) { "Body content." }

    before do
      create_csv_file(csv_content)
      create_html_file("Invalid Date Article", html_body)
    end

    it 'logs an error and does not save the article' do
      allow_any_instance_of(Article).to receive(:save) do |article_instance|
        article_instance.errors.add(:publication_date, "is not a valid date")
        false
      end

      expect { Rake::Task['import:news_articles'].invoke }
        .to output(/Failed to save article: Invalid Date Article.*Publication date is not a valid date/m).to_stdout
      expect(Article.count).to eq(0)
    end
  end

  context 'parse_likes helper method' do
    it 'correctly parses a valid likes string' do
      parsed_likes = parse_likes("2023-01-01:10|2023-01-02:15")
      expect(parsed_likes).to eq({"2023-01-01" => 10, "2023-01-02" => 15})
    end

    it 'returns an empty hash for an empty string' do
      parsed_likes = parse_likes("")
      expect(parsed_likes).to eq({})
    end

    it 'returns an empty hash for a nil string' do
      parsed_likes = parse_likes(nil)
      expect(parsed_likes).to eq({})
    end

    it 'handles single like entry' do
      parsed_likes = parse_likes("2024-01-01:100")
      expect(parsed_likes).to eq({"2024-01-01" => 100})
    end

    it 'handles string with invalid format gracefully' do
      parsed_likes = parse_likes("invalid_date:abc|another:def")
      expect(parsed_likes).to eq({"invalid_date" => 0, "another" => 0})
    end

    it 'handles date strings with colons correctly (e.g., timestamps)' do
      parsed_likes = parse_likes("2023-01-01 10:00:00:100|2023-01-02:50|NoColonDate")
      expect(parsed_likes).to eq({"2023-01-01 10:00:00" => 100, "2023-01-02" => 50, "NoColonDate" => 0})
    end
  end

  context 'read_html_body helper method' do
    it 'reads the content of an existing HTML file' do
      title = "Sample Article Title"
      body_content = "This is some HTML body content."
      create_html_file(title, body_content)

      expect(read_html_body(title)).to eq(body_content)
    end

    it 'returns an empty string and logs a message if the HTML file is missing' do
      title = "Non-existent HTML file"

      expect {
        expect(read_html_body(title)).to eq('')
      }.to output(/Missing body file for: Non-existent HTML file/).to_stdout
    end

    it 'handles special characters in title for filename conversion' do
      title = "Article with-Special:Chars%and/Slashes.1"
      body_content = "Special char body."
      create_html_file(title, body_content)

      expect(read_html_body(title)).to eq(body_content)
    end
  end
end