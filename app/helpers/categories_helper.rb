module CategoriesHelper
  def path_to_root( c )
    r_val = []
    while c
      r_val.push( c )
      c = c.parent
    end
    return r_val
  end
end
