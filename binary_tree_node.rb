
class TreeNode

  attr_writer :parent
  attr_reader :value

  def initialize(value)
    @parent = nil
    @value = value
  end

  def left=(node)
    self.left.parent = nil
    @left = node
    node.parent = self
  end

  def left
    @left
  end

  def right=(node)
    self.right.parent = nil
    @right = node
    node.parent = self
  end

  def right
    @right
  end

  def dfs(target_value)
    if @value == target_value
      return self
    elsif self.left.nil?
      return nil
    elsif self.right.nil?
      return nil
    else
      winning_node = @left.dfs(target_value)
      winning_node = @right.dfs(target_value) if answer.nil?
    end
    winning_node
  end

  def bfs(target_value)
    nodes_to_check = [self]
    until nodes_to_check.empty?
      current_node = nodes_to_check.shift
      if current_node.value == target_value
        return current_node
      else
        nodes_to_check.concat([current_node.left, current_mode.right])
      end
    end
  end

end
