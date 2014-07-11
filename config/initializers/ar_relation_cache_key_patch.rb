module RelationCacheKey
  # Compute the cache key of a group of records.
  #
  #   Item.cache_key # => "0b27dac757428d88c0f3a0298eb0278f"
  #   Item.active.cache_key # => "0b27dac757428d88c0f3a0298eb0278e"
  #
  def cache_key
    scope_sql = where(nil).select("#{table_name}.id, #{table_name}.updated_at").to_sql

    # PostgreSQL only
    sql = "SELECT md5(array_agg(id || '-' || updated_at)::text) " +
        "FROM (#{scope_sql}) as query"

    md5 = connection.select_value(sql)

    key = if md5.present?
            md5
          else
            "empty"
          end

    "#{model_name.cache_key}/#{key}"
  end

  def updated_at
    where(nil).order(:updated_at).last.updated_at
  end
end

ActiveRecord::Base.extend RelationCacheKey
