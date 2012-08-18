module Sidekiq::Status::Storage
  RESERVED_FIELDS=%w(status stop update_time).freeze

  protected

  # Stores multiple values a job's status hash
  # @param [String] id job id
  # @param [Hash] status_updates updated values
  # @return [String] Redis operation status code
  def store_for_id(id, status_updates)
    Sidekiq.redis do |conn|
      answers = conn.multi do
        conn.hmset(id, 'update_time', Time.now.to_i, *(status_updates.to_a.flatten))
        conn.expire(id, Sidekiq::Status::DEFAULT_EXPIRY)
      end
      answers[0]
    end
  end
end