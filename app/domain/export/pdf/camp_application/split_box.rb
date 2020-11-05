
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
        original = @document 
        @document = original.clone
        page_count_was = @document.page_count
        render_container
        page_count_is = @document.page_count
        @document = original 
        # start_new_page if page_count_is > page_count_was
        # render_container
      end

      def render_container
        bounding_box([0, cursor], width: bounds.width) do
          bounding_box([0, bounds.top], width: children_width) do
            @left.yield if @left
          end
          @height = cursor
          bounding_box([children_width + @gap, bounds.top], width: children_width) do
            @right.yield if @right
          end
          @height = cursor if cursor < @height
          move_cursor_to @height
        end
      end

      def children_width
        (bounds.width - @gap) / 2
      end

      def self.render(*args, &block)
        box = self.new(*args)
        yield(box)
        box.render
      end
    end
  end
end


