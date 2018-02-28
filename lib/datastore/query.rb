require 'druid'

module Datastore
  class Query
    def initialize(datasource:, properties:, dimensions:, aggregators:)
      properties = ActiveSupport::HashWithIndifferentAccess.new(properties)

      @datasource = Druid::DataSource.new(datasource, ENV['DRUID_URL'])
      @query = Druid::Query::Builder.new
      @interval = properties[:interval]
      @granularity = properties[:granularity] || 'all'
      @limit = properties[:limit] || 5
      @dimensions = dimensions || []
      @aggregators = aggregators || []
      build
    end

    def run
      result = @datasource.post(@query)
      if top_n?
        convert_top_n_data(result)
      else
        convert_timeserie_data(result)
      end
    end

    def timeserie?
      @dimensions.blank?
    end

    def multiseries?
      @dimensions.size == 1 && @granularity != 'all'
    end

    def top_n?
      @dimensions.size == 1 && @granularity == 'all'
    end

    def group_by?
      @dimensions.size > 1
    end

    private

    def build
      @query.interval(*@interval)
      @query.granularity(@granularity)

      set_aggregators

      if multiseries?
        # TODO
      elsif top_n?
        @query.topn(@dimensions.first.name.to_sym, @aggregators.first.name.to_sym, @limit)
      elsif group_by?
        @query.group_by(*@dimensions.map(&:name))
        @query.limit(@limit, @dimensions.map { |d| [d.name, :desc] })
      else
        # timeserie
      end
    end

    def set_aggregators
      @aggregators.group_by(&:aggregator_type).each do |type, aggregators|
        @query.send(type.underscore, aggregators.map(&:name))
      end
    end

    def convert_top_n_data(result)
      result.map do |row|
        row['result']
      end.flatten
    end

    def convert_timeserie_data(result)
      result.map do |row|
        row.merge!(row['result']).delete('result')
        row
      end
    end
  end
end
