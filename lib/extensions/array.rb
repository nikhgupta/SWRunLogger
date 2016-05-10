class Array
  def average
    self.map(&:to_f).sum / count.to_f
  end

  def average_for(*method_chain)
    self.map do |record|
      data = record
      method_chain.each do |method|
        data = data.present? ? data.send(method) : nil
      end
      data
    end.average
  end
end
