# An email template which can be personalized for a given resource
class EmailTemplator

  # white-list of special keywords to be replaced
  KEYWORDS = {}

  # 2-array with left and right keyword delimiters
  DELIMITERS = %w({ })

  ATTRIBUTES = [:subject, :body]

  attr_reader(*ATTRIBUTES)
  attr_reader :errors

  def initialize(subject, body)
    @subject, @body = subject, body

    @errors = []
  end

  def valid?
    ATTRIBUTES.each do |attribute|
      value = public_send(attribute)
      if value.nil? || value.empty?
        @errors << "#{attribute.to_s.capitalize} can't be blank"
      end
    end

    unless unknown_keywords.empty?
      @errors << "Unknown keywords found: #{unknown_keywords.join(', ')}"
    end

    @errors.empty?
  end

  def personalize resource
    raise ArgumentError, @errors unless valid?

    resource = pre_personalize_hook resource

    replace_map = self.class::KEYWORDS.inject({}) do |hash, (keyword,method)|
      replace = resource.public_send(method)
      hash.merge!(keyword => replace.to_s)
    end.freeze

    personalized = {}

    ATTRIBUTES.each do |attribute|
      attribute_value = public_send(attribute).dup

      replace_map.each do |key, value|
        attribute_value.gsub!(self.class.keyword_with_delimiters(key), value)
      end

      personalized[attribute] = attribute_value
    end

    self.class.new(personalized[:subject], personalized[:body]).freeze
  end

  def pre_personalize_hook resource
    resource
  end

  def unknown_keywords
    regexp = /#{Regexp.escape(self.class::DELIMITERS.first)}(.*?)#{Regexp.escape(self.class::DELIMITERS.last)}/

    present_keywords = ATTRIBUTES.map do |attribute|
      public_send(attribute).to_s.scan(regexp).map(&:first)
    end.flatten

    present_keywords - self.class.keywords
  end

  def self.keywords_with_delimiters
    keywords.map do |keyword|
      keyword_with_delimiters keyword
    end
  end

private

  def self.keyword_with_delimiters keyword
    "#{self::DELIMITERS.first}#{keyword}#{self::DELIMITERS.last}"
  end

  def self.keywords
    self::KEYWORDS.keys.map(&:to_s).sort
  end
end
