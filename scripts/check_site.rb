# Validate the deployed artifact rather than the Liquid source templates.
require 'nokogiri'
require 'uri'
require 'yaml'
require 'pathname'

root = Pathname.new(ARGV.fetch(0, '_site')).expand_path
abort "Build output missing: #{root}" unless root.join('index.html').file?
config = YAML.safe_load_file('_config.yml')
site_url = config.fetch('url')
baseurl = config.fetch('baseurl', '')
site_host = URI(site_url).host
errors = []
documents = {}

Dir[root.join('**/*.html')].each do |file|
  source = File.read(file)
  next unless source.match?(/<html\b/i) # Preserve the Google verification file verbatim.

  doc = Nokogiri::HTML5(source, max_errors: 100)
  documents[Pathname.new(file)] = doc
  label = Pathname.new(file).relative_path_from(root)
  doc.errors.each { |error| errors << "#{label}: #{error.message}" }
  errors << "#{label}: missing language" if doc.at_css('html')['lang'].to_s.empty?
  errors << "#{label}: missing title" if doc.at_css('title')&.text.to_s.strip.empty?
  errors << "#{label}: missing main landmark" unless doc.at_css('main')
  errors << "#{label}: expected one h1" unless doc.css('h1').size == 1
  errors << "#{label}: missing description" if doc.at_css('meta[name="description"]')&.[]('content').to_s.empty?
  canonical = doc.at_css('link[rel="canonical"]')&.[]('href')
  path = '/' + label.to_s.delete_suffix('index.html')
  errors << "#{label}: incorrect canonical URL #{canonical.inspect}" unless canonical == site_url + baseurl + path
  ids = doc.css('[id]').map { |node| node['id'] }
  errors << "#{label}: duplicate IDs" unless ids.uniq.size == ids.size
  doc.css('img').each do |img|
    errors << "#{label}: image missing alt or src" unless img.key?('alt') && !img['src'].to_s.empty?
  end
  errors << "#{label}: obsolete script or zoom restriction" if source.match?(/jquery|analytics\.js|adsbygoogle|disqus|user-scalable\s*=\s*no/i)
end

# Resolve URLs against their real public paths, including absolute same-site URLs.
documents.each do |file, doc|
  page_path = '/' + file.relative_path_from(root).to_s
  doc.css('a[href], link[href], img[src], script[src]').each do |node|
    href = node[node.name == 'img' || node.name == 'script' ? 'src' : 'href']
    begin
      uri = URI.join(site_url + baseurl + page_path, href)
      next unless %w[http https].include?(uri.scheme) && uri.host == site_host

      path = URI::DEFAULT_PARSER.unescape(uri.path)
      next unless baseurl.empty? || path == baseurl || path.start_with?(baseurl + '/')
      path = path.delete_prefix(baseurl) unless baseurl.empty?
      target = root.join(path.delete_prefix('/')).cleanpath
      unless target.to_s.start_with?(root.to_s + '/') || target == root
        errors << "#{file.basename}: URL escapes output: #{href}"
        next
      end
      target = target.join('index.html') if target.directory?
      unless target.file?
        errors << "#{file.basename}: missing internal target #{href}"
        next
      end
      if uri.fragment && !uri.fragment.empty? && documents[target]
        fragment = URI::DEFAULT_PARSER.unescape(uri.fragment)
        errors << "#{file.basename}: missing fragment #{href}" unless documents[target].css('[id]').any? { |n| n['id'] == fragment }
      end
    rescue URI::InvalidURIError => e
      errors << "#{file.basename}: invalid URL #{href.inspect}: #{e.message}"
    end
  end
end

%w[feed.xml sitemap.xml].each do |name|
  path = root.join(name)
  unless path.file?
    errors << "Missing #{name}"
    next
  end
  begin
    xml = Nokogiri::XML(File.read(path)) { |options| options.strict.nonet }
    xml.xpath('//*[local-name()="loc"] | //*[local-name()="link"]/@href | //*[local-name()="id"]').each do |node|
      value = node.content
      errors << "#{name}: incorrect site URL #{value}" if value.start_with?('http') && !value.start_with?(site_url + baseurl + '/')
    end
  rescue Nokogiri::XML::SyntaxError => e
    errors << "#{name}: #{e.message}"
  end
end
%w[Gemfile Gemfile.lock README.md AGENTS.md design-qa.md scripts vendor .github _drafts params.json manoamaro.conf].each do |name|
  errors << "Private build/source file published: #{name}" if root.join(name).exist?
end
Dir['google*.html'].each do |source|
  output = root.join(source)
  expected = "google-site-verification: #{File.basename(source)}"
  unless output.file? && File.read(output).strip == expected
    errors << "#{source}: verification token missing or altered in public output"
  end
end
errors << 'Missing 404 page' unless root.join('404.html').file?
errors << 'Missing robots.txt' unless root.join('robots.txt').file?
abort errors.join("\n") unless errors.empty?
puts "Site checks passed: #{documents.size} HTML pages, internal links, feed, sitemap, and public output."
