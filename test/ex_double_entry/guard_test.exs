defmodule ExDoubleEntry.GuardTest do
  use ExDoubleEntry.DataCase, async: true
  alias ExDoubleEntry.{Account, Guard, Transfer}
  doctest Guard
end
