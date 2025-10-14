# auto_register: false
# frozen_string_literal: true

module Site
  module Views
    class Scope < Hanami::View::Scope
      def initialize(**)
        super
        # Preserve slots across nested scope/render calls by threading them via locals.
        @_slots = _locals[:_slots] || {}

        # Evaluate the block given to `#render_scope` so that we can fill our slots.
        _locals[:render_scope_block]&.call(self)
      end

      def render_with_slots(partial_name, **locals, &block)
        # `#scope` inside templates does not do anything with its given block at the moment. Save
        # the block into a special local name that we then call inside the custom scope class'
        # `#initialize`.
        s = scope(render_scope_block: block, _slots: {})
        s.render(partial_name, **locals, _slots: s._slots)
      end

      def slot(name, content = nil)
        @_slots[name] = (content || yield).html_safe
      end

      def slot?(name)
        @_slots.key?(name)
      end

      def render_slot(name)
        @_slots[name]
      end

      attr_reader :_slots
    end
  end
end
