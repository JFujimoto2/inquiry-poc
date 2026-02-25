module Aipass
  Response = Struct.new(:success, :data, :error_message, keyword_init: true) do
    def success?
      success
    end
  end
end
