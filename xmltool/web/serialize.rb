def prune_areas(hash)
  new_hash = {}
  hash.each do |key, value|
    if value.is_a?(Hash)
      new_hash[key] = prune_areas(value)
    end
  end
  new_hash
end

def areas_to_tree(hash, parent_key = '')
  hash.map do |key, value|
    new_key = parent_key.empty? ? key : "#{parent_key}/#{key}"
    {
      'key' => new_key,
      'title' => key,
      'children' => value.is_a?(Hash) ? areas_to_tree(value, new_key) : []
    }
  end
end

def serialize_areas(hash)
  pruned_hash = prune_areas(hash)
  areas_to_tree(pruned_hash)
end

def serialize_classes(classes)
  classes.map do |clazz|
    {
      "value" => clazz,
      "label" => clazz.capitalize
    }
  end
end

def serialize_races(races)
  races_hash = races.map do |race|
    {
      "value" => race,
      "label" => race.capitalize
    }
  end

  races_hash << { value: "all", label: "All" }
end