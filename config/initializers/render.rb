storage_path = Rails.root.join("storage")
Dir.mkdir(storage_path) unless File.exist?(storage_path)