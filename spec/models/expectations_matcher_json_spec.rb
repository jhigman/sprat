require_relative '../../app.rb'

describe Sprat::ExpectationsMatcherJson do

  it "should match integer with string number" do

    outputs = [
      { 'path' => '$.[0].item', 'value' => '23', 'label' => 'Item1'}
    ]

    item1 = {'item' => 23}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should match string numbers" do

    outputs = [
      { 'path' => '$.[0].item', 'value' => '23', 'label' => 'Item1'}
    ]

    item1 = {'item' => '23'}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should match decimal numbers" do

    outputs = [
      { 'path' => '$.[0].item', 'value' => 6.78, 'label' => 'Item1'}
    ]

    item1 = {'item' => 6.78}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end


  it "should match decimal and string decimal" do

    outputs = [
      { 'path' => '$.[0].item', 'value' => '6.78', 'label' => 'Item1'}
    ]

    item1 = {'item' => 6.78}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end


  it "should match strings" do

    outputs = [
      { 'path' => '$.[0].item', 'value' => 'hello', 'label' => 'Item1'},
      { 'path' => '$.[1].item', 'value' => 'one, two, three', 'label' => 'Item2'}
    ]

    item1 = {'item' => 'hello'}
    item2 = {'item' => 'one, two, three'}
    response = [item1, item2]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should match strings ignoring whitespace" do

    outputs = [
      { 'path' => '$.[0].item', 'value' => 'hello, matey', 'label' => 'Item1'},
    ]

    item1 = {'item' => "    hello  \r\n    ,  matey "}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should match arrays" do

    outputs = [
      { 'path' => '$.[0].item', 'value' => 'hello', 'label' => 'Item1'},
      { 'path' => '$.[1].item', 'value' => 'one,    two,   three', 'label' => 'Item2'},
      { 'path' => '$.[2].item', 'value' => 'one,two,three', 'label' => 'Item3'},
    ]

    item1 = {'item' => ["hello"]}
    item2 = {'item' => ["one", "two", "three"]}
    item3 = {'item' => ["one", "   two", "three"]}
    response = [item1, item2, item3]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should match dates in expected formats" do

    outputs = [
      { 'path' => '$.[0].item', 'value' => "2014-01-24", 'label' => 'Item1'}
    ]

    item1 = {'item' => "2014-01-24"}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

    outputs = [
      { 'path' => '$.[0].item', 'value' => "24/01/2014", 'label' => 'Item1'}
    ]

    expect(matcher.match(outputs)).to eql([])

    outputs = [
      { 'path' => '$.[0].item', 'value' => "2014-01-23", 'label' => 'Item1'}
    ]

    expect(matcher.match(outputs)).to eql(["Expected 2014-01-23 for 'Item1', but found 2014-01-24"])

    outputs = [
      { 'path' => '$.[0].item', 'value' => "24 Jan 2014", 'label' => 'Item1'}
    ]

    expect(matcher.match(outputs)).to eql(["Expected 24 Jan 2014 for 'Item1', but found 2014-01-24"])

    outputs = [
      { 'path' => '$.[0].item', 'value' => "2014-01-24T12:34", 'label' => 'Item1'}
    ]

    expect(matcher.match(outputs)).to eql(["Expected 2014-01-24T12:34 for 'Item1', but found 2014-01-24"])


  end


  it "should match dates ignoring times" do

    outputs = [
      { 'path' => '$.[0].item', 'value' => "24/01/2014", 'label' => 'Item1'}
    ]

    item1 = {'item' => "2014-01-24T13:45"}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should demonstrate issue with commas in keys" do

    outputs = [
      { 'path' => "$.['one, two']", 'value' => "some value", 'label' => 'Item1'}
    ]

    response = {["one, two"] => "some value"}

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    # really we want to get "some value" returned, but comma is reserved for ranges in jsonpath
    expect(matcher.match(outputs)).to eql(["Expected some value for 'Item1', but found nothing"])

  end


  it "should match simple arrays" do

    outputs = [
      { 'path' => "$.[0]", 'value' => "one", 'label' => 'Item1'},
      { 'path' => "$.[1]", 'value' => "two", 'label' => 'Item2'}
    ]

    response = ["one", "two"]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should match simple hashes" do

    outputs = [
      { 'path' => "$.first", 'value' => "one", 'label' => 'Item1'},
      { 'path' => "$.second", 'value' => "two", 'label' => 'Item2'}
    ]

    response = { 'first' => 'one', 'second' => 'two' }

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should match paths with root" do

    outputs = [
      { 'path' => '$.root[0].name', 'value' => "one", 'label' => 'Item1'},
      { 'path' => '$.root[1].name', 'value' => "two", 'label' => 'Item2'}
    ]

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}
    response = { 'root' => [item1, item2]}

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])


  end

  it "should match paths without root" do

    outputs = [
      { 'path' => '$.[0].name', 'value' => 'one', 'label' => 'Name1'}
    ]

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}
    response = [item1, item2]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should match paths with spaces" do

    outputs = [
      { 'path' => '$.["name second"]', 'value' => 'two', 'label' => 'Name1'}
    ]

    response = {'name first' => 'one', 'name second' => 'two'}

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql([])

  end

  it "should handle path not found despite jsonpath bug" do

    outputs = [
      { 'path' => '$.[99].name', 'value' => 'one', 'label' => 'Name1'}
    ]

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}
    response = [item1, item2]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql(["Expected one for 'Name1', but found nothing"])
  end

  it "should match nested hash with case sensitivity" do

    outputs = [
      { 'path' => '$.root[0].name', 'value' => 'one', 'label' => 'Name1'},
      { 'path' => '$.root[1].name', 'value' => 'TWO', 'label' => 'Name2'}
    ]

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}
    response = { 'root' => [item1, item2]}

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    expect(matcher.match(outputs)).to eql(["Expected TWO for 'Name2', but found two"])

  end


end