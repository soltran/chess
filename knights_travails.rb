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


class KnightMoves

  attr_reader :positions_coordinates

  def initialize(start_position)
    @start_position = start_position
  end

  def find_possible_moves(start_position)
    theoretical_moves = find_theoretical_moves(start_position)
    theoretical_moves.select do |move|
      move.all? { |coordinate| coordinate >= 0 && coordinate < 8}
    end
  end

  def ignore_previous_moves(possible_moves, moves_made)
    constrained_moves = possible_moves.select {|move| !moves_made.include? move}
  end

  def generate_children(node)
    possible_moves = find_possible_moves(node.value)
    possible_moves.each do |possible_move|
      new_tree_node = TreeNode.new(possible_move)
      node.adopt_child(new_tree_node)
    end

    node.children
  end


  def generate_descendants(node, nodes_created = [])
    if nodes_created.count == 64
      return nodes_created
    else
      new_generation = generate_children(node)
      new_generation.each do |child_node|
        positions_visited = nodes_created.map {|node_created| node_created.value}
        current_position = child_node.value
        next if positions_visited.include?(current_position)
        nodes_created << child_node
        generate_descendants(child_node, nodes_created)
      end
    end
    nodes_created
  end

  def move_tree
    root_node = TreeNode.new(@start_position)

    descendent_nodes = generate_descendants(root_node)

    descendent_nodes
  end

  private

  def reassign_coordinates(shuffled_coordinates)
    new_x_coordinates, new_y_coordinates = shuffled_coordinates

    new_y_coordinates << new_y_coordinates.shift
    new_y_coordinates << new_y_coordinates.shift

    first_x_half = new_x_coordinates.shift, new_x_coordinates.shift
    second_x_half = new_x_coordinates

    first_y_half = new_y_coordinates.shift, new_y_coordinates.shift
    second_y_half = new_y_coordinates

    first_halves = first_x_half, first_y_half

    second_halves = second_x_half, second_y_half

    in_halves = first_halves, second_halves

    in_halves
  end

  def find_theoretical_moves(start_position)
    total_moves = []
    x, y  = start_position
    updated_coordinates = [[], []]
    additions = [-1, 1, -2, 2]
    start_position.each_with_index do |coordinate, index|
      additions.each do |addition|
        updated_coordinates[index] << (coordinate + addition)
      end
    end
    reassigned_coordinates = reassign_coordinates(updated_coordinates)
    reassigned_coordinates.each do |half|
      half.first.each do |first_half_first|
        half.last.each do |first_half_second|
          total_moves << [first_half_first, first_half_second]
        end
      end
    end
    total_moves
  end
end


board = KnightMoves.new([5,2])
node = TreeNode.new([0,0])
nodes_created = board.generate_descendants(node)
nodes_created.each_with_index {|node, index| p "#{index}: #{node.value.inspect}"}


nodes_created.each do |node|
    node.parent.each do |parent|
      p parent.parent.value
    end
  end