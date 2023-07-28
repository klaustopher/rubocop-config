class User < ApplicationRecord
  validates :name, uniquenes: true

  def an_array
    [
      :foo,
      :bar,
      :test,
    ]
  end

  def a_hash
    {
      foo:                "test",
      bar:                "other",
      a_super_long_value: "something in there",
    }
  end

  private

  def foo
    :this_is_a_private_method
  end
end
