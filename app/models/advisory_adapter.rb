class AdvisoryAdapter < Struct
  def initialize(hsh)
    super *members.map{|k| hsh[k.to_s] }
  end

end
