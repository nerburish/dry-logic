module Dry
  module Logic
    def self.Predicate(block)
      case block
      when Method then Predicate.new(block.name, &block)
      else raise ArgumentError, 'predicate needs an :id'
      end
    end

    class Predicate
      include Dry::Equalizer(:id, :args)

      attr_reader :id, :args, :fn

      def initialize(id, *args, &block)
        @id = id
        @fn = block
        @args = args
      end

      #as long as we keep track of the args, we don't actually need to curry the proc...
      #if we never curry the proc then fn.arity & fn.parameters stay intact
      def curry(*args)
        all_args = @args+args
        if all_args.size <= arity
          self.class.new(id, *all_args, &fn)
        else
          raise_arity_error(all_args.size)
        end
      end

      #enables a rule to call with its params & have them ignored if the
      #predicate doesn't need them.
      #if @args.size == arity then we should ignore called args
      def call(*args)
        all_args = @args+args
        if @args.size == arity
          fn.(*@args)
        elsif all_args.size == arity
          fn.(*all_args)
        else
          raise_arity_error(all_args.size)
        end
      end

      def arity
        fn.arity
      end

      def parameters
        fn.parameters
      end

      def to_ast
        [:predicate, [id, args]]
      end
      alias_method :to_a, :to_ast

      private
      def raise_arity_error(args_size)
        raise ArgumentError, "wrong number of arguments (#{args_size} for #{arity})"
      end
    end
  end
end
