module Stamina
  module Induction
    
    #
    # Implements an UnionFind data structure dedicated to state merging induction algorithms.
    # For this purpose, this union-find handles mergeable user data as well as transactional 
    # support. See Stamina::Induction::Commons about the usage of this class (and mergeable 
    # user data in particular) by induction algorithms.
    #
    # == Example (probably easier than a long explanation)
    #
    #   # create a union-find for 10 elements
    #   ufds = Stamina::Induction::UnionFind.new(10) do |index|
    #     # each element will be associated with a hash with data of interest:
    #     # smallest element, greatest element and concatenation of names
    #     {:smallest => index, :greatest => index, :names => index.to_s}
    #   end
    #
    #   # each element is its own leader
    #   puts (0...10).all?{|s| ufds.leader?(s)} -> true
    #
    #   # and their respective group number are the element indices themselve
    #   puts ufds.to_a  -> [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    #
    #   # now, let merge 4 with 0
    #   ufds.union(0, 4) do |d0, d4|
    #     {:smallest => d0[:smallest] < d4[:smallest] ? d0[:smallest] : d4[:smallest],
    #      :greatest => d0[:smallest] > d4[:smallest] ? d0[:smallest] : d4[:smallest],
    #      :names => d0[:names] + " " + d4[:names]}
    #   end
    #
    #   # let see what happens on group numbers
    #   puts ufds.to_a -> [0, 1, 2, 3, 0, 5, 6, 7, 8, 9]
    #
    #   # let now have a look on mergeable_data of the group of 0 (same result for 4)
    #   puts ufds.mergeable_data(0).inspect -> {:smallest => 0, :greatest => 4, :names => "0 4"}
    #
    # == Basic Union Find API
    #
    # A UnionFind data structure typically allows encoding a partition of elements (a 
    # partition is a collection of disjoint sets - aka a collection of groups). Basically, 
    # this class represents elements by successive indices (from 0 to size, the later being 
    # excluded). The partitioning information is kept in a array, associating a group number 
    # to each element. This group number is simply the index of the least element in the 
    # group (which means that group numbers are not necessarily consecutive). For example, 
    # the following arrays maps to the associated partitions:
    #
    #   [0, 1, 2, 3, 4, 5] -> {{0}, {1}, {2}, {3}, {4}}
    #   [0, 0, 0, 0, 0, 0] -> {{0, 1, 2, 3, 4, 5}}
    #   [0, 1, 1, 0, 4, 4] -> {{0, 3}, {1, 2}, {5, 5}}
    #
    # The API of this basic union-find data structure is composed of the following 
    # methods:
    # - new(size) (class method): builds an initial partition information over _size_ 
    #   elements. This initial partition keeps each element in its own group.
    # - find(i): returns the group number of the i-th element
    # - union(i, j): merge the group of the i-th element with the group of the j-th 
    #   element. Note that i and j are elements, NOT group numbers.
    #
    # As we use least elements as group numbers, it is also interesting to know if a 
    # given element is that least element (aka leader element of the group) or not:
    #
    # - leader?(i): returns true if i is the group number of the i-th element, false
    #   otherwise. In other words, returns true if find(i)==i
    # - slave?(i): the negation of leader?(i).
    #
    # == Handling User Data
    #
    # Even if this class represents elements by indices, it also allows keeping user 
    # data attached to each group. For this:
    #
    # - an initial user data is attached to each element at construction time by 
    #   yielding a block (passing the element index as first argument and expecting
    #   user data as block return value).
    # - the union(i, j) method allows a block to be given. It passes user data of i's
    #   and j's groups as arguments and expects the block to compute and return the 
    #   merged user data for the new group.
    # - mergeable_data(i) returns the current user data associated to the group of 
    #   the i-th element.
    # - mergeable_datas returns an array with user data attached to each group.
    #
    # Please note that user data are considered immutable values, and should never be
    # changed... Only new ones can be created at union time. To ensures this good usage,
    # user data are freezed by this class at creation time and union time.
    #
    # == Transactional support
    #
    # The main aim of this UnionFind is to make the implementation induction algorithms 
    # Stamina::Induction::RPNI and Stamina::Induction::BlueFringe (sufficiently) efficient, 
    # simple and readable. These algorithms rely on a try-and-error strategy are must be
    # able to revert the changes they have made during their last try. The transaction 
    # support implemented by this data structure helps them achieving this goal. For this
    # we provide the following methods:
    #
    # - save_point: ensures that the internal state of the UnionFind can be restored if
    #   rollback is invoked later.
    # - commit: informs the UnionFind that changes that have been made since the last
    #   invocation of save_point will not be reconsidered.
    # - rollback: restores the internal state of the UnionFind that has been saved when
    #   save_point has been called.
    #
    # Please note that this class does not support sub-transactions.
    #
    class UnionFind
      
      #
      # An element of the union find, keeping the index of its leader element as well as 
      # mergeable user data. This class is not intended to be used by external users of the 
      # UnionFind data structure.
      #
      class Node
        
        # Index of the parent element (on the way to the leader)
        attr_accessor :parent
        
        # Attached user data
        attr_accessor :data 
        
        #
        # Creates a default Node instance with a specific parent index and attached
        # user data.
        #
        def initialize(parent, data)
          @parent = parent
          @data = data
        end
        
        #
        # Duplicates this node, ensuring that future changes will not affect the copy. 
        # Please note that the user data itself is not duplicated and is not expected 
        # to change. This property (not changing user data) is respected by the RPNI
        # and BlueFringe classes as implemented in this library.
        #
        def dup
          Node.new(@parent, @data)
        end
        
      end # class Node
      
      #
      # Number of elements in this union find
      #
      attr_reader :size
      
      #
      # (protected) Accessor on elements array, provided for duplication
      #
      attr_writer :elements
      
      #
      # Creates a default union find of a given size. Each element is initially in its own 
      # group. User data attached to each group is obtained by yielding a block, passing 
      # element index as first argument.
      #
      # Precondition:
      # - size is expected to be strictly positive
      #
      def initialize(size)
        @size = size
        @elements = (0...size).collect do |i| 
          Node.new(i, block_given? ? yield(i).freeze : nil)
        end
        @changed = nil
      end
      
      # Union Find API ###########################################################
      
      #
      # Finds the group number of the i-th element (the group number is the least
      # element of the group, aka _leader_).
      #
      # Preconditions:
      # - i is a valid element: 0 <= i < size
      #
      # Postconditions:
      # - returned value _found_ is such that <code>find(found)==found</code>
      # - the union find data structure is not modified (no compression implemented).
      #
      def find(i)
        while @elements[i].parent != i
          i = @elements[i].parent
        end
        i
      end
      
      #
      # Merges groups of the i-th element and j-th element, yielding a block to compute
      # the merging of user data attached to their respective groups before merging.
      #
      # Preconditions:
      # - This method allows i and j not to be leaders, but any element.
      # - i and j are expected to be valid elements (0 <= i <= size, same for j)
      #
      # Postconditions:
      # - groups of i and j have been merged. All elements of the two subgroups have 
      #   the group number defined as <code>min(find(i),find(j))</code> (before 
      #   merging)
      # - if a block is provided, the user data attached to the new group is computed by 
      #   yielding the block, passing mergable_data(i) and mergable_data(j) as arguments.
      #   The block is ecpected to return the merged data that will be kept for the new 
      #   group.
      # - If a transaction is pending, all required information is saved to restore
      #   the union-find structure if the transaction is rollbacked later.
      #
      def union(i, j)
        i, j = find(i), find(j)
        reversed = false
        i, j, reversed = j, i, true if j<i
        
        # Save i and j if in transaction and not already saved
        if @changed
          @changed[i] = @elements[i].dup unless @changed.has_key?(i)
          @changed[j] = @elements[j].dup unless @changed.has_key?(j)
        end
        
        # Make the changes now
        @elements[j].parent = i
        if block_given?
          d1, d2 = @elements[i].data, @elements[j].data
          d1, d2 = d2, d1 if reversed
          @elements[i].data = yield(d1, d2).freeze
        else
          nil
        end
      end
      
      #
      # Checks if an element is the leader of its group.
      #
      # Preconditions:
      # - i is a valid element: 0 <= i < size
      #
      # Postconditions:
      # - true if find(i)==i, false otherwise.
      #
      def leader?(i)
        @elements[i].parent==i
      end
      
      # 
      # Checks if an element is a slave in its group (negation of leader?).
      #
      # Preconditions:
      # - i is a valid element: 0 <= i < size
      #
      # Postconditions:
      # - false if find(i)==i, true otherwise.
      #
      def slave?(i)
        @elements[i].parent != i
      end
      
      # UserData API #############################################################
      
      #
      # Returns the mergeable data of each group in an array. No order of the
      # groups is ensured by this method.
      #
      def mergeable_datas
        indices = (0...size).select {|i| leader?(i)}
        indices.collect{|i| @elements[i].data}
      end
      
      #
      # Returns the mergeable data attached to the group of the i-th element.
      #
      # Preconditions:
      # - This method allows i not to be leader, but any element.
      # - i is a valid element: 0 <= i < size
      #
      def mergeable_data(i)
        @elements[find(i)].data
      end
      
      # Transactional API ########################################################
      
      #
      # Makes a save point now. Internally ensures that future changes will be 
      # tracked and that a later rollback will restore the union find to the 
      # internal state it had before this call. This method should not be called
      # if a transaction is already pending.
      #
      def save_point
        @changed = {}
      end
      
      #
      # Terminates the pending transaction by commiting all changes that have been 
      # done since the last save_point call. This method should not be called if no
      # transaction is pending.
      #
      def commit
        @changed = nil
      end
      
      #
      # Rollbacks all changes that have been done since the last save_point call.
      # This method will certainly fail if no transaction is pending.
      #
      def rollback
        @changed.each_pair do |index, node|
          @elements[index] = node
        end
        @changed = nil
      end
      
      # 
      # Makes a save point, yields the block. If it returns false or nil, rollbacks 
      # the transaction otherwise commits it. This method is a nice shortcut for
      # the following piece of code
      #
      #   ufds.save_point
      #   if try_something
      #     ufds.commit
      #   else
      #     ufds.rollback
      #   end
      #
      # which can also be expressed as:
      #
      #   ufds.transactional do
      #     try_something
      #   end
      #
      # This method returns the value returned by the block
      #
      def transactional
        save_point
        returned = yield
        if returned.nil? or returned == false
          rollback
        else
          commit
        end
        returned
      end
      
      # Common utilities #########################################################
      
      #
      # Duplicates this data-structure, ensuring that no change on self or on the 
      # copy is shared. Please note that user datas themselve are not duplicated as 
      # they are considered immutable values (and freezed at construction and union).
      #
      def dup
        copy = UnionFind.new(size)
        copy.elements = @elements.collect{|e| e.dup}
        copy
      end
      
      #
      # Returns the partitioning information as as array with the group number of 
      # each element.
      #
      def to_a
        (0...size).collect{|i| find(i)}
      end
      
      #
      # Returns a string representation of this union find information.
      #
      def to_s
        @elements.to_s
      end
      
      #
      # Returns a string representation of this union find information.
      #
      def inspect
        @elements.to_s
      end
      
      protected :elements=
    end # class UnionFind
    
  end # module Induction
end # module Stamina
