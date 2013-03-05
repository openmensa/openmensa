class Transactional < MethodDecorators::Decorator
  def call(orig, this, *args, &blk)
    ActiveRecord::Base.transaction do
      orig.call(*args, &blk)
    end
  end
end
