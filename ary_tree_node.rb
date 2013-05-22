#!/usr/bin/env ruby

class TreeNode

  attr_accessor :parent
  attr_reader :value


  def initialize(value)
    @parent = nil
    @value = value
    @children = []
  end

  def adopt_child(node)
    @children << node
    node.parent = self
  end

  def children
    @children
  end

  def sever_child(node)
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

if __FILE__ == $PROGRAM_NAME

  while true

    puts "Please pass in a value for node."
    input = gets.chomp

    begin
      node1 = TreeNode.new(input)
    rescue ArgumentError => e
      puts e
      puts "Cannot run. Please pass in one argument"
    end

  end

end


