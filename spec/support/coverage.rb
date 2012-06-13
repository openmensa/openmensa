
class SimpleCov::Formatter::MergedFormatter
  def format(result)
     SimpleCov::Formatter::HTMLFormatter.new.format(result)
     SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end
