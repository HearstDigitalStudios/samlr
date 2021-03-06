module Samlr
  class Condition
    attr_reader :audience, :not_before, :not_on_or_after, :options

    def initialize(condition, options)
      @options         = options
      @not_before      = (condition || {})["NotBefore"]
      @not_on_or_after = (condition || {})["NotOnOrAfter"]
      @audience        = extract_audience(condition)
    end

    def verify!
      unless not_before_satisfied?
        raise Samlr::ConditionsError.new("Not before violation, now #{Samlr::Tools::Timestamp.stamp} vs. earliest #{not_before}")
      end

      unless not_on_or_after_satisfied?
        raise Samlr::ConditionsError.new("Not on or after violation, now #{Samlr::Tools::Timestamp.stamp} vs. at latest #{not_on_or_after}")
      end

      unless audience_satisfied?
        raise Samlr::ConditionsError.new("Audience violation, expected #{options[:audience]} vs. #{audience}")
      end

      true
    end

    def not_before_satisfied?
      not_before.nil? || Samlr::Tools::Timestamp.not_before?(Samlr::Tools::Timestamp.parse(not_before))
    end

    def not_on_or_after_satisfied?
      not_on_or_after.nil? || Samlr::Tools::Timestamp.not_on_or_after?(Samlr::Tools::Timestamp.parse(not_on_or_after))
    end

    def audience_satisfied?
      audience.nil? || options[:audience].nil? ||
        options[:audience] === audience
    end

    private

    def extract_audience(condition)
      return unless condition

      audience_node = condition.at("./saml:AudienceRestriction/saml:Audience", NS_MAP)

      return unless audience_node

      audience_node.text
    end
  end
end
