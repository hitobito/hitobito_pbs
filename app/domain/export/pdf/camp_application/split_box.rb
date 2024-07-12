module Export::Pdf
  class CampApplication
    class SplitBox
      include Prawn::View

      def initialize(document, gap: 15, left: nil, right: nil, height: 0)
        @document = document
        @gap = gap
        @height = height
      end

      def left(&block)
        @left = block
      end

      def right(&block)
        @right = block
      end

      def render
        bounding_box([0, cursor], width: bounds.width) do
          bounding_box([0, bounds.top], width: children_width) do
            @left&.yield
          end
          lowest = cursor
          bounding_box([children_width + @gap, bounds.top], width: children_width) do
            @right&.yield
          end
          lowest = cursor if cursor < lowest
          move_cursor_to lowest
        end
      end

      def children_width
        (bounds.width - @gap) / 2
      end

      def self.render(*, &block)
        box = new(*)
        yield(box)
        box.render
      end
    end
  end
end
