require 'clearwater/black_box_node'
require 'bowser'

module Clearwater
  module VirtualList
    def self.create(buffer: 0, &block)
      Class.new(Component) do
        define_method :content do
          block.call(
            items: @items[@first..@last],
            list_style: {
              height: "#{total_height}px",
              padding_top: "#{@first * height}px",
              box_sizing: 'border-box',
            },
            item_style: {
              height: "#{height}px",
              box_sizing: 'border-box',
            },
          )
        end

        define_method(:buffer) { buffer }
      end
    end

    class Component
      include Clearwater::BlackBoxNode

      attr_reader :items, :height
      attr_reader :onscroll, :onresize
      attr_reader :app
      attr_accessor :first, :last

      def initialize(items, item_height:)
        @items = items
        @height = item_height
      end

      def mount element
        @app = Clearwater::Application.new(
          component: Container.new(self),
          router: NullRouter.new,
          element: element,
        )
        @onscroll = Bowser.window.on(:scroll) { render_content element }
        @onresize = Bowser.window.on(:resize) { render_content element }

        render_content element
      end

      def update previous, element
        @app = previous.app
        @app.component.list = self
        @onscroll = previous.onscroll
        @onresize = previous.onresize

        return if height == previous.height &&
          buffer == previous.buffer &&
          items == previous.items

        render_content element
      end

      def unmount
        Bowser.window.off :scroll, &onscroll
        Bowser.window.off :resize, &onresize
      end

      def render_content(element)
        app.component.list.first, app.component.list.last = app.component.list.visible_item_bounds(element)

        app.perform_render
      end

      def visible_item_bounds(element)
        window = Bowser.window
        view_height = window.inner_height || window.client_height

        view_top = window.page_y_offset
        view_bottom = view_top + view_height

        list_top = top_from_window(element) - top_from_window(window)
        list_height = height.to_i * items.count

        list_view_top = [0, view_top - list_top].max
        list_view_bottom = [0, [list_height, view_bottom - list_top].min].max

        first_item_index = [0, (list_view_top / height).to_i - buffer].max
        last_item_index = [items.count, (list_view_bottom / height).ceil + buffer].min

        [first_item_index, last_item_index]
      end

      def top_from_window element
        return 0 unless element
        return 0 if element.equal? Bowser.window

        element.offset_top.to_i + top_from_window(element.offset_parent)
      end

      def total_height
        height * items.count
      end

      class Container
        include Clearwater::Component

        attr_accessor :list

        def initialize list
          @list = list
        end

        def render
          list.content
        end
      end

      class NullRouter
        def application= _
        end

        def set_outlets
        end
      end
    end
  end
end

# Monkeypatch to wrap the offsetParent element
module Bowser
  class Element
    def offset_parent
      parent = super

      return unless parent

      Element.new(parent)
    end
  end
end
