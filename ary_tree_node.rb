class TreeNode

  attr_accessor :parent
  attr_reader :value, :chickens


  def initialize(value)
    @parent = nil
    @value = value
    @children = []
    @chickens = true
  end

  def adopt_child(node)
    @children << node
    node.parent = self
  end

  def children
    @children
  end

  def severe_child(node)
    node.parent = nil
    @children.delete(node)
  end

  def dfs(&block)
    if block.call(self) == true
      return self
    else
      @children.each do |child_node|
        return nil if child_node.children.nil?
        winning_node = child_node.dfs(target_value)
      end
    end
    winning_node
  end

  def bfs(&block)
    nodes_to_check = [self]
    until nodes_to_check.empty?
      current_node = nodes_to_check.shift
      if block.call(self) == true
        return current_node
      else
        nodes_to_check.concat(current_node.children)
      end
    end
  end

end
